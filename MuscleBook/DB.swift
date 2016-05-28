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

typealias CurrentSchema = Schema20160524095754146

class DB {

    static let sharedInstance = DB()

    static let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask, true
        ).first! + "/musclebook.db"

    private let db: Connection

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
                Schema20160524095754146.migration
            ]
        )

        if !migrationManager.hasMigrationsTable() {
            try! migrationManager.createMigrationsTable()
        }

        if migrationManager.needsMigration() {
            try! migrationManager.migrateDatabase()
            try! recalculateAllWorksets()
        }
    }

}

// MARK:

extension DB {

    func all(type: Workset.Type) throws -> AnySequence<Workset> {
        return try db.prepare(
            Workset.Schema.table.order(Workset.Schema.startTime.desc)
        )
    }

    func all(type: Exercise.Type) throws -> [ExerciseReference] {
        return Array(
            try db.prepare(
                Exercise.Schema.table.order(Exercise.Schema.name)
            )
        )
    }

    func all(type: Workout.Type) throws -> AnySequence<Workout> {
        return try db.prepare(Workout.Schema.table.order(Workout.Schema.startTime.desc))
    }

    func save(exercise: Exercise) throws -> Int64 {
        let rowid = try db.run(
            Exercise.Schema.table.insert(exercise)
        )
        try db.run(
            Exercise.Schema.search.insert(or: .Replace, exercise.exerciseReference)
        )
        return rowid
    }

    func save(movement: MuscleMovement) throws -> Int64 {
        return try db.run(MuscleMovement.Schema.table.insert(movement))
    }

    func save(workset: Workset) throws {
        try db.transaction {
            var w = workset
            let wID = self.workoutID(forStartTime: workset.input.startTime, duration: workset.input.duration)
            w.workoutID = wID
            try self.db.run(Workset.Schema.table.insert(w))
            try self.recalculate(workoutID: wID)
        }
    }

    func save(worksets: [Workset]) throws {
        try db.transaction {
            for w in worksets {
                try self.save(w)
            }
        }
    }

    func update(workset: Workset) throws {
        typealias W = Workset.Schema
        try db.run(
            W.table
                .filter(W.worksetID == workset.worksetID!)
                .update(workset.setters)
        )
    }

    func count(type: Exercise.Type) -> Int {
        return db.scalar(Exercise.Schema.table.count)
    }

    func count(type: Muscle.Type) -> Int {
        return Muscle.allMuscles.count
    }

    func count(type: Workset.Type) -> Int {
        return db.scalar(Workset.Schema.table.count)
    }

    func count(type: Workout.Type) -> Int {
        return db.scalar(Workout.Schema.table.count)
    }

