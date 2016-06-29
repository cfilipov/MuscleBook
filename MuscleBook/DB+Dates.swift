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

    func activationByDay() throws -> [NSDate: ActivationLevel] {
        let cal = NSCalendar.currentCalendar()
        typealias W = Workout.Schema
        let res = try db.prepare(W.table
            .select(W.startTime, W.activation.max)
            .group(W.startTime.localDay)
            .order(W.startTime.localDay)
        )
        return Dictionary(
            res.lazy.map {
                (
                    cal.startOfDayForDate($0[W.startTime]),
                    $0.get(W.activation.max)!
                )
            }
        )
    }

    func activationByDay(exerciseID exerciseID: Int64) throws -> [NSDate: ActivationLevel] {
        let cal = NSCalendar.currentCalendar()
        typealias W = Workset.Schema
        let res = try db.prepare(W.table
            .select(W.startTime, W.activation.max)
            .filter(W.exerciseID == exerciseID)
            .group(W.startTime.localDay)
            .order(W.startTime.localDay)
        )
        return Dictionary(
            res.lazy.map {
                (
                    cal.startOfDayForDate($0[W.startTime]),
                    $0.get(W.activation.max)!
                )
            }
        )
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

    func isRestDay(date: NSDate) -> Bool {
        typealias W = Workout.Schema
        let count = db.scalar(
            W.table
                .select(W.workoutID.count)
                .filter(W.startTime.localDay == date.localDay)
        )
        return count == 0 ? true : false
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
    
}