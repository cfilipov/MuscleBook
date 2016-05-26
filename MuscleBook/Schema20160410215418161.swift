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

enum Schema20160410215418161: Schema {
    static var version: Int64 = 20160410215418161

    static func migrateDatabase(db: Connection) throws {
        try Workset.create(db)
        try Workout.create(db)
        try Muscle.create(db)
        try Muscle.populate(db)
        try MuscleMovementClassification.create(db)
        try MuscleMovementClassification.populate(db)
        try MuscleMovement.create(db)
        try Exercise.create(db)
    }
}

private typealias This = Schema20160410215418161

extension This {

    enum Muscle {
        static let table = Table("muscle")
        static let search = VirtualTable("muscle_search")
        static let muscleID = Expression<Int64>("muscle_id")
        static let name = Expression<String>("name")
        static let fmaID = Expression<String?>("fma_id")
        static let synonyms = Expression<ArrayBox<String>>("synonyms")
        static let isMuscleGroup = Expression<Bool>("is_muscle_group")
    }

    enum MuscleMovementClassification {
        static let table = Table("muscle_movement_classification")
        static let muscleMovementClassID = Expression<Int64>("muscle_movement_class_id")
        static let name = Expression<String>("name")
    }

    enum MuscleMovement {
        typealias Classification = MuscleBook.MuscleMovement.Classification
        static let table = Table("muscle_movement")
        static let muscleMovementID = Expression<Int64>("muscle_movement_id")
        static let exerciseID = Expression<Int64>("exercise_id")
        static let muscleMovementClassID = Expression<Classification>("muscle_movement_class_id")
        static let muscleName = Expression<String>("muscle_name")
        static let muscleID = Expression<MuscleBook.Muscle?>("muscle_id")
    }

    enum Exercise {
        static let table = Table("exercise")
        static let search = VirtualTable("exercise_search")
        static let exerciseID = Expression<Int64>("exercise_id")
        static let name = Expression<String>("name")
        static let equipment = Expression<ArrayBox<String>>("equipment")
        static let gif = Expression<String?>("gif")
        static let force = Expression<String?>("force")
        static let level = Expression<String?>("level")
        static let mechanics = Expression<String?>("mechanics")
        static let type = Expression<String>("type")
        static let instructions = Expression<ArrayBox<String>?>("instructions")
        static let link = Expression<String>("link")
        static let source = Expression<String?>("source")
    }

    enum Workset {
        static let table = Table("workset")
        static let worksetID = Expression<Int64>("workset_id")
        static let exerciseID = Expression<Int64?>("exercise_id")
        static let workoutID = Expression<Int64>("workout_id")
        static let exerciseName = Expression<String>("exercise_name")
        static let date = Expression<NSDate>("date")
        static let reps = Expression<Int>("reps")
        static let weight = Expression<Double?>("weight")
        static let duration = Expression<Double?>("duration")
        static let e1RM = Expression<Double?>("e1rm")
        static let maxE1RM = Expression<Double?>("max_e1rm")
        static let maxDuration = Expression<Double?>("max_duration")
    }

    enum Workout {
        static let table = View("workout")
        static let workset = Table("workset")
        static let reps = Expression<Int>("reps")
        static let date = Expression<NSDate>("date")
        static let workoutID = Expression<Int64>("workout_id")
        static let weight = Expression<Double?>("weight")
        static let duration = Expression<Double?>("duration")
        static let e1RM = Expression<Double?>("e1rm")
    }
}

// MARK:

extension This.Exercise {

    static func find(exactName name: String) -> QueryType {
        return search
            .select(exerciseID, self.name)
            .filter(self.name == name)
    }

    static func match(name name: String) -> QueryType {
        return search
            .select(exerciseID, self.name)
            .match("*"+name+"*")
    }
}

extension This.Muscle {
    static func find(name: String) -> QueryType {
        return search.select(muscleID).match("*"+name+"*")
    }
}

