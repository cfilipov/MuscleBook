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
        var duration: Double?
        var failure: Bool
        var warmup: Bool
        var reps: Int?
        var weight: Double?
        var bodyweight: Double?
        var assistanceWeight: Double?
    }
    struct Calculations {
        var volume: Double?
        var e1RM: Double?
        var percentMaxVolume: Double?
        var percentMaxDuration: Double?
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

func calculateWilks(weight: Double, bodyweight x: Double) -> Double {
    precondition(x > 0)
    precondition(weight > 0)
    // TODO: calculate female coef. too
    let a = -216.0475144
    let b = 16.2606339
    let c = -0.002388645
    let d = -0.00113732
    let e = 7.01863E-06
    let f = -1.291E-08
    return weight / (a + (b*x) + (c*pow(x, 2) + (d*pow(x, 3) + (e*pow(x, 4) + (f*pow(x, 5))))))
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

    var shortString: String {
        if let reps = input.reps, weight = input.weight {
            return "\(reps)@\(weight)"
        }
        else if let reps = input.reps {
            return "\(reps)r"
        }
        else {
            return "\(input.duration)s"
        }
    }
}

extension Workset.Input {
    var exercise: ExerciseReference? {
        get {
            guard let exerciseID = exerciseID where !exerciseName.isEmpty else { return nil }
            return ExerciseReference(
                exerciseID: exerciseID,
                name: exerciseName
            )
        }

        set(newVal) {
            self.exerciseID = newVal?.exerciseID
            self.exerciseName = newVal?.name ?? ""
        }
    }
}
