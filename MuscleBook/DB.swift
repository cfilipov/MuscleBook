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

// MARK:

typealias CurrentSchema = Schema20160608215756485

class DB {

    enum Error: ErrorType {
        case CannotInsertWorkset
        case RecalculateWorkoutFailed
    }

    static let sharedInstance = DB()

    static let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask, true
        ).first! + "/musclebook.db"

    static let exercisesURL = NSBundle
        .mainBundle()
        .URLForResource("exercises", withExtension: "yaml")!

    let db: Connection

    private init() {
        let fileManager = NSFileManager.defaultManager()

        if !fileManager.fileExistsAtPath(DB.path) {
            let bundlePath = BundlePath(name: "musclebook", type: "db")
            try! fileManager.copyItemAtPath(bundlePath, toPath: DB.path)
        }

        db = try! Connection(DB.path)

        #if DEBUG
            print("Database: " + DB.path)
            db.trace{print($0)}
        #endif

        let migrationManager = SQLiteMigrationManager(
            db: db,
            migrations: [
                Schema20160410215418161.migration,
                Schema20160524095754146.migration,
                Schema20160601181210067.migration,
                Schema20160608215756485.migration
            ]
        )

        if !migrationManager.hasMigrationsTable() {
            try! migrationManager.createMigrationsTable()
        }

        if migrationManager.needsMigration() {
            try! migrationManager.migrateDatabase()
            try! importYAML(Exercise.self, fromURL: DB.exercisesURL)
            try! recalculateAll()
        }
    }

}

