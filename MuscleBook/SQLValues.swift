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

extension MuscleMovement.Classification: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> MuscleMovement.Classification {
        return MuscleMovement.Classification(rawValue: intValue)!
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}

extension Muscle: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> Muscle {
        return Muscle(rawValue: intValue)!
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}

extension Activation: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> Activation {
        return Activation(rawValue: intValue)!
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}

extension InputOptions: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> InputOptions {
        return InputOptions(rawValue: intValue)
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}

extension Exercise.Equipment: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> Exercise.Equipment {
        return Exercise.Equipment(rawValue: intValue)!
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}

extension Exercise.Force: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> Exercise.Force {
        return Exercise.Force(rawValue: intValue)!
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}

extension Exercise.Mechanics: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> Exercise.Mechanics {
        return Exercise.Mechanics(rawValue: intValue)!
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}

extension Exercise.ExerciseType: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> Exercise.ExerciseType {
        return Exercise.ExerciseType(rawValue: intValue)!
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}

extension Exercise.SkillLevel: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> Exercise.SkillLevel {
        return Exercise.SkillLevel(rawValue: intValue)!
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}
