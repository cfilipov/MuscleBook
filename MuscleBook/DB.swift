/*
 Muscle Book
 Copyright (C) 2016  Cristian Filipov

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation
import SQLite
import SQLiteMigrationManager

class DB {
    let connection: Connection
    static let sharedInstance = DB()
    private let migrationManager: SQLiteMigrationManager
    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! + "/musclebook.db"

    private init() {
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(path) {
            let bundlePath = BundlePath(name: "musclebook", type: "db")
            try! fileManager.copyItemAtPath(bundlePath, toPath: path)
        }

        connection = try! Connection(path)
        migrationManager = SQLiteMigrationManager(db: connection, migrations: DB.migrations())

        #if DEBUG
            print("Database: " + path)
            connection.trace{print($0)}
        #endif
    }

    static func migrations() -> [Migration] {
        return [
            MigrationInit()
        ]
    }

    func migrateIfNeeded() throws {
        if !migrationManager.hasMigrationsTable() {
            try migrationManager.createMigrationsTable()
        }

        if migrationManager.needsMigration() {
            try migrationManager.migrateDatabase()
        }
    }
}

protocol ModelType {
    associatedtype Adapter: AdapterType
}

protocol KeyedModelType: ModelType {
    associatedtype Adapter: KeyedAdapterType
    var identifier: Int64? { get }
}

protocol DateModelType: ModelType {
    associatedtype Adapter: DateAdapterType
    var date: NSDate { get }
}

protocol AdapterType {
    associatedtype Model
    static func mapRow(row: Row) -> Model
}

protocol KeyedAdapterType: AdapterType {
    associatedtype Model
    static var identifier: Expression<Int64> { get }
}

protocol DateAdapterType: AdapterType {
    associatedtype Model
    static var date: Expression<NSDate> { get }
}

protocol TableAdapterType: AdapterType {
    associatedtype Model
    static func setters(model: Model) -> [SQLite.Setter]
    static var table: SchemaType { get }
}

extension AdapterType {
    static var db: SQLite.Connection {
        return DB.sharedInstance.connection
    }
}

extension SequenceType where Generator.Element == Row {
    func adapterOf<Model: ModelType where Model.Adapter.Model == Model>(type: Model.Type) -> AnySequence<Model> {
        return AnySequence { Void -> AnyGenerator<Model> in
            var generator = self.generate()
            return AnyGenerator {
                guard let row = generator.next() else { return nil }
                return Model.Adapter.mapRow(row)
            }
        }
    }
}

extension TableAdapterType where Model: ModelType, Model.Adapter == Self {

    static func all() throws -> AnySequence<Model> {
        return try db.prepare(table).adapterOf(Model.self)
    }

    static func save(item: Model) throws -> Int64 {
        return try db.run(
            table.insert(setters(item))
        )
    }

    static func count() -> Int {
        return db.scalar(table.count)
    }

}

extension TableAdapterType where Model: KeyedModelType, Model.Adapter == Self {

    static func find(identifier: Int64) -> Model? {
        let query = table.filter(self.identifier == identifier)
        guard let row = db.pluck(query) else { return nil }
        return mapRow(row)
    }

    static func delete(item: Model) throws -> Int {
        guard let identifier = item.identifier
            else { fatalError("Identifier required to delete item \(item)") }
        let query = table.filter(self.identifier == identifier)
        return try db.run(query.delete())
    }

}

extension DateAdapterType where Model: DateModelType, Model.Adapter == Self, Self: TableAdapterType {

    static func newest() throws -> Model? {
        guard let row = db.pluck(table.order(date.desc)) else { return nil }
        return mapRow(row)
    }

    static func oldest() throws -> Model? {
        guard let row = db.pluck(table.order(date.asc)) else { return nil }
        return mapRow(row)
    }

    static func minDate() -> NSDate? {
        return db.pluck(table.select(date.min))?.get(date.min)
    }

}


