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

    func get(type: PersonalRecord.Type, input: Workset.Input) -> [PersonalRecord] {
        guard let exerciseID = input.exerciseID else { return [] }
        var records: [PersonalRecord] = []
        let calculations = input.calculations
        if let weight = input.weight,
            w = maxReps(exerciseID: exerciseID, weight: weight, todate: input.startTime) {
            records.append(
                .MaxReps(
                    worksetID: w.worksetID,
                    maxReps: w.input.reps!,
                    curReps: input.reps))
        }
        if let w = maxRM(exerciseID: exerciseID, todate: input.startTime) {
            records.append(
                .MaxWeight(
                    worksetID: w.worksetID,
                    maxWeight: w.input.weight!,
                    curWeight: input.weight))
        }
        if let w = max1RM(exerciseID: exerciseID, todate: input.startTime) {
            records.append(
                .Max1RM(
                    worksetID: w.worksetID,
                    maxWeight: w.input.weight!,
                    curWeight: input.weight))
        }
        if let w = maxE1RM(exerciseID: exerciseID, todate: input.startTime) {
            records.append(
                .MaxE1RM(
                    worksetID: w.worksetID,
                    maxWeight: w.calculations.e1RM!,
                    curWeight: calculations.findmap {
                        if case let .E1RM(val) = $0 { return val }
                        return nil
                    }))
        }
        if let w = maxVolume(exerciseID: exerciseID, todate: input.startTime) {
            records.append(
                .MaxVolume(
                    worksetID: w.worksetID,
                    maxVolume: w.calculations.volume!,
                    curVolume: calculations.findmap {
                        if case let .Volume(val) = $0 { return val }
                        return nil
                    }))
        }
        if let reps = input.reps,
            w = maxXRM(exerciseID: exerciseID, reps: reps, todate: input.startTime) {
            records.append(
                .MaxXRM(
                    worksetID: w.worksetID,
                    maxWeight: w.input.weight!,
                    curWeight: input.weight))
        }
        return records
    }

    func get(type: Records.Type, input: Workset.Input) -> Records? {
        guard let exerciseID = input.exerciseID else { return nil }
        var perf = Records()
        perf.maxReps = input.weight.flatMap { self.maxReps(exerciseID: exerciseID, weight: $0, todate: input.startTime) }
        perf.maxWeight = maxRM(exerciseID: exerciseID, todate: input.startTime)
        perf.max1RM = max1RM(exerciseID: exerciseID, todate: input.startTime)
        perf.maxE1RM = maxE1RM(exerciseID: exerciseID, todate: input.startTime)
        perf.maxVolume = maxVolume(exerciseID: exerciseID, todate: input.startTime)
        perf.maxXRM = input.reps.flatMap { maxXRM(exerciseID: exerciseID, reps: $0, todate: input.startTime) }
        return perf
    }
    
    func maxRM(exerciseID exerciseID: Int64, todate date: NSDate = NSDate()) -> Workset? {
        return db.pluck(
            Workset.Schema.table
                .filter(
                    Workset.Schema.startTime.localDay < date.localDay &&
                    Workset.Schema.exerciseID == exerciseID &&
                    Workset.Schema.exerciseID != nil &&
                    Workset.Schema.weight != nil)
                .order(Workset.Schema.weight.desc)
                .limit(1))
    }

    func maxReps(exerciseID exerciseID: Int64, weight: Double, todate date: NSDate = NSDate()) -> Workset? {
        return db.pluck(
            Workset.Schema.table
                .filter(
                    Workset.Schema.startTime.localDay < date.localDay &&
                    Workset.Schema.exerciseID == exerciseID &&
                    Workset.Schema.exerciseID != nil &&
                    Workset.Schema.weight >= weight &&
                    Workset.Schema.reps != nil)
                .order(Workset.Schema.reps.desc)
                .limit(1)
        )
    }

    func max1RM(exerciseID exerciseID: Int64, todate date: NSDate = NSDate()) -> Workset? {
        typealias W = Workset.Schema
        return db.pluck(W.table
            .filter(
                W.startTime.localDay < date.localDay &&
                    W.exerciseID == exerciseID &&
                    W.exerciseID != nil &&
                    W.reps == 1 &&
                    W.weight != nil)
            .order(Workset.Schema.weight.desc)
            .limit(1))
    }

    func maxE1RM(exerciseID exerciseID: Int64, todate date: NSDate = NSDate()) -> Workset? {
        typealias W = Workset.Schema
        return db.pluck(W.table
            .filter(
                W.startTime.localDay < date.localDay &&
                    W.exerciseID == exerciseID &&
                    W.exerciseID != nil &&
                    W.e1RM != nil)
            .order(W.e1RM.desc)
            .limit(1))
    }

    func maxXRM(exerciseID exerciseID: Int64, reps: Int, todate date: NSDate = NSDate()) -> Workset? {
        typealias W = Workset.Schema
        return db.pluck(W.table
            .filter(
                W.startTime.localDay < date.localDay &&
                    W.exerciseID == exerciseID &&
                    W.exerciseID != nil &&
                    W.reps == reps &&
                    W.weight != nil)
            .order(Workset.Schema.weight.desc)
            .limit(1)
        )
    }

    func maxVolume(exerciseID exerciseID: Int64, todate date: NSDate = NSDate()) -> Workset? {
        return db.pluck(
            Workset.Schema.table
                .filter(
                    Workset.Schema.startTime.localDay < date.localDay &&
                        Workset.Schema.exerciseID == exerciseID &&
                        Workset.Schema.exerciseID != nil &&
                        Workset.Schema.weight != nil &&
                        Workset.Schema.volume != nil)
                .order(Workset.Schema.volume.desc)
                .limit(1))
    }

    func maxSquat(sinceDate date: NSDate) -> Double? {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.weight.max)
            .filter(
                W.startTime.localDay >= date &&
                    W.exerciseID == 973))
    }

    func maxDeadlift(sinceDate date: NSDate) -> Double? {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.weight.max)
            .filter(
                W.startTime.localDay >= date &&
                    W.exerciseID == 723))
    }

    func maxBench(sinceDate date: NSDate) -> Double? {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.weight.max)
            .filter(
                W.startTime.localDay >= date &&
                    W.exerciseID == 482))
    }

    func recalculateAll(after startTime: NSDate = NSDate(timeIntervalSince1970: 0)) throws {
        typealias W = Workset.Schema
        for workset: Workset in try db.prepare(W.table.filter(W.startTime >= startTime)) {
            guard let records = get(Records.self, input: workset.input) else { continue }
            let relRecords = RelativeRecords(input: workset.input, records: records)
            let newWorkset = workset.copy(input: workset.input, calculations: relRecords.calculations)
            try update(newWorkset)
            try recalculate(workoutID: workset.workoutID)
        }
    }

    func totalActiveDuration(sinceDate date: NSDate) -> Double? {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.duration.sum)
            .filter(W.startTime.localDay >= date))
    }

    func totalSets(sinceDate date: NSDate) -> Int {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.worksetID.count)
            .filter(W.startTime.localDay >= date))
    }

    func totalReps(sinceDate date: NSDate) -> Int? {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.reps.sum)
            .filter(W.startTime.localDay >= date))
    }

    func totalVolume(sinceDate date: NSDate) -> Double? {
        typealias W = Workset.Schema
        let query: ScalarQuery = W.table.select(W.volume.sum)
        return db.scalar(query.filter(W.startTime.localDay >= date))
    }

    func totalPRs(sinceDate date: NSDate) -> Int {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.worksetID.count)
            .filter(W.startTime.localDay >= date &&
                (W.intensity > 1.0 || W.intensity > 1.0)))
    }

    func volumeByDay() throws -> [(NSDate, Double)] {
        let cal = NSCalendar.currentCalendar()
        return try all(Workout).map { workout in
            let date = cal.startOfDayForDate(workout.startTime)
            return (date, workout.volume ?? 0)
        }
    }
    
}
