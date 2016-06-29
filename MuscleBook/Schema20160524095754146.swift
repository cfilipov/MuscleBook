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

private typealias Prev = Schema20160410215418161

enum Schema20160524095754146: Schema {
    static var version: Int64 = 20160524095754146

    static func migrateDatabase(db: Connection) throws {
        Exercise.table = Exercise._tableTMP
        Exercise.search = Exercise._searchTMP
        Workset.table = Workset._tableTMP
        Workout.table = Workout._tableTMP

        try Activation.create(db)
        try Activation.populate(db)

        try Exercise.create(db)
        try Exercise.populate(db)
        try Workout.create(db)
        try Workset.create(db)
        try Workout.populate(db)
        try Workset.populate(db)

        try db.run(Prev.Exercise.table.drop(ifExists: true))
        try db.run(Prev.Exercise.search.drop(ifExists: true))
        try db.run(Prev.Workout.table.drop(ifExists: true))
        try db.run(Prev.Workset.table.drop(ifExists: true))

        try db.run(Exercise._tableTMP.rename(Exercise._table))
        try db.run(Exercise._searchTMP.rename(Exercise._search))
        try db.run(Workset._tableTMP.rename(Workset._table))
        try db.run(Workout._tableTMP.rename(Workout._table))

        Exercise.table = Exercise._table
        Exercise.search = Exercise._search
        Workset.table = Workset._table
        Workout.table = Workout._table
    }
}

private typealias This = Schema20160524095754146

extension Schema20160524095754146 {

    typealias Muscle = Prev.Muscle
    typealias MuscleMovementClassification = Prev.MuscleMovementClassification
    typealias MuscleMovement = Prev.MuscleMovement

    enum ExerciseReference {
        static let exerciseID = Expression<Int64?>("exercise_id")
        static let name = Expression<String>("exercise_name")
    }

    /* Rename column `name` to `exercise_name` */

    enum Exercise {
        static var table = _table
        static let _table = Table("exercise")
        static let _tableTMP = Table("exercise_tmp")

        static var search = _search
        static let _search = VirtualTable("exercise_search")
        static let _searchTMP = VirtualTable("exercise_search_tmp")

        static let exerciseID = Expression<Int64>("exercise_id")
        static let name = Expression<String>("exercise_name")
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

    /* `workset` table (added & removed columns) */

    enum Workset {
        static var table = _table
        static let _table = Table("workset")
        static let _tableTMP = Table("workset_tmp")

        static let worksetID = Expression<Int64>("workset_id")
        static let workoutID = Expression<Int64>("workout_id")

        /* Input */

        static let exerciseID = Expression<Int64?>("exercise_id")
        static let exerciseName = Expression<String>("exercise_name")
        static let startTime = Expression<NSDate>("start_time")
        static let duration = Expression<Double>("duration")
        static let failure = Expression<Bool>("failure")
        static let warmup = Expression<Bool>("warmup")
        static let reps = Expression<Int?>("reps")
        static let weight = Expression<Double?>("weight")

        /* Calculations */

        static let volume = Expression<Double?>("volume")
        static let e1RM = Expression<Double?>("e1rm")
        static let percentMaxVolume = Expression<Double?>("percent_max_volume")
        static let percentMaxDuration = Expression<Double?>("percent_max_duration")
        static let intensity = Expression<Double?>("intensity")
        static let activation = Expression<MuscleBook.ActivationLevel>("activation_id")
    }

    /* `workout` table replaces `workout` view */

    enum Workout {
        static var table = _table
        static let _table = Table("workout")
        static let _tableTMP = Table("workout_tmp")
        static let workoutID = Expression<Int64>("workout_id")
        static let startTime = Expression<NSDate>("start_time")
        static let sets = Expression<Int>("sets")
        static let reps = Expression<Int>("reps")
        static let duration = Expression<Double>("duration")
        static let restDuration = Expression<Double>("rest_duration")
        static let activeDuration = Expression<Double>("active_duration")
        static let volume = Expression<Double?>("volume")
        static let avePercentMaxVolume = Expression<Double?>("ave_percent_max_volume")
        static let avePercentMaxDuration = Expression<Double>("ave_percent_max_duration")
        static let aveIntensity = Expression<Double?>("ave_intensity")
        static let maxDuration = Expression<Double>("max_duration")
        static let maxActivation = Expression<MuscleBook.ActivationLevel>("max_activation")
    }

