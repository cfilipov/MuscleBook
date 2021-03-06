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

protocol SQLAdaptable {
    init(row: Row)
    var setters: [Setter] { get }
}

// MARK:

extension MuscleWorkSummary: SQLAdaptable {
    typealias W = Workset.Schema
    typealias M = MuscleMovement.Schema

    init(row: Row) {
        muscle = row.get(M.muscleID)!
        exercise = ExerciseReference(row: row)
        movementClass = row.get(M.muscleMovementClassID)
        activation = row.get(W.activation.max)!
        volume = row[W.volume.sum]
        weight = row[W.weight.max]
    }

    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Exercise: SQLAdaptable {
    typealias Schema = CurrentSchema.Exercise

    init(row: Row) {
        exerciseID = row[Schema.exerciseID]
        name = row[Schema.name]
        equipment = row.get(Schema.equipment)
        inputOptions = row.get(Schema.inputOptions)
        gif = row[Schema.gif]
        force = row.get(Schema.force)
        skillLevel = row.get(Schema.skillLevel)
        muscles = nil
        mechanics = row.get(Schema.mechanics)
        exerciseType = row.get(Schema.exerciseType)
        instructions = row.get(Schema.instructions)?.array
        link = row[Schema.link]
        source = row[Schema.source]
    }

    var setters: [Setter] {
        return [
            Schema.exerciseID <- self.exerciseID,
            Schema.name <- self.name,
            Schema.equipment <- self.equipment,
            Schema.inputOptions <- self.inputOptions,
            Schema.gif <- self.gif,
            Schema.force <- self.force,
            Schema.skillLevel <- self.skillLevel,
            Schema.mechanics <- self.mechanics,
            Schema.exerciseType <- self.exerciseType,
            Schema.instructions <- ArrayBox(array: self.instructions ?? []),
            Schema.link <- self.link,
            Schema.source <- self.source
        ]
    }
}

extension ExerciseReference: SQLAdaptable {
    typealias Schema = CurrentSchema.ExerciseReference

    init(row: Row) {
        exerciseID = row[Schema.exerciseID]
        name = row[Schema.name]
        count = 0
    }

    var setters: [Setter] {
        return [
            Schema.exerciseID <- self.exerciseID,
            Schema.name <- self.name
        ]
    }
}

extension Muscle: SQLAdaptable {
    typealias Schema = CurrentSchema.Muscle

