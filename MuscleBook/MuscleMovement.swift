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

struct MuscleMovement {
    let muscleMovementID: Int64?
    let exerciseID: Int64
    let classification: Classification
    let muscleName: String
    let muscle: Muscle?

    // http://www.exrx.net/Kinesiology/Glossary.html

    enum Classification: Int64 {
        case Target = 1
        case Agonist
        case Antagonist
        case Synergist
        case Stabilizer
        case DynamicStabilizer
        case AntagonistStabilizer
        case Other

        var name: String {
            switch self {
            case .Target: return "Target"
            case .Agonist: return "Agonist"
            case .Antagonist: return "Antagonist"
            case .Synergist: return "Synergist"
            case .Stabilizer: return "Stabilizer"
            case .DynamicStabilizer: return "Dynamic Stabilizer"
            case .AntagonistStabilizer: return "Antagonist Stabilizer"
            case .Other: return "Other"
            }
        }

        var activation: Double {
            switch self {
            case .Target: return 0.6
            case .Agonist: return 0.15
            case .Antagonist: return 0.15
            case .Synergist: return 0.2
            case .Stabilizer: return 0.15
            case .DynamicStabilizer: return 0.15
            case .AntagonistStabilizer: return 0.15
            case .Other: return 0.15
            }
        }
        
        static var all: [Classification] {
            return [.Target, .Agonist, .Antagonist, .Synergist, .Stabilizer, .DynamicStabilizer, .AntagonistStabilizer, .Other]
        }
    }
}

extension MuscleMovement.Classification {
    var color: UIColor {
        switch self {
        case .DynamicStabilizer, .Stabilizer, .AntagonistStabilizer, .Other: return UIColor(rgba: "#fcbba1")
        case .Agonist: return UIColor(rgba: "#fcbba1")
        case .Antagonist: return UIColor(rgba: "#fb6a4a")
        case .Synergist: return UIColor(rgba: "#fb6a4a")
        case .Target: return UIColor(rgba: "#ef3b2c")
        }
    }
}

extension SequenceType where Generator.Element == MuscleMovement {
    typealias C = MuscleMovement.Classification
    func dictionary() -> [C: [Muscle]] {
        var dict: [C: [Muscle]] = [:]
        forEach { movement in
            if let muscle = movement.muscle {
                var items = (dict[movement.classification] ?? [])
                items.append(muscle)
                dict[movement.classification] = items
            }
        }
        return dict
    }
}