    /* new table: `activation` */

    enum Activation {
        static let table = Table("activation")
        static let activationID = Expression<Int64>("activation_id")
        static let name = Expression<String>("name")
    }

}

// MARK:

private extension This.Activation {
    static func create(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(activationID, primaryKey: true)
                t.column(name)
            }
        )
    }

    static func populate(db: Connection) throws {
        for c in ActivationLevel.all {
            try db.run(
                table.insert(
                    or: .Replace,
                    activationID <- c.rawValue,
                    name <- c.name
                )
            )
        }
    }
}

private extension This.Workset {
    static func create(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(worksetID, primaryKey: .Autoincrement)
                t.column(exerciseID, references:
                    Table("exercise"),
                    Expression<Int64>("exercise_id")
                )
                t.column(workoutID, references:
                    Table("workout"),
                    Expression<Int64>("workout_id")
                )
                t.column(exerciseName)
                t.column(startTime)
                t.column(duration)
                t.column(failure)
                t.column(warmup)
                t.column(reps)
                t.column(weight)
                t.column(volume)
                t.column(e1RM)
                t.column(percentMaxVolume)
                t.column(percentMaxDuration)
                t.column(intensity)
                t.column(activation)
            }
        )
        try db.run(
            table.createIndex(
                [exerciseID, workoutID, startTime],
                ifNotExists: true
            )
        )
    }

    static func populate(db: Connection) throws {
        typealias PW = Prev.Workset
        for workset in try db.prepare(PW.table) {
            let date = workset[PW.date]
            let r = Double(workset[PW.reps] ?? 0)
            let start = date.dateByAddingTimeInterval(-r)
            let d = workset[PW.duration] ?? r
            try db.run(
                table.insert(
                    exerciseName <- workset[PW.exerciseName],
                    exerciseID <- workset[PW.exerciseID],
                    workoutID <- workset[PW.workoutID],
                    startTime <- start,
                    reps <- workset[PW.reps],
                    weight <- workset[PW.weight],
                    percentMaxDuration <- 0,
                    duration <- d,
                    failure <- false,
                    warmup <- false,
                    activation <- MuscleBook.ActivationLevel.None
                )
            )
        }
    }

}

private extension This.Workout {
    static func create(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(workoutID, primaryKey: .Autoincrement)
                t.column(startTime)
                t.column(sets)
                t.column(reps)
                t.column(duration)
                t.column(restDuration)
                t.column(activeDuration)
                t.column(volume)
                t.column(avePercentMaxVolume)
                t.column(avePercentMaxDuration)
                t.column(aveIntensity)
                t.column(maxDuration)
                t.column(maxActivation)
            }
        )
        try db.run(
            table.createIndex(
                [startTime],
                ifNotExists: true
            )
        )
    }

    static func populate(db: Connection) throws {
        typealias PW = Prev.Workout
        for workset in try db.prepare(PW.table) {
            try db.run(
                table.insert(
                    workoutID <- workset[PW.workoutID],
                    startTime <- workset[PW.date],
                    sets <- 0,
                    reps <- 0,
                    duration <- 0,
                    restDuration <- 0,
                    activeDuration <- 0,
                    avePercentMaxDuration <- 0,
                    maxDuration <- 0,
                    maxActivation <- MuscleBook.ActivationLevel.None
                )
            )
        }
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

    static func populate(db: Connection) throws {
        typealias PE = Prev.Exercise
        for ex in try db.prepare(PE.table) {
            let rowid = try db.run(
                table.insert(
                    exerciseID <- ex[PE.exerciseID],
                    name <- ex[PE.name],
                    equipment <- ex.get(PE.equipment),
                    gif <- ex[PE.gif],
                    force <- ex[PE.force],
                    level <- ex[PE.level],
                    mechanics <- ex[PE.mechanics],
                    type <- ex[PE.type],
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
    }

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