    func count(type: Workout.Type, date: NSDate) -> Int {
        return db.scalar(
            Workout.Schema.table.filter(
                Workout.Schema.startTime.localDay == date.localDay
            ).count
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

    func dereference(ref: ExerciseReference) -> Exercise? {
        guard let exerciseID = ref.exerciseID else { return nil }
        typealias S = Exercise.Schema
        let query = S.table.filter(S.exerciseID == exerciseID)
        return db.pluck(query)
    }

    func get(type: Workout.Type, workoutID: Int64) -> Workout? {
        return db.pluck(Workout.Schema.table.filter(Workout.Schema.workoutID == workoutID))
    }

    func match(name name: String) throws -> AnySequence<ExerciseReference> {
        return try db.prepare(Exercise.Schema.match(name: name))
    }

    func find(exactName name: String) -> ExerciseReference? {
        return db.pluck(Exercise.Schema.find(exactName: name))
    }

    func find(exerciseID exerciseID: Int64) throws -> AnySequence<MuscleMovement> {
        return try db.prepare(
            MuscleMovement.Schema.table.filter(
                MuscleMovement.Schema.exerciseID == exerciseID
            )
        )
    }

    func worksets(workoutID workoutID: Int64) throws -> AnySequence<Workset> {
        return try db.prepare(
            Workset.Schema.table.filter(
                Workset.Schema.workoutID == workoutID
            )
        )
    }

    func nextAvailableRowID(type: Workout.Type) -> Int64 {
        typealias S = Workset.Schema
        let max = db.scalar(S.table.select(S.workoutID.max))
        return (max ?? 0) + 1
    }

    func maxRM(exerciseID exerciseID: Int64, todate date: NSDate = NSDate()) -> Workset? {
        return db.pluck(
            Workset.Schema.table
                .filter(
                    Workset.Schema.startTime.localDay < date.localDay &&
                        Workset.Schema.exerciseID == exerciseID &&
                        Workset.Schema.exerciseID != nil
                )
                .order(Workset.Schema.weight.desc)
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
                    W.reps == 1
            )
            .order(Workset.Schema.weight.desc)
            .limit(1)
        )
    }

    func maxE1RM(exerciseID exerciseID: Int64, todate date: NSDate = NSDate()) -> Workset? {
        typealias W = Workset.Schema
        return db.pluck(W.table
            .filter(
                W.startTime.localDay < date.localDay &&
                    W.exerciseID == exerciseID &&
                    W.exerciseID != nil
            )
            .order(W.e1RM.desc)
            .limit(1)
        )
    }

    func maxXRM(exerciseID exerciseID: Int64, reps: Int, todate date: NSDate = NSDate()) -> Workset? {
        typealias W = Workset.Schema
        return db.pluck(W.table
            .filter(
                W.startTime.localDay < date.localDay &&
                    W.exerciseID == exerciseID &&
                    W.exerciseID != nil &&
                    W.reps == reps
            )
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
                        Workset.Schema.exerciseID != nil
                )
                .order(Workset.Schema.volume.desc)
                .limit(1)
        )
    }

    func volumeByDay() throws -> [(NSDate, Double)] {
        let cal = NSCalendar.currentCalendar()
        return try all(Workout).map { workout in
            let date = cal.startOfDayForDate(workout.startTime)
            return (date, workout.volume ?? 0)
        }
    }

    func activationByDay() throws -> [NSDate: Activation] {
        let cal = NSCalendar.currentCalendar()
        typealias W = Workset.Schema
        let res = try db.prepare(W.table
            .select(W.startTime, W.activation)
            .group(W.startTime.localDay)
            .order(W.startTime.localDay)
        )
        return Dictionary(
            res.lazy.map {
                (
                    cal.startOfDayForDate($0[W.startTime]),
                    $0.get(W.activation)
                )
            }
        )
    }

    func firstWorkoutDay() -> NSDate? {
        typealias W = Workout.Schema
        return db.scalar(W.table.select(W.startTime.min))
    }

    func lastWorkoutDay() -> NSDate? {
        typealias W = Workout.Schema
        return db.scalar(W.table.select(W.startTime.max))
    }

    func isRestDay(date: NSDate) -> Bool {
        typealias W = Workout.Schema
        let count = db.scalar(
            W.table
                .select(W.workoutID.count)
                .filter(W.startTime.localDay == date.localDay)
        )
        return count > 0 ? true : false
    }

    func lastRestDay() -> NSDate? {
        let cal = NSCalendar.currentCalendar()
        let minDate = firstWorkoutDay()
        var date = NSDate()
        while !cal.isSameDay(date, minDate) {
            if isRestDay(date) {
                break
            } else {
                date = cal.addDays(-1, toDate: date)!
            }
        }
        return date
    }

