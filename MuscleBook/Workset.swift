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
    struct Input {
        var exerciseID: Int64?
        var exerciseName: String
        var startTime: NSDate
        var duration: Double
        var failure: Bool
        var warmup: Bool
        var reps: Int?
        var weight: Double?
    }
    struct Calculations {
        var volume: Double?
        var e1RM: Double?
        var percentMaxVolume: Double?
        var intensity: Double?
        var activation: Activation
    }
    let worksetID: Int64
    let workoutID: Int64
    let input: Input
    let calculations: Calculations
}

// http://www.exrx.net/Calculators/OneRepMax.html
// http://www.exrx.net/Calculators/onerepmax.js
func estimate1RM(reps reps: Int, weight: Double) -> Double? {
    precondition(reps >= 0)
    if reps == 0 { return nil }
    if reps == 1 { return weight }
    if reps < 10 { return round(weight / (1.0278 - 0.0278 * Double(reps))) }
    else { return round(weight / 0.75) }
}

extension Workset {
    func copy(worksetID worksetID: Int64, workoutID: Int64) -> Workset {
        return Workset(
            worksetID: worksetID,
            workoutID: workoutID,
            input: self.input,
            calculations: self.calculations
        )
    }

    func copy(worksetID worksetID: Int64) -> Workset {
        return Workset(
            worksetID: worksetID,
            workoutID: self.workoutID,
            input: self.input,
            calculations: self.calculations
        )
    }

    func copy(input input: Input, calculations: Calculations) -> Workset {
        return Workset(
            worksetID: self.worksetID,
            workoutID: self.workoutID,
            input: input,
            calculations: calculations
        )
    }
}
