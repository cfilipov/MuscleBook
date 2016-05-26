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

struct ExerciseReference {
    let exerciseID: Int64?
    let name: String
}

extension ExerciseReference: Equatable {}

func ==(lhs: ExerciseReference, rhs: ExerciseReference) -> Bool {
    return lhs.exerciseID == rhs.exerciseID && lhs.name == rhs.name
}

extension Exercise {
    var exerciseReference: ExerciseReference {
        return ExerciseReference(exerciseID: exerciseID, name: name)
    }
}

extension Workset {
    var exerciseReference: ExerciseReference {
        return ExerciseReference(exerciseID: exerciseID, name: exerciseName)
    }
}