    init(row: Row) {
        self = Muscle(rawValue: row[Schema.muscleID])!
    }

    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension ActivationLevel: SQLAdaptable {
    typealias Schema = CurrentSchema.Activation

    init(row: Row) {
        self = ActivationLevel(rawValue: row[Schema.activationID])!
    }

    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Exercise.InputOptions: SQLAdaptable {
    typealias Schema = CurrentSchema.InputOptions

    init(row: Row) {
        self = Exercise.InputOptions(rawValue: row[Schema.inputOptionsID])
    }

    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Exercise.Equipment {
    typealias Schema = CurrentSchema.Equipment

    init(row: Row) {
        self = Exercise.Equipment(rawValue: row[Schema.equipmentID])!
    }

    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Exercise.Force {
    typealias Schema = CurrentSchema.Force
    
    init(row: Row) {
        self = Exercise.Force(rawValue: row[Schema.forceID])!
    }
    
    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Exercise.Mechanics {
    typealias Schema = CurrentSchema.Mechanics
    
    init(row: Row) {
        self = Exercise.Mechanics(rawValue: row[Schema.mechanicsID])!
    }
    
    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Exercise.ExerciseType {
    typealias Schema = CurrentSchema.ExerciseType
    
    init(row: Row) {
        self = Exercise.ExerciseType(rawValue: row[Schema.exerciseTypeID])!
    }
    
    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Exercise.SkillLevel {
    typealias Schema = CurrentSchema.SkillLevel
    
    init(row: Row) {
        self = Exercise.SkillLevel(rawValue: row[Schema.skillLevelID])!
    }
    
    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension MuscleMovement: SQLAdaptable {
    typealias Schema = CurrentSchema.MuscleMovement

    init(row: Row) {
        muscleMovementID = row[Schema.muscleMovementID]
        exerciseID = row[Schema.exerciseID]
        classification = row.get(Schema.muscleMovementClassID)
        muscleName = row[Schema.muscleName]
        muscle = row.get(Schema.muscleID)
    }

    var setters: [Setter] {
        return [
            Schema.exerciseID <- self.exerciseID,
            Schema.muscleMovementClassID <- self.classification,
            Schema.muscleName <- self.muscleName,
            Schema.muscleID <- self.muscle
        ]
    }
}

extension MuscleMovement.Classification: SQLAdaptable {
    typealias Schema = CurrentSchema.MuscleMovementClassification

    init(row: Row) {
        self = MuscleMovement.Classification(rawValue: row[Schema.muscleMovementClassID])!
    }

    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Workout: SQLAdaptable {
    typealias Schema = CurrentSchema.Workout

    init(row: Row) {
        workoutID = row[Schema.workoutID]
        startTime = row[Schema.startTime]
        sets = row[Schema.sets]
        reps = row[Schema.reps]
        duration = row[Schema.duration]
        restDuration = row[Schema.restDuration]
        activeDuration = row[Schema.activeDuration]
        volume = row[Schema.volume]
        avePercentMaxVolume = row[Schema.avePercentMaxVolume]
        avePercentMaxDuration = row[Schema.avePercentMaxDuration]
        aveIntensity = row[Schema.aveIntensity]
        maxDuration = row[Schema.maxDuration]
        activation = row.get(Schema.activation)
    }

    var setters: [Setter] {
        return [
            Schema.startTime <- startTime,
            Schema.sets <- sets,
            Schema.reps <- reps,
            Schema.duration <- duration,
            Schema.restDuration <- restDuration,
            Schema.activeDuration <- activeDuration,
            Schema.volume <- volume,
            Schema.avePercentMaxVolume <- avePercentMaxVolume,
            Schema.avePercentMaxDuration <- avePercentMaxDuration,
            Schema.aveIntensity <- aveIntensity,
            Schema.maxDuration <- maxDuration,
            Schema.activation <- activation,
        ]
    }
}

extension Workset: SQLAdaptable {
    typealias Schema = CurrentSchema.Workset

    init(row: Row) {
        worksetID = row[Schema.worksetID]
        workoutID = row[Schema.workoutID]
        input = Workset.Input(
            exerciseID: row[Schema.exerciseID],
            exerciseName: row[Schema.exerciseName],
            startTime: row[Schema.startTime],
            duration: row[Schema.duration],
            failure: row[Schema.failure],
            warmup: row[Schema.warmup],
            reps: row[Schema.reps],
            weight: row[Schema.weight],
            bodyweight: row[Schema.bodyweight],
            assistanceWeight: row[Schema.assistanceWeight]
        )
        calculations = Workset.Calculations(
            volume: row[Schema.volume],
            e1RM: row[Schema.e1RM],
            percentMaxVolume: row[Schema.percentMaxVolume],
            percentMaxDuration: row[Schema.percentMaxDuration],
            intensity: row[Schema.intensity],
            activation: row.get(Schema.activation)
        )
    }

    var setters: [Setter] {
        return [
            Schema.workoutID <- workoutID,
            Schema.exerciseID <- input.exerciseID,
            Schema.exerciseName <- input.exerciseName,
            Schema.startTime <- input.startTime,
            Schema.duration <- input.duration,
            Schema.failure <- input.failure,
            Schema.warmup <- input.warmup,
            Schema.reps <- input.reps,
            Schema.weight <- input.weight,
            Schema.bodyweight <- input.bodyweight,
            Schema.assistanceWeight <- input.assistanceWeight,
            Schema.volume <- calculations.volume,
            Schema.e1RM <- calculations.e1RM,
            Schema.percentMaxVolume <- calculations.percentMaxVolume,
            Schema.percentMaxDuration <- calculations.percentMaxDuration,
            Schema.intensity <- calculations.intensity,
            Schema.activation <- calculations.activation
        ]
    }
}
