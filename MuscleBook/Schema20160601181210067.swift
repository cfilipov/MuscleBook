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

private typealias Prev = Schema20160524095754146

enum Schema20160601181210067: Schema {
    static var version: Int64 = 20160601181210067

    static func migrateDatabase(db: Connection) throws {
        Exercise.table = Exercise._tableTMP
        Exercise.search = Exercise._searchTMP
        Workset.table = Workset._tableTMP
        Workout.table = Workout._tableTMP

        try InputOptions.create(db)
        try InputOptions.populate(db)

        try Equipment.create(db)
        try Equipment.populate(db)

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

private typealias This = Schema20160601181210067

extension Schema20160601181210067 {

    typealias Muscle = Prev.Muscle
    typealias MuscleMovementClassification = Prev.MuscleMovementClassification
    typealias MuscleMovement = Prev.MuscleMovement
    typealias ExerciseReference = Prev.ExerciseReference
    typealias Activation = Prev.Activation

    /* Add column `input_type` and replace `equipment` column type */

    enum Exercise {
        static var table = _table
        static let _table = Table("exercise")
        static let _tableTMP = Table("exercise_tmp")

        static var search = _search
        static let _search = VirtualTable("exercise_search")
        static let _searchTMP = VirtualTable("exercise_search_tmp")

        static let exerciseID = Expression<Int64>("exercise_id")
        static let inputOptions = Expression<MuscleBook.InputOptions>("input_options_id") // New
        static let name = Expression<String>("exercise_name")
        static let equipmentID = Expression<MuscleBook.Exercise.Equipment>("equipment_id") // Changed type
        static let gif = Expression<String?>("gif")
        static let force = Expression<String?>("force")
        static let level = Expression<String?>("level")
        static let mechanics = Expression<String?>("mechanics")
        static let type = Expression<String>("type")
        static let instructions = Expression<ArrayBox<String>?>("instructions")
        static let link = Expression<String>("link")
        static let source = Expression<String?>("source")
    }

    /* New table */

    enum InputOptions {
        static let table = Table("input_options")
        static let inputOptionsID = Expression<Int64>("input_options_id")
        static let name = Expression<String>("name")
    }

    /* New table */

    enum Equipment {
        static let table = Table("equipment")
        static let equipmentID = Expression<Int64>("equipment_id")
        static let name = Expression<String>("name")
    }

    /* `workset` table (added & changed columns) */

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
        static let duration = Expression<Double?>("duration") // Now optional
        static let failure = Expression<Bool>("failure")
        static let warmup = Expression<Bool>("warmup")
        static let reps = Expression<Int?>("reps")
        static let weight = Expression<Double?>("weight")
        static let bodyweight = Expression<Double?>("bodyweight") // New
        static let assistanceWeight = Expression<Double?>("assistance_weight") // New

        /* Calculations */

        static let volume = Expression<Double?>("volume")
        static let e1RM = Expression<Double?>("e1rm")
        static let wilks = Expression<Double?>("wilks")
        static let percentMaxVolume = Expression<Double?>("percent_max_volume")
        static let percentMaxDuration = Expression<Double?>("percent_max_duration")
        static let intensity = Expression<Double?>("intensity")
        static let activation = Expression<MuscleBook.Activation>("activation_id")
    }

    /* Rename column, change colume types */

    enum Workout {
        static var table = _table
        static let _table = Table("workout")
        static let _tableTMP = Table("workout_tmp")
        static let workoutID = Expression<Int64>("workout_id")
        static let startTime = Expression<NSDate>("start_time")
        static let sets = Expression<Int>("sets")
        static let reps = Expression<Int>("reps")
        static let duration = Expression<Double?>("duration") // Now nullable
        static let restDuration = Expression<Double?>("rest_duration") // Now nullable
        static let activeDuration = Expression<Double?>("active_duration") // Now nullable
        static let volume = Expression<Double?>("volume")
        static let avePercentMaxVolume = Expression<Double?>("ave_percent_max_volume")
        static let avePercentMaxDuration = Expression<Double?>("ave_percent_max_duration") // Now nullable
        static let aveIntensity = Expression<Double?>("ave_intensity")
        static let maxDuration = Expression<Double?>("max_duration") // Now nullable
        static let activation = Expression<MuscleBook.Activation>("activation") // Renamed
    }
}

// MARK:

extension This.Exercise {
    static func create(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                /* Column Constraints */
                t.column(exerciseID, primaryKey: .Autoincrement)
                t.column(name)
                t.column(inputOptions)
                t.column(equipmentID)
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
            let e = MuscleBook.Exercise.Equipment(name: ex.get(PE.equipment).array[0])!
            var input: InputOptions = []
            switch e {
            case .Lever: input.insert(.DefaultOptions)
            case .LeverPlateLaded: input.insert(.DefaultOptions)
            case .LeverSelectorized: input.insert(.DefaultOptions)
            case .Weighted: input.insert([.BodyWeight, .Reps, .Duration, .Weight])
            case .Barbell: input.insert(.DefaultOptions)
            case .Dumbbell: input.insert(.DefaultOptions)
            case .Sled: input.insert(.DefaultOptions)
            case .Smith: input.insert(.DefaultOptions)
            case .Suspended: input.insert([.BodyWeight, .Reps, .Duration])
            case .Assisted: input.insert([.BodyWeight, .Reps, .Duration, .AssistanceWeight])
            case .SelfAssisted: input.insert([.BodyWeight, .Reps, .Duration])
            case .AssistedMachine: input.insert([.Reps, .Weight, .Duration, .AssistanceWeight])
            case .AssistedPartner: input.insert([.BodyWeight, .Reps, .Duration])
            case .Suspension: input.insert([.BodyWeight, .Reps, .Duration])
            case .Cable: input.insert(.DefaultOptions)
            case .BodyWeight: input.insert([.BodyWeight, .Reps, .Duration])
            }
            let rowid = try db.run(
                table.insert(
                    exerciseID <- ex[PE.exerciseID],
                    name <- ex[PE.name],
                    equipmentID <- e,
                    inputOptions <- input,
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

}

extension This.InputOptions {
    static func create(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(inputOptionsID, primaryKey: true)
                t.column(name)
            }
        )
    }

    static func populate(db: Connection) throws {
        typealias I = MuscleBook.InputOptions
        try db.run(table.insert(inputOptionsID <- I.Reps.rawValue, name <- "Reps"))
        try db.run(table.insert(inputOptionsID <- I.Weight.rawValue, name <- "Weight"))
        try db.run(table.insert(inputOptionsID <- I.BodyWeight.rawValue, name <- "Body Weight"))
        try db.run(table.insert(inputOptionsID <- I.Duration.rawValue, name <- "Duration"))
        try db.run(table.insert(inputOptionsID <- I.AssistanceWeight.rawValue, name <- "Assistance Weight"))
    }
}

extension This.Equipment {
    static func create(db: Connection) throws {
        try db.run(
            table.create(ifNotExists: true) { t in
                t.column(equipmentID, primaryKey: true)
                t.column(name)
            }
        )
    }

