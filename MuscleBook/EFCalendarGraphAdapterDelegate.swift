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

class EFCalendarGraphAdapterDelegate: NSObject, EFCalendarGraphDataSource {

    private let db = DB.sharedInstance
    private let cal = NSCalendar.currentCalendar()
    private let workouts: [NSDate: Double]
    private let maxVolume: Double
    private let aveVolume: Double

    override init() {
        workouts = Dictionary(try! db.volumeByDay())
        maxVolume = workouts.values.maxElement() ?? 0
        aveVolume = workouts.values.reduce(0, combine: +) / Double(workouts.count)
    }

    func numberOfDataPointsInCalendarGraph(calendarGraph: EFCalendarGraph!) -> UInt {
        return 360
    }
    
    func calendarGraph(calendarGraph: EFCalendarGraph!, valueForDate date: NSDate!, daysAfterStartDate: UInt, daysBeforeEndDate: UInt) -> AnyObject! {
        let volume = workouts[cal.startOfDayForDate(date)] ?? 0
        if volume > aveVolume {
            return 5
        }
        if volume <= aveVolume && volume > 0 {
            return 1
        }
        return 0
    }
}
