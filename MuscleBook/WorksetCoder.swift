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

extension Workset: ValueCoding {
    typealias Coder = WorksetCoder
}

@objc class WorksetCoder: NSObject, NSCoding, CodingType {

    let value: Workset

    required init(_ v: Workset) {
        value = v
    }

    required init?(coder aDecoder: NSCoder) {
        let exerciseName = aDecoder.decodeObjectForKey("Exercise") as! String
        let date = aDecoder.decodeObjectForKey("Date") as! NSDate
        let reps = aDecoder.decodeObjectForKey("Reps") as! Int
        let weight = aDecoder.decodeObjectForKey("Weight") as? Double
        let duration = aDecoder.decodeObjectForKey("Duration") as? Double
        value = Workset(
            worksetID: nil,
            exerciseID: nil,
            workoutID: nil,
            exerciseName: exerciseName,
            date: date,
            reps: reps,
            weight: weight,
            duration: duration,
            e1RM: nil,
            maxE1RM: nil,
            maxDuration: nil
        )
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.exerciseName, forKey: "Exercise")
        aCoder.encodeObject(value.date, forKey: "Date")
        aCoder.encodeObject(value.reps, forKey: "Reps")
        if let _ = value.weight {
            aCoder.encodeObject(value.weight, forKey: "Weight")
        }
        if let _ = value.duration {
            aCoder.encodeObject(value.duration, forKey: "Duration")
        }
    }

}