    func totalExercises(sinceDate date: NSDate) -> Int {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.exerciseID.distinct.count)
            .filter(W.startTime.localDay >= date)
        )
    }

    func totalSets(sinceDate date: NSDate) -> Int {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.worksetID.count)
            .filter(W.startTime.localDay >= date)
        )
    }

    func totalWorkouts(sinceDate date: NSDate) -> Int {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.workoutID.distinct.count)
            .filter(W.startTime.localDay >= date)
        )
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
                (W.intensity > 1.0 || W.intensity > 1.0)
            )
        )
    }

    func totalActiveDuration(sinceDate date: NSDate) -> Double? {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.duration.sum)
            .filter(W.startTime.localDay >= date)
        )
    }

    func get(type: MuscleWorkSummary.Type, date: NSDate, movementClass: MuscleMovement.Classification) throws -> AnySequence<MuscleWorkSummary> {
        typealias W = Workset.Schema
        typealias M = MuscleMovement.Schema
        return try db.prepare(W.table
            .select(
                M.muscleID,
                M.muscleMovementClassID,
                W.table[W.exerciseID],
                W.table[W.exerciseName],
                W.activation.max,
                W.volume.sum,
                W.weight.max
            )
            .join(M.table, on: W.table[W.exerciseID] == M.table[M.exerciseID])
            .filter(
                W.startTime.localDay == date.localDay &&
                W.table[W.exerciseID] != nil &&
                M.muscleMovementClassID == movementClass &&
                M.muscleID != nil
            )
            .group(M.muscleID)
        )
    }

    func get(type: MuscleWorkSummary.Type, workoutID: Int64, movementClass: MuscleMovement.Classification) throws -> AnySequence<MuscleWorkSummary> {
        typealias W = Workset.Schema
        typealias M = MuscleMovement.Schema
        return try db.prepare(W.table
            .select(
                M.muscleID,
                M.muscleMovementClassID,
                W.table[W.exerciseID],
                W.table[W.exerciseName],
                W.activation.max,
                W.volume.sum,
                W.weight.max
            )
            .join(M.table, on: W.table[W.exerciseID] == M.table[M.exerciseID])
            .filter(
                W.workoutID == workoutID &&
                W.table[W.exerciseID] != nil &&
                M.muscleMovementClassID == movementClass &&
                M.muscleID != nil
            )
            .group(M.muscleID)
        )
    }

    func importCSV(type: Workset.Type, fromURL url: NSURL) throws -> Int {
        let importer = WorksetCSVImporter(url: url)
        return try importer.importCSV()
    }

    func exportCSV(type: Workset.Type, toURL url: NSURL) throws {
        let writer = CHCSVWriter(forWritingToCSVFile: url.path)
        writer.writeField("Date")
        writer.writeField("WorkoutID")
        writer.writeField("ExerciseID")
        writer.writeField("Exercise")
        writer.writeField("Reps")
        writer.writeField("Weight")
        writer.writeField("Duration")
        writer.finishLine()
        try all(Workset).forEach { workset in
            writer.writeField(workset.input.startTime.datatypeValue)
            writer.writeField(workset.workoutID?.description ?? "")
            writer.writeField(workset.input.exerciseID?.description ?? "")
            writer.writeField(workset.input.exerciseName)
            writer.writeField(workset.input.reps?.description ?? "")
            writer.writeField(workset.input.weight?.description ?? "")
            writer.writeField(workset.input.duration.description)
            writer.finishLine()
        }
    }

    func dateRange(workoutID workoutID: Int64) -> (NSDate, NSDate)? {
        let date = Workset.Schema.startTime
        let row = db.pluck(Workset.Schema.table
            .select(date.min, date.max)
            .filter(Workset.Schema.workoutID == workoutID)
            .limit(1)
        )
        guard let min = row?[date.min] else { return nil }
        guard let max = row?[date.max] else { return nil }
        return (min, max)
    }

    func findUnknownExercises() throws -> AnySequence<ExerciseReference> {
        let query = Workset.Schema.table
            .select(Workset.Schema.exerciseName)
            .filter(Workset.Schema.exerciseID == nil)
            .group(Workset.Schema.exerciseName)
        return try db.prepare(query)
    }

    func startDate(workout: Workout) -> NSDate? {
        let row = db.pluck(Workset.Schema.table
            .select(Workset.Schema.startTime.min)
            .filter(Workset.Schema.workoutID == workout.workoutID!)
            .limit(1)
        )
        return row?[Workset.Schema.startTime.min]
    }

    func endDate(workout: Workout) -> NSDate? {
        let row = db.pluck(Workset.Schema.table
            .select(Workset.Schema.startTime.max)
            .filter(Workset.Schema.workoutID == workout.workoutID!)
            .limit(1)
        )
        return row?[Workset.Schema.startTime.max]
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

    func next(workout: Workout) -> Workout? {
        let date = Workset.Schema.startTime
        return db.pluck(Workset.Schema.table
            .order(date.asc)
            .filter(date > workout.startTime)
            .limit(1)
        )
    }

    func newest(type: Workset.Type) -> Workset? {
        typealias W = Workset.Schema
        return db.pluck(W.table.order(W.startTime.desc))
    }

    func delete(workset: Workset) throws -> Int {
        typealias W = Workset.Schema
        guard let worksetID = workset.worksetID else {
            fatalError("Identifier required to delete workset \(workset)")
        }
        let query = W.table.filter(W.worksetID == worksetID)
        return try db.run(query.delete())
    }

    func workoutID(forStartTime date: NSDate, duration: Double) -> Int64 {
//        nextAvailableRowID(Workout)
        fatalError()
    }

    func recalculateAllWorksets() throws {
        typealias W = Workset.Schema
        for workset: Workset in try db.prepare(W.table) {
            guard let records = get(Records.self, input: workset.input) else { continue }
            let relRecords = RelativeRecords(input: workset.input, records: records)
            var newWorkset = Workset(relativeRecords: relRecords)
            newWorkset.worksetID = workset.worksetID
            newWorkset.workoutID = workset.workoutID
            try update(newWorkset)
            if let workoutID = workset.workoutID {
                try recalculate(workoutID: workoutID)
            }
        }
    }

    func recalculate(workoutID workoutID: Int64) throws -> SuccessOrFail {
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
            .filter(WS.workoutID == workoutID)
        ) else { return .Fail }
        let sets = row[WS.worksetID.count]
        guard let
            startTime = row[WS.startTime.min],
            endTime = row[WS.startTime.max],
            reps = row[WS.reps.sum],
            activeDuration = row[WS.duration.sum],
            volume = row[WS.volume.sum],
            avePcVolume = row[WS.percentMaxVolume.average],
            avePercentMaxDuration = row[WS.percentMaxDuration.average],
            aveIntensity = row[WS.intensity.average],
            maxDuration = row[WS.duration.max],
            maxActivation = row.get(WS.activation.max)
            else { return .Fail }
        let lastDuration = db.scalar(WS.table
            .select(WS.duration)
            .filter(WS.workoutID == workoutID)
            .order(WS.startTime.desc)
            .limit(1)
        )
        let duration = endTime.timeIntervalSinceDate(startTime) + lastDuration
        let restDuration = duration - activeDuration
        try db.run(WO.table
            .filter(WS.workoutID == workoutID)
            .update(
                WO.startTime <- startTime,
                WO.sets <- sets,
                WO.reps <- reps,
                WO.duration <- duration,
                WO.restDuration <- restDuration,
                WO.activeDuration <- activeDuration,
                WO.volume <- volume,
                WO.avePercentMaxVolume <- avePcVolume,
                WO.avePercentMaxDuration <- avePercentMaxDuration,
                WO.aveIntensity <- aveIntensity,
                WO.maxDuration <- maxDuration,
                WO.maxActivation <- maxActivation
            )
        )
        return .Success
    }

    func get(type: Records.Type, input: Workset.Input) -> Records? {
        guard let exerciseID = input.exerciseID else { return nil }
        var perf = Records()
        perf.maxWeight = maxRM(exerciseID: exerciseID, todate: input.startTime)
        perf.max1RM = max1RM(exerciseID: exerciseID, todate: input.startTime)
        perf.maxE1RM = maxE1RM(exerciseID: exerciseID, todate: input.startTime)
        perf.maxVolume = maxVolume(exerciseID: exerciseID, todate: input.startTime)
        if let reps = input.reps {
            perf.maxXRM = maxXRM(exerciseID: exerciseID, reps: reps, todate: input.startTime)
        }
        return perf
    }

}
