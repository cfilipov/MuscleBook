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

protocol Schema {
    static var migration: Migration { get }
    static var version: Int64 { get }
    static func migrateDatabase(db: Connection) throws
}

struct AnyMigration<S: Schema>: Migration {
    let version: Int64
    let schema: S.Type

    init(schema: S.Type) {
        self.schema = schema
        self.version = schema.version
    }

    func migrateDatabase(db: Connection) throws {
        try S.migrateDatabase(db)
    }
}

extension Schema {
    static var migration: Migration {
        return AnyMigration(schema: self)
    }
}
