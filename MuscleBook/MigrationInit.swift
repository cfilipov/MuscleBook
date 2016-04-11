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
import SQLiteMigrationManager
import SQLite

struct MigrationInit: Migration {
    var version: Int64 = 20160410215418161

    func migrateDatabase(db: Connection) throws {
        try createWorksetTable(db)
        try createWorkoutView(db)
        try createMuscleTable(db)
        try createMuscleMovementClassificationTable(db)
        try createMuscleMovementTable(db)
        try createExerciseTable(db)
    }

    func createMuscleTable(db: Connection) throws {
        let tMuscle = Table("muscle")
        let tSearch = VirtualTable("muscle_search")
        let cMuscleID = Expression<Int64>("muscle_id")
        let cName = Expression<String>("name")
        let cFmaID = Expression<String?>("fma_id")
        let cSynonyms = Expression<ArrayBox<String>>("synonyms")
        let cIsMuscleGroup = Expression<Bool>("is_muscle_group")
        try db.run(tMuscle.create(ifNotExists: true) { t in
            t.column(cMuscleID, primaryKey: true)
            t.column(cName)
            t.column(cFmaID)
            t.column(cSynonyms)
            t.column(cIsMuscleGroup)
            }
        )
        try db.run(tSearch.create(.FTS4([cMuscleID, cName, cFmaID, cSynonyms], tokenize: .Porter)))
        /* TODO: Bulk insert rows into FTS using raw SQL
         INSERT INTO muscle_search SELECT identifier, name, fma_id, synonyms FROM muscle;
         */
        /* TODO: Use external content table instead of duplcating data http://www.sqlite.org/fts3.html#section_6_2_2 */
        for muscle in Muscle.allMuscles {
            try db.run(
                tMuscle.insert(
                    or: .Replace,
                    cMuscleID <- muscle.rawValue,
                    cName <- muscle.name,
                    cFmaID <- muscle.fmaID,
                    cSynonyms <- ArrayBox(array: muscle.synonyms),
                    cIsMuscleGroup <- muscle.isMuscleGroup
                )
            )
            try db.run(
                tSearch.insert(
                    or: .Replace,
                    cMuscleID <- muscle.rawValue,
                    cName <- muscle.name,
                    cFmaID <- muscle.fmaID,
                    cSynonyms <- ArrayBox(array: muscle.synonyms)
                )
            )
        }
    }

    func createMuscleMovementClassificationTable(db: Connection) throws {
        let tMuscleMovementClassification = Table("muscle_movement_classification")
        let cMuscleMovementClassID = Expression<Int64>("muscle_movement_class_id")
        let cName = Expression<String>("name")
        try db.run(
            tMuscleMovementClassification.create(ifNotExists: true) { t in
                t.column(cMuscleMovementClassID, primaryKey: true)
                t.column(cName)
            }
        )
        for c in MuscleMovement.Classification.all {
            try db.run(
                tMuscleMovementClassification.insert(
                    or: .Replace,
                    cMuscleMovementClassID <- c.rawValue,
                    cName <- c.name
                )
            )
        }
    }

    func createMuscleMovementTable(db: Connection) throws {
        let tMuscleMovement = Table("muscle_movement")
        let cMuscleMovementID = Expression<Int64>("muscle_movement_id")
        let cExerciseID = Expression<Int64>("exercise_id")
        let cMuscleMovementClassID = Expression<MuscleMovement.Classification>("muscle_movement_class_id")
        let cMuscleName = Expression<String>("muscle_name")
        let cMuscleID = Expression<Muscle?>("muscle_id")

        let tExercise = Table("exercise")
        let cExerciseExerciseID = Expression<Int64>("exercise_id")

        try db.run(
            tMuscleMovement.create(ifNotExists: true) { t in
                t.column(cMuscleMovementID, primaryKey: .Autoincrement)
                t.column(cExerciseID, references:
                    tExercise,
                    cExerciseExerciseID
                )
                t.column(cMuscleMovementClassID)
                t.column(cMuscleName)
                t.column(cMuscleID)
            }
        )
        try db.run(
            tMuscleMovement.createIndex([cExerciseID], ifNotExists: true)
        )
    }

