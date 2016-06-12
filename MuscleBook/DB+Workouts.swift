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

extension DB {

    func all(type: Workout.Type) throws -> AnySequence<Workout> {
        return try db.prepare(Workout.Schema.table.order(Workout.Schema.startTime.desc))
    }

    func count(type: Workout.Type) -> Int {
        return db.scalar(Workout.Schema.table.count)
    }

    func count(type: Workout.Type, after startTime: NSDate) -> Int {
        typealias WO = Workout.Schema
        return db.scalar(
            WO.table
                .select(WO.workoutID.count)
                .filter(WO.startTime > startTime)
        )
    }

    func count(type: Workout.Type, forDay date: NSDate) -> Int {
        return db.scalar(
            Workout.Schema.table.filter(
                Workout.Schema.startTime.localDay == date.localDay
                ).count
        )
    }

    func count(type: Workout.Type, exerciseID: Int64) -> Int {
        typealias WS = Workset.Schema
        return db.scalar(
            WS.table
                .select(WS.workoutID.distinct.count)
                .filter(WS.exerciseID == exerciseID)
        )
    }

    func countByDay(type: Workout.Type) throws -> [(NSDate, Int)] {
        let cal = NSCalendar.currentCalendar()
        let date = Workout.Schema.startTime
        let count = Workout.Schema.workoutID.count
        let rows = try db.prepare(
            Workout.Schema.table.select(date, count).group(date.localDay)
        )
        return rows.map { row in
            return (
                cal.startOfDayForDate(row[date]),
                row[count]
            )
        }
    }

    func create(type: Workout.Type, startDate: NSDate) throws -> Int64 {
        typealias WO = Workout.Schema
        return try db.run(
            WO.table.insert(
                WO.startTime <- startDate,
                WO.sets <- 0,
                WO.reps <- 0,
                WO.duration <- 0,
                WO.restDuration <- 0,
                WO.activeDuration <- 0,
                WO.avePercentMaxDuration <- 0,
                WO.maxDuration <- 0,
                WO.activation <- MuscleBook.Activation.Light
            )
        )
    }

    func endDate(workout: Workout) -> NSDate? {
        let row = db.pluck(Workset.Schema.table
            .select(Workset.Schema.startTime.max)
            .filter(Workset.Schema.workoutID == workout.workoutID)
            .limit(1)
        )
        return row?[Workset.Schema.startTime.max]
    }

    func firstWorkoutDay() -> NSDate? {
        typealias W = Workout.Schema
        return db.scalar(W.table.select(W.startTime.min))
    }

    func get(type: Workout.Type, workoutID: Int64) -> Workout? {
        return db.pluck(Workout.Schema.table.filter(Workout.Schema.workoutID == workoutID))
    }

    func getOrCreate(type: Workout.Type, input: Workset.Input) throws -> Int64 {
        typealias WS = Workset.Schema
        typealias WO = Workout.Schema
        guard let lastWorkset: Workset = db.pluck(WS.table.order(WS.startTime.desc)) else {
            return try create(Workout.self, startDate: input.startTime)
        }
        let diff = input.startTime.timeIntervalSinceDate(lastWorkset.input.startTime)
        /* TODO: Inserting new worksets into the past is not supported right now */
        guard diff > 0 else {
            throw Error.CannotInsertWorkset
        }
        if diff < 3600 {
            return lastWorkset.workoutID
        } else {
            return try create(Workout.self, startDate: input.startTime)
        }
    }

    func lastWorkoutDay() -> NSDate? {
        typealias W = Workout.Schema
        return db.scalar(W.table.select(W.startTime.max))
    }

    func nextAvailableRowID(type: Workout.Type) -> Int64 {
        typealias S = Workset.Schema
        let max = db.scalar(S.table.select(S.workoutID.max))
        return (max ?? 0) + 1
    }

    func next(workout: Workout) -> Workout? {
        let date = Workset.Schema.startTime
        return db.pluck(Workset.Schema.table
            .order(date.asc)
            .filter(date > workout.startTime)
            .limit(1)
        )
    }

    func prev(workout: Workout) -> Workout? {
        typealias W = Workset.Schema
        let date = W.startTime
        return db.pluck(W.table
            .order(date.desc)
            .filter(date < workout.startTime)
            .limit(1)
        )
    }

    func recalculate(workoutID workoutID: Int64) throws {
        typealias WS = Workset.Schema
        typealias WO = Workout.Schema
        guard let row = db.pluck(WS.table
            .select(
                WS.startTime.min,
                WS.startTime.max,
                WS.worksetID.count,
                WS.reps.sum,
                WS.volume.sum,
                WS.duration.sum,
                WS.percentMaxVolume.average,
                WS.percentMaxDuration.average,
                WS.intensity.average,
                WS.duration.max,
                WS.activation.max
            )
            .filter(
                WS.workoutID == workoutID &&
                    WS.warmup == false
            )
            ) else { throw Error.RecalculateWorkoutFailed }
        let avePcVolume = row[WS.percentMaxVolume.average]
        let aveIntensity = row[WS.intensity.average]
        let activeDuration = row[WS.duration.sum]
        guard let
            startTime = row[WS.startTime.min],
            endTime = row[WS.startTime.max]
            else { throw Error.RecalculateWorkoutFailed }
        let lastDuration = db.scalar(WS.table
            .select(WS.duration)
            .filter(WS.workoutID == workoutID)
            .order(WS.startTime.desc)
            .limit(1)
        )
        let duration: Double?
        if let lastDuration = lastDuration {
            duration = endTime.timeIntervalSinceDate(startTime) + lastDuration
        } else {
            duration = nil
        }
        let restDuration: Double?
        if let duration = duration, activeDuration = activeDuration {
            restDuration = duration - activeDuration
        } else {
            restDuration = nil
        }
        let activation: Activation
        if let avePcVolume = avePcVolume, aveIntensity = aveIntensity {
            activation = Activation(percent: max(aveIntensity, avePcVolume))
        } else if let avePcVolume = avePcVolume {
            activation = Activation(percent: avePcVolume)
        } else if let aveIntensity = aveIntensity {
            activation = Activation(percent: aveIntensity)
        } else {
            activation = .Light
        }
        try db.run(WO.table
            .filter(WS.workoutID == workoutID)
            .update(
                WO.startTime <- startTime,
                WO.sets <- row[WS.worksetID.count],
                WO.reps <- (row[WS.reps.sum] ?? 0),
                WO.duration <- duration,
                WO.restDuration <- restDuration,
                WO.activeDuration <- activeDuration,
                WO.volume <- row[WS.volume.sum],
                WO.avePercentMaxVolume <- avePcVolume,
                WO.avePercentMaxDuration <- row[WS.percentMaxDuration.average],
                WO.aveIntensity <- aveIntensity,
                WO.maxDuration <- row[WS.duration.max],
                WO.activation <- activation
            )
        )
    }

    func startDate(workout: Workout) -> NSDate? {
        let row = db.pluck(Workset.Schema.table
            .select(Workset.Schema.startTime.min)
            .filter(Workset.Schema.workoutID == workout.workoutID)
            .limit(1)
        )
        return row?[Workset.Schema.startTime.min]
    }

    func totalWorkouts(sinceDate date: NSDate) -> Int {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.workoutID.distinct.count)
            .filter(W.startTime.localDay >= date)
        )
    }
    
}
