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
        try DB.sharedInstance.save(
            records.flatMap { try workset(CSVRecord: $0) }
        )
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

    func workset(CSVRecord record: CHCSVOrderedDictionary) throws -> Workset.Input? {
        fatalError() // TODO: Unbreak this
//        guard let
//            dateStr = record["Date"] as? String,
//            exerciseName = record["Exercise"] as? String,
//            reps = (record["Reps"] as? String).flatMap(Int.init)
//            else { return nil }
//        let exerciseID = (record["ExerciseID"] as? String).flatMap { Int64($0) } 
//        let weight = (record["Weight"] as? String).flatMap { Double($0) }
//        let duration = (record["Duration"] as? String).flatMap { Double($0) }
//        let wID = (record["WorkoutID"] as? String).flatMap { Int64($0) } ?? nextWorkoutID(dateStr: dateStr)
//        let date = NSDate.parseISO8601Date(dateStr)
//        if weight == nil && duration == nil { return nil }
//        let db = DB.sharedInstance
//        return try Workset(
//            input: Workset.Input(
//                exerciseID: exerciseID ?? db.match(name: exerciseName).generate().next()?.exerciseID,
//                exerciseName: exerciseName,
//                startTime: date,
//                duration: duration!,
//                failure: false,
//                warmup: false,
//                reps: reps,
//                weight: weight
//            )
//        )
    }

}
