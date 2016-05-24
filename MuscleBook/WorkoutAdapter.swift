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

extension Workout: KeyedModelType, DateModelType {
    typealias Adapter = WorkoutAdapter

    var identifier: Int64? {
        return workoutID
    }
}

enum WorkoutAdapter: TableAdapterType, DateAdapterType, KeyedAdapterType {

    typealias Model = Workout
    static let table: SchemaType = View("workout")

    /* Columns */

    static let workoutID = Expression<Int64>("workout_id")
    static let date = Expression<NSDate>("date")
    static let sets = Expression<Int>("sets")
    static let reps = Expression<Int>("reps")
    static let weight = Expression<Double?>("weight")
    static let duration = Expression<Double?>("duration")

    static let identifier = workoutID

    static func setters(model: Model) -> [SQLite.Setter] {
        fatalError("Can't insert into a view")
    }

    static func mapRow(row: Row) -> Model {
        return Workout(
            workoutID: row[workoutID],
            date: row[date],
            totalWeight: row[weight],
            totalDuration: row[duration],
            count: row[sets]
        )
    }

    static func nextWorkoutID() -> Int64 {
        let db = DB.sharedInstance.connection
        let tbWorkset = Workset.Adapter.table
        let cWorkoutID = Workset.Adapter.workoutID
        let max = db.scalar(tbWorkset.select(cWorkoutID.max)) ?? 0
        return max + 1
    }

    static func countByDay() throws -> [(NSDate, Int)] {
        let db = DB.sharedInstance.connection
        let rows = try db.prepare(
            table.select(date, workoutID.count).group(date.localDay)
        )
        let cal = NSCalendar.currentCalendar()
        return rows.map { row in
            return (cal.startOfDayForDate(row[date]), row[workoutID.count])
        }
    }

    static func all() throws -> AnySequence<Workout> {
        let db = DB.sharedInstance.connection
        return try db.prepare(table.order(date.desc)).adapterOf(Workout)
    }

    static func volumeByDay() throws -> [(NSDate, Double)] {
        let cal = NSCalendar.currentCalendar()
        return try all().map { workout in
            let date = cal.startOfDayForDate(workout.date)
            return (date, workout.totalWeight ?? 0)
        }
    }
    
}

extension Workout {

    func startDate() -> NSDate? {
        let db = DB.sharedInstance.connection
        let tbWorkset = Workset.Adapter.table
        let cWorkoutID = Workset.Adapter.workoutID
        let cDate = Workset.Adapter.date
        let row = db.pluck(tbWorkset
            .select(cDate.min)
            .filter(cWorkoutID == self.workoutID!)
            .limit(1)
        )
        return row?[cDate.min]
    }

    func endDate() -> NSDate? {
        let db = DB.sharedInstance.connection
        let tbWorkset = Workset.Adapter.table
        let cWorkoutID = Workset.Adapter.workoutID
        let cDate = Workset.Adapter.date
        let row = db.pluck(tbWorkset
            .select(cDate.max)
            .filter(cWorkoutID == self.workoutID!)
            .limit(1)
        )
        return row?[cDate.max]
    }

    func prev() -> Workout? {
        let db = DB.sharedInstance.connection
        let tbWorkout = Adapter.table
        let cDate = Adapter.date
        let row = db.pluck(tbWorkout
            .order(cDate.desc)
            .filter(cDate < self.date)
            .limit(1)
        )
        if let row = row {
            return Adapter.mapRow(row)
        }
        return nil
    }

    func next() -> Workout? {
        let db = DB.sharedInstance.connection
        let tbWorkout = Adapter.table
        let cDate = Adapter.date
        let row = db.pluck(tbWorkout
            .order(cDate.asc)
            .filter(cDate > self.date)
            .limit(1)
        )
        if let row = row {
            return Adapter.mapRow(row)
        }
        return nil
    }
    
}