    static func populate(db: Connection) throws {
        typealias E = MuscleBook.Exercise.Equipment
        try db.run(table.insert(equipmentID <- E.Cable.rawValue, name <- "Cable"))
        try db.run(table.insert(equipmentID <- E.LeverPlateLaded.rawValue, name <- "Lever (plate loaded)"))
        try db.run(table.insert(equipmentID <- E.LeverSelectorized.rawValue, name <- "Lever (selectorized)"))
        try db.run(table.insert(equipmentID <- E.Weighted.rawValue, name <- "Weighted"))
        try db.run(table.insert(equipmentID <- E.BodyWeight.rawValue, name <- "Body Weight"))
        try db.run(table.insert(equipmentID <- E.Barbell.rawValue, name <- "Barbell"))
        try db.run(table.insert(equipmentID <- E.Dumbbell.rawValue, name <- "Dumbbell"))
        try db.run(table.insert(equipmentID <- E.Sled.rawValue, name <- "Sled"))
        try db.run(table.insert(equipmentID <- E.Smith.rawValue, name <- "Smith"))
        try db.run(table.insert(equipmentID <- E.Suspended.rawValue, name <- "Suspended"))
        try db.run(table.insert(equipmentID <- E.Assisted.rawValue, name <- "Assisted"))
        try db.run(table.insert(equipmentID <- E.SelfAssisted.rawValue, name <- "Self-assisted"))
        try db.run(table.insert(equipmentID <- E.AssistedMachine.rawValue, name <- "Assisted (machine)"))
        try db.run(table.insert(equipmentID <- E.AssistedPartner.rawValue, name <- "Assisted (partner)"))
        try db.run(table.insert(equipmentID <- E.Suspension.rawValue, name <- "Suspension"))
        try db.run(table.insert(equipmentID <- E.Lever.rawValue, name <- "Lever"))
    }
}

extension This.Workset {
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
                t.column(bodyweight)
                t.column(assistanceWeight)
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
            try db.run(
                table.insert(
                    exerciseName <- workset[PW.exerciseName],
                    exerciseID <- workset[PW.exerciseID],
                    workoutID <- workset[PW.workoutID],
                    startTime <- workset[PW.startTime],
                    reps <- workset[PW.reps],
                    weight <- workset[PW.weight],
                    bodyweight <- nil,
                    percentMaxDuration <- workset[PW.percentMaxDuration],
                    duration <- workset[PW.duration],
                    failure <- workset[PW.failure],
                    warmup <- workset[PW.warmup],
                    activation <- workset.get(PW.activation)
                )
            )
        }
    }
}

extension This.Workout {
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
                t.column(activation)
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
                    startTime <- workset[PW.startTime],
                    sets <- workset[PW.sets],
                    reps <- workset[PW.reps],
                    duration <- workset[PW.duration],
                    restDuration <- workset[PW.restDuration],
                    activeDuration <- workset[PW.activeDuration],
                    avePercentMaxDuration <- workset[PW.avePercentMaxDuration],
                    maxDuration <- workset[PW.maxDuration],
                    activation <- workset.get(PW.maxActivation)
                )
            )
        }
    }

}
