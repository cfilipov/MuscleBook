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

extension WorksetAdapter {
    
    static func importCSV(url url: NSURL) throws -> Int {
        let importer = WorksetCSVImporter(url: url)
        return try importer.importCSV()
    }

    static func exportCSV(url: NSURL) throws {
        let writer = CHCSVWriter(forWritingToCSVFile: url.path)
        writer.writeField("Date")
        writer.writeField("WorkoutID")
        writer.writeField("ExerciseID")
        writer.writeField("Exercise")
        writer.writeField("Reps")
        writer.writeField("Weight")
        writer.writeField("Duration")
        writer.finishLine()
        try all().forEach { workset in
            writer.writeField(workset.date.datatypeValue)
            writer.writeField(workset.workoutID?.description ?? "")
            writer.writeField(workset.exerciseID?.description ?? "")
            writer.writeField(workset.exerciseName)
            writer.writeField(workset.reps.description)
            writer.writeField(workset.weight?.description ?? "")
            writer.writeField(workset.duration?.description ?? "")
            writer.finishLine()
        }
    }

}

final class WorksetCSVImporter {

    private let url: NSURL
    private var records: [CHCSVOrderedDictionary] = []
    private var workoutIDs: [String: Int64] = [:]
    private var curWorkoutID: Int64 = 0

    let localtimeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return formatter
    }()

    init(url: NSURL) {
        self.url = url
    }

    func importCSV() throws -> Int {
        precondition(records.isEmpty)
        precondition(workoutIDs.isEmpty)
        precondition(curWorkoutID == 0)
        records = NSArray(contentsOfCSVURL: url, options: [.SanitizesFields, .TrimsWhitespace, .UsesFirstLineAsKeys]) as! [CHCSVOrderedDictionary]
        try DB.sharedInstance.connection.transaction {
            for record in self.records {
                if let w = try self.workset(CSVRecord: record) {
                    try Workset.Adapter.save(w)
                }
            }
        }
        return records.count
    }

    func nextWorkoutID() -> Int64 {
        curWorkoutID += 1
        return curWorkoutID
    }

    func nextWorkoutID(dateStr dateStr: String) -> Int64 {
        if let existingWorkoutID = workoutIDs[dateStr] {
            return existingWorkoutID
        }
        let workoutID = workoutIDs[dateStr] ?? nextWorkoutID()
        workoutIDs[dateStr] = workoutID
        return workoutID
    }

    func workset(CSVRecord record: CHCSVOrderedDictionary) throws -> Workset? {
        guard let
            dateStr = record["Date"] as? String,
            exerciseName = record["Exercise"] as? String,
            reps = (record["Reps"] as? String).flatMap(Int.init)
            else { return nil }
        let exerciseID = (record["ExerciseID"] as? String).flatMap { Int64($0) } 
        let weight = (record["Weight"] as? String).flatMap { Double($0) }
        let duration = (record["Duration"] as? String).flatMap { Double($0) }
        let wID = (record["WorkoutID"] as? String).flatMap { Int64($0) } ?? nextWorkoutID(dateStr: dateStr)
        let date = NSDate.parseISO8601Date(dateStr)
        if weight == nil && duration == nil { return nil }
        var workset = try Workset(
            worksetID: nil,
            exerciseID: exerciseID ?? Exercise.Adapter.find(name: exerciseName).generate().next()?.exerciseID,
            workoutID: wID,
            exerciseName: exerciseName,
            date: date,
            reps: reps,
            weight: weight,
            duration: duration,
            e1RM: weight.flatMap { Workset.estimate1RM(reps: reps, weight: $0) },
            maxE1RM: nil,
            maxDuration: nil
        )
        workset.maxE1RM = workset.exerciseID.flatMap { Workset.Adapter.findMax1RM(exerciseID: $0, todate: date)?.e1RM }
        return workset
    }

}

