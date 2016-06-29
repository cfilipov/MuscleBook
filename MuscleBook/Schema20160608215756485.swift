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

import SQLite
import SQLiteMigrationManager

private typealias Prev = Schema20160601181210067

enum Schema20160608215756485: Schema {
    static var version: Int64 = 20160608215756485
    
    static func migrateDatabase(db: Connection) throws {
        try Force.migrateDatabase(db)
        try Mechanics.migrateDatabase(db)
        try ExerciseType.migrateDatabase(db)
        try SkillLevel.migrateDatabase(db)
        try Exercise.migrateDatabase(db)
    }
}

private typealias This = Schema20160608215756485

extension Schema20160608215756485 {
    typealias Muscle = Prev.Muscle
    typealias MuscleMovementClassification = Prev.MuscleMovementClassification
    typealias MuscleMovement = Prev.MuscleMovement
    typealias ExerciseReference = Prev.ExerciseReference
    typealias Activation = Prev.Activation
    typealias InputOptions = Prev.InputOptions
    typealias Equipment = Prev.Equipment
    typealias Workset = Prev.Workset
    typealias Workout = Prev.Workout
    
    /* New table */
    
    enum Force {
        static let table = Table("force")
        static let forceID = Expression<Int64>("force_id")
        static let name = Expression<String>("name")
    }
    
    /* New table */
    
    enum Mechanics {
        static let table = Table("mechanics")
        static let mechanicsID = Expression<Int64>("mechanics_id")
        static let name = Expression<String>("name")
    }
    
    /* New table */
    
    enum ExerciseType {
        static let table = Table("exercise_type")
        static let exerciseTypeID = Expression<Int64>("exercise_type_id")
        static let name = Expression<String>("name")
    }
    
    /* New table */
    
    enum SkillLevel {
        static let table = Table("skill_level")
        static let skillLevelID = Expression<Int64>("skill_level_id")
        static let name = Expression<String>("name")
    }
    
    /* Modify table */
    
    enum Exercise {
        static var table = _table
        static let _table = Table("exercise")
        static let _tableTMP = Table("exercise_tmp")
        
        static var search = _search
        static let _search = VirtualTable("exercise_search")
        static let _searchTMP = VirtualTable("exercise_search_tmp")
        
        static let exerciseID = Expression<Int64>("exercise_id")
        static let inputOptions = Expression<MuscleBook.Exercise.InputOptions>("input_options_id")
        static let name = Expression<String>("exercise_name")
        static let equipment = Expression<MuscleBook.Exercise.Equipment>("equipment_id")
        static let gif = Expression<String?>("gif")
        static let force = Expression<MuscleBook.Exercise.Force?>("force_id")
        static let skillLevel = Expression<MuscleBook.Exercise.SkillLevel?>("skill_level_id")
        static let mechanics = Expression<MuscleBook.Exercise.Mechanics?>("mechanics_id")
        static let exerciseType = Expression<MuscleBook.Exercise.ExerciseType>("exercise_type_id")
        static let instructions = Expression<ArrayBox<String>?>("instructions")
        static let link = Expression<String?>("link") // Now optional
        static let source = Expression<String?>("source")
    }
}

// MARK:

extension This.Exercise {
    static func migrateDatabase(db: Connection) throws {
        table = _tableTMP
        search = _searchTMP
        try db.run(
            table.create(ifNotExists: true) { t in
                /* Column Constraints */
                t.column(exerciseID, primaryKey: true)
                t.column(name, unique: true)
                t.column(inputOptions)
                t.column(equipment)
                t.column(gif)
                t.column(force)
                t.column(skillLevel)
                t.column(mechanics)
                t.column(exerciseType)
                t.column(instructions)
                t.column(link)
                t.column(source)
            }
        )
        try db.run(
            table.createIndex([exerciseID], ifNotExists: true)
        )
        try db.run(
            search.create(.FTS4([exerciseID, name], tokenize: .Porter))
        )
        typealias PE = Prev.Exercise
        for ex in try db.prepare(PE.table) {
            let rowid = try db.run(
                table.insert(
                    exerciseID <- ex[PE.exerciseID],
                    name <- ex[PE.name],
                    equipment <- ex.get(PE.equipmentID),
                    inputOptions <- ex.get(PE.inputOptions),
                    gif <- ex[PE.gif],
                    force <- ex[PE.force].flatMap { MuscleBook.Exercise.Force(name: $0) },
                    skillLevel <- ex[PE.level].flatMap { MuscleBook.Exercise.SkillLevel(name: $0) },
                    mechanics <- ex[PE.mechanics].flatMap { MuscleBook.Exercise.Mechanics(name: $0) },
                    exerciseType <- MuscleBook.Exercise.ExerciseType(name: ex[PE.type])!,
                    instructions <- ex.get(PE.instructions),
                    link <- ex[PE.link],
                    source <- ex[PE.source]
                )
            )
            try db.run(
                search.insert(or: .Replace,
                    exerciseID <- rowid,
                    name <- ex[PE.name]
                )
            )
        }
        try db.run(Prev.Exercise.table.drop(ifExists: true))
        try db.run(Prev.Exercise.search.drop(ifExists: true))
        try db.run(_tableTMP.rename(_table))
        try db.run(_searchTMP.rename(_search))
        table = _table
        search = _search
    }
    
}

extension This.Force {
    static func migrateDatabase(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(forceID, primaryKey: true)
                t.column(name)
            }
        )
        typealias F = MuscleBook.Exercise.Force
        try db.run(table.insert(forceID <- F.Push.rawValue, name <- F.Push.name))
        try db.run(table.insert(forceID <- F.Pull.rawValue, name <- F.Pull.name))
        try db.run(table.insert(forceID <- F.PushAndPull.rawValue, name <- F.PushAndPull.name))
    }
}

extension This.Mechanics {
    static func migrateDatabase(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(mechanicsID, primaryKey: true)
                t.column(name)
            }
        )
        typealias M = MuscleBook.Exercise.Mechanics
        try db.run(table.insert(mechanicsID <- M.Isolation.rawValue, name <- M.Isolation.name))
        try db.run(table.insert(mechanicsID <- M.Compound.rawValue, name <- M.Compound.name))
    }
}

extension This.SkillLevel {
    static func migrateDatabase(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(skillLevelID, primaryKey: true)
                t.column(name)
            }
        )
        typealias S = MuscleBook.Exercise.SkillLevel
        try db.run(table.insert(skillLevelID <- S.Beginer.rawValue, name <- S.Beginer.name))
        try db.run(table.insert(skillLevelID <- S.Intermediate.rawValue, name <- S.Intermediate.name))
        try db.run(table.insert(skillLevelID <- S.Advanced.rawValue, name <- S.Advanced.name))
    }
}

extension This.ExerciseType {
    static func migrateDatabase(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(exerciseTypeID, primaryKey: true)
                t.column(name)
            }
        )
        typealias E = MuscleBook.Exercise.ExerciseType
        try db.run(table.insert(exerciseTypeID <- E.BasicOrAuxiliary.rawValue, name <- E.BasicOrAuxiliary.name))
        try db.run(table.insert(exerciseTypeID <- E.Auxiliary.rawValue, name <- E.Auxiliary.name))
        try db.run(table.insert(exerciseTypeID <- E.Basic.rawValue, name <- E.Basic.name))
        try db.run(table.insert(exerciseTypeID <- E.Specialized.rawValue, name <- E.Specialized.name))
    }
}