extension This.MuscleMovement {
    static func find(exerciseID exerciseID: Int64) -> QueryType {
        return table.filter(self.exerciseID == exerciseID)
    }
}

// MARK:

private extension This.Workset {
    static func create(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(worksetID, primaryKey: .Autoincrement)
                t.column(exerciseID, references:
                    This.Exercise.table,
                    This.Exercise.exerciseID
                )
                t.column(workoutID)
                t.column(exerciseName)
                t.column(date)
                t.column(reps)
                t.column(weight)
                t.column(duration)
                t.column(e1RM)
                t.column(maxE1RM)
                t.column(maxDuration)
            }
        )
        try db.run(
            table.createIndex(
                [exerciseID, workoutID, date],
                ifNotExists: true
            )
        )
    }
}

private extension This.Workout {
    static func create(db: Connection) throws {
        try db.run(
            table.create(This.Workout.table
                .select(
                    workoutID.asName("workout_id"),
                    date.asName("date"),
                    date.count.asName("sets"),
                    reps.sum.asName("reps"),
                    (Expression<Double>("reps") * weight).sum.asName("weight"),
                    duration.sum.asName("duration"),
                    e1RM.max.asName("e1rm_max")
                )
                .group(workoutID)
            )
        )
    }
}

private extension This.Muscle {
    static func create(db: Connection) throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(muscleID, primaryKey: true)
            t.column(name)
            t.column(fmaID)
            t.column(synonyms)
            t.column(isMuscleGroup)
            }
        )
        try db.run(
            search.create(
                .FTS4([muscleID, name, fmaID, synonyms], tokenize: .Porter)
            )
        )
    }

    static func populate(db: Connection) throws {
        /* 
         TODO: Bulk insert rows into FTS using raw SQL

            INSERT INTO muscle_search SELECT identifier, name, fma_id, synonyms FROM muscle;

         TODO: Use external content table instead of duplcating data http://www.sqlite.org/fts3.html#section_6_2_2
         */
        for muscle in Muscle.allMuscles {
            try db.run(
                table.insert(
                    or: .Replace,
                    muscleID <- muscle.rawValue,
                    name <- muscle.name,
                    fmaID <- muscle.fmaID,
                    synonyms <- ArrayBox(array: muscle.synonyms),
                    isMuscleGroup <- muscle.isMuscleGroup
                )
            )
            try db.run(
                search.insert(
                    or: .Replace,
                    muscleID <- muscle.rawValue,
                    name <- muscle.name,
                    fmaID <- muscle.fmaID,
                    synonyms <- ArrayBox(array: muscle.synonyms)
                )
            )
        }
    }
}

private extension This.MuscleMovementClassification {
    static func create(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(muscleMovementClassID, primaryKey: true)
                t.column(name)
            }
        )
    }

    static func populate(db: Connection) throws {
        for c in MuscleMovement.Classification.all {
            try db.run(
                table.insert(
                    or: .Replace,
                    muscleMovementClassID <- c.rawValue,
                    name <- c.name
                )
            )
        }
    }
}

private extension This.MuscleMovement {
    static func create(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(muscleMovementID, primaryKey: .Autoincrement)
                t.column(exerciseID, references:
                    This.Exercise.table,
                    This.Exercise.exerciseID
                )
                t.column(muscleMovementClassID)
                t.column(muscleName)
                t.column(muscleID)
            }
        )
        try db.run(
            table.createIndex([exerciseID], ifNotExists: true)
        )
    }
}

private extension This.Exercise {
    static func create(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                /* Column Constraints */
                t.column(exerciseID, primaryKey: .Autoincrement)
                t.column(name)
                t.column(equipment)
                t.column(gif)
                t.column(force)
                t.column(level)
                t.column(mechanics)
                t.column(type)
                t.column(instructions)
                t.column(link)
                t.column(source)
            }
        )
        try db.run(
            search.create(.FTS4([exerciseID, name], tokenize: .Porter))
        )
    }
}