    func createExerciseTable(db: Connection) throws {
        let tExercise = Table("exercise")
        let tSearch = VirtualTable("exercise_search")
        let cExerciseID = Expression<Int64>("exercise_id")
        let cName = Expression<String>("name")
        let cEquipment = Expression<ArrayBox<String>>("equipment")
        let cGif = Expression<String?>("gif")
        let cForce = Expression<String?>("force")
        let cLevel = Expression<String?>("level")
        let cMechanics = Expression<String?>("mechanics")
        let cType = Expression<String>("type")
        let cInstructions = Expression<ArrayBox<String>?>("instructions")
        let cLink = Expression<String>("link")
        let cSource = Expression<String?>("source")

        try db.run(
            tExercise.create(ifNotExists: true) { t in
                /* Column Constraints */
                t.column(cExerciseID, primaryKey: .Autoincrement)
                t.column(cName)
                t.column(cEquipment)
                t.column(cGif)
                t.column(cForce)
                t.column(cLevel)
                t.column(cMechanics)
                t.column(cType)
                t.column(cInstructions)
                t.column(cLink)
                t.column(cSource)
            }
        )
        try db.run(
            tSearch.create(.FTS4([cExerciseID, cName], tokenize: .Porter))
        )
    }

    func createWorksetTable(db: Connection) throws {
        let tWorkset = Table("workset")
        let cWorksetID = Expression<Int64>("workset_id")
        let cExerciseID = Expression<Int64?>("exercise_id")
        let cWorkoutID = Expression<Int64>("workout_id")
        let cExerciseName = Expression<String>("exercise_name")
        let cDate = Expression<NSDate>("date")
        let cReps = Expression<Int>("reps")
        let cWeight = Expression<Double?>("weight")
        let cDuration = Expression<Double?>("duration")
        let cE1RM = Expression<Double?>("e1rm")
        let cMaxE1RM = Expression<Double?>("max_e1rm")
        let cMaxDuration = Expression<Double?>("max_duration")

        let tExercise = Table("exercise")
        let cExerciseExerciseID = Expression<Int64>("exercise_id")

        try db.run(
            tWorkset.create(ifNotExists: true) { t in
                t.column(cWorksetID, primaryKey: .Autoincrement)
                t.column(cExerciseID, references:
                    tExercise,
                    cExerciseExerciseID
                )
                t.column(cWorkoutID)
                t.column(cExerciseName)
                t.column(cDate)
                t.column(cReps)
                t.column(cWeight)
                t.column(cDuration)
                t.column(cE1RM)
                t.column(cMaxE1RM)
                t.column(cMaxDuration)
            }
        )
        try db.run(
            tWorkset.createIndex(
                [cExerciseID, cWorkoutID, cDate],
                ifNotExists: true
            )
        )
    }

    func createWorkoutView(db: Connection) throws {
        let vWorkout = View("workout")
        let tWorkset = Table("workset")
        let cReps = Expression<Double>("reps")
        let cDate = Expression<NSDate>("date")
        let cWorkoutID = Expression<Int64>("workout_id")
        let cWeight = Expression<Double?>("weight")
        let cDuration = Expression<Double?>("duration")
        let cE1RM = Expression<Double?>("e1rm")
        try db.run(
            vWorkout.create(tWorkset
                .select(
                    cWorkoutID.asName("workout_id"),
                    cDate.asName("date"),
                    cDate.count.asName("sets"),
                    cReps.sum.asName("reps"),
                    (cReps * cWeight).sum.asName("weight"),
                    cDuration.sum.asName("duration"),
                    cE1RM.max.asName("e1rm_max")
                )
                .group(cWorkoutID)
            )
        )
    }
}
