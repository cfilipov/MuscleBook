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
        try Activation.create(db)
        try Activation.populate(db)
        try Workout.create(db)
        try db.run(Prev.Workout.table.drop(ifExists: true))
        try db.run(Workset.table.rename(Prev.Workset.table))
        try Workout.populate(db)
        try Workset.populate(db)
        try db.run(Prev.Workset.table.drop(ifExists: true))
    }
}

private typealias This = Schema20160524095754146

extension Schema20160524095754146 {

    typealias Muscle = Prev.Muscle
    typealias MuscleMovementClassification = Prev.MuscleMovementClassification
    typealias MuscleMovement = Prev.MuscleMovement
    typealias Exercise = Prev.Exercise

    /* `workset` table (added & removed columns) */

    enum Workset {
        static let table = Table("workset")
        static let worksetID = Expression<Int64>("workset_id")
        static let workoutID = Expression<Int64>("workout_id")
        static let exerciseID = Expression<Int64?>("exercise_id")
        static let exerciseName = Expression<String>("exercise_name")
        static let startTime = Expression<NSDate>("start_time")
        static let duration = Expression<Double>("duration")
        static let failure = Expression<Bool>("failure")
        static let warmup = Expression<Bool>("warmup")
        static let reps = Expression<Int?>("reps")
        static let weight = Expression<Double?>("weight")
        static let volume = Expression<Double?>("volume")
        static let e1RM = Expression<Double?>("e1rm")
        static let relativeRM = Expression<Double?>("relative_rm")
        static let relative1RM = Expression<Double?>("relative_1rm")
        static let relativeE1RM = Expression<Double?>("relative_e1rm")
        static let relativexRM = Expression<Double?>("relative_xrm")
        static let relativeVolume = Expression<Double?>("relative_volume")
        static let relativeDuration = Expression<Double>("relative_duration")
        static let relativeIntensity = Expression<Double?>("relative_intensity")
        static let activation = Expression<MuscleBook.Activation>("activation_id")
    }

    /* `workout` table replaces `workout` view */

    enum Workout {
        static let table = Table("workout")
        static let workoutID = Expression<Int64>("workout_id")
        static let startTime = Expression<NSDate>("start_time")
        static let sets = Expression<Int>("sets")
        static let reps = Expression<Int>("reps")
        static let duration = Expression<Double>("duration")
        static let restDuration = Expression<Double>("rest_duration")
        static let activeDuration = Expression<Double>("active_duration")
        static let volume = Expression<Double?>("volume")
        static let aveRelativeVolume = Expression<Double?>("ave_relative_volume")
        static let aveRelativeDuration = Expression<Double>("ave_relative_duration")
        static let aveRelativeIntensity = Expression<Double?>("ave_relative_intensity")
        static let maxDuration = Expression<Double>("max_duration")
        static let maxActivation = Expression<MuscleBook.Activation>("max_activation")
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
        for c in Activation.all {
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
                t.column(relativeRM)
                t.column(relative1RM)
                t.column(relativeE1RM)
                t.column(relativexRM)
                t.column(relativeVolume)
                t.column(relativeDuration)
                t.column(relativeIntensity)
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
        for workset in try db.prepare(Prev.Workset.table) {
            try db.run(
                table.insert(
                    exerciseName <- workset[Prev.Workset.exerciseName],
                    exerciseID <- workset[Prev.Workset.exerciseID],
                    workoutID <- workset[Prev.Workset.workoutID],
                    startTime <- workset[Prev.Workset.date],
                    reps <- workset[Prev.Workset.reps],
                    weight <- workset[Prev.Workset.weight],
                    relativeDuration <- 0,
                    duration <- Double(workset[Prev.Workset.reps] ?? 0),
                    failure <- false,
                    warmup <- false,
                    activation <- MuscleBook.Activation.None
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
                t.column(aveRelativeVolume)
                t.column(aveRelativeDuration)
                t.column(aveRelativeIntensity)
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
        for workset in try db.prepare(Prev.Workset.table) {
            try db.run(
                table.insert(
                    workoutID <- workset[Prev.Workset.workoutID],
                    startTime <- workset[Prev.Workset.date],
                    sets <- 0,
                    reps <- 0,
                    duration <- 0,
                    restDuration <- 0,
                    activeDuration <- 0,
                    aveRelativeDuration <- 0,
                    maxDuration <- 0,
                    maxActivation <- MuscleBook.Activation.None
                )
            )
        }
    }

}
