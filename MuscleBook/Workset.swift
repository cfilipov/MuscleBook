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

struct Workset {
    var worksetID: Int64?
    let exerciseID: Int64?
    let workoutID: Int64?
    let exerciseName: String
    let date: NSDate
    let reps: Int
    let weight: Double?
    let duration: Double?
    var e1RM: Double?
    var maxE1RM: Double?
    var maxDuration: Double?
}

extension Workset: Equatable { }

func == (lhs: Workset, rhs: Workset) -> Bool {
    // http://stackoverflow.com/questions/26550775
    if lhs.worksetID != rhs.worksetID { return false }
    if lhs.workoutID != rhs.workoutID { return false }
    if lhs.exerciseName != rhs.exerciseName { return false }
    if lhs.date != rhs.date { return false }
    if lhs.reps != rhs.reps { return false }
    if lhs.weight != rhs.weight { return false }
    if lhs.duration != rhs.duration { return false }
    return true
}

extension Workset {
    var valueString: String {
        if let weight = weight {
            return "\(reps)@\(weight)"
        }
        return "\(reps) reps"
    }

    // http://www.exrx.net/Calculators/OneRepMax.html
    // http://www.exrx.net/Calculators/onerepmax.js
    static func estimate1RM(reps reps: Int, weight: Double) -> Double? {
        precondition(reps >= 0)
        if reps == 0 { return nil }
        if reps == 1 { return weight }
        if reps < 10 { return round(weight / (1.0278 - 0.0278 * Double(reps))) }
        if reps == 10 { return round(weight / 0.75) }
        return nil // This calculation only works for reps < 10
    }
}
