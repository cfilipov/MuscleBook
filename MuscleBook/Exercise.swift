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

struct Exercise {
    enum Equipment: Int64 {
        case Lever = 1
        case LeverPlateLaded
        case LeverSelectorized
        case Weighted
        case Barbell
        case Dumbbell
        case Sled
        case Smith
        case Suspended
        case Assisted
        case SelfAssisted
        case AssistedMachine
        case AssistedPartner
        case Suspension
        case Cable
        case BodyWeight
    }
    
    let exerciseID: Int64?
    let name: String
    let inputOptions: InputOptions
    let equipment: Equipment
    let gif: String?
    let force: String?
    let level: String?
    let muscles: [MuscleMovement]?
    let mechanics: String?
    let type: String
    let instructions: [String]?
    let link: String
    let source: String?
}

extension Exercise.Equipment {
    init?(name: String) {
        switch name {
        case "Cable": self = Exercise.Equipment.Cable
        case "Lever (plate loaded)": self = Exercise.Equipment.LeverPlateLaded
        case "Lever (selectorized)": self = Exercise.Equipment.LeverSelectorized
        case "Weighted": self = Exercise.Equipment.Weighted
        case "Body Weight": self = Exercise.Equipment.BodyWeight
        case "Barbell": self = Exercise.Equipment.Barbell
        case "Dumbbell": self = Exercise.Equipment.Dumbbell
        case "Sled": self = Exercise.Equipment.Sled
        case "Smith": self = Exercise.Equipment.Smith
        case "Suspended": self = Exercise.Equipment.Suspended
        case "Assisted": self = Exercise.Equipment.Assisted
        case "Self-assisted": self = Exercise.Equipment.SelfAssisted
        case "Assisted (machine)": self = Exercise.Equipment.AssistedMachine
        case "Assisted (partner)": self = Exercise.Equipment.AssistedPartner
        case "Suspension": self = Exercise.Equipment.Suspension
        case "Bodyweight": self = Exercise.Equipment.BodyWeight
        case "Lever": self = Exercise.Equipment.Lever
        default: return nil
        }
    }

    var name: String {
        switch self {
        case .Cable: return "Cable"
        case .LeverPlateLaded: return "Lever (plate loaded)"
        case .LeverSelectorized: return "Lever (selectorized)"
        case .Weighted: return "Weighted"
        case .BodyWeight: return "Body Weight"
        case .Barbell: return "Barbell"
        case .Dumbbell: return "Dumbbell"
        case .Sled: return "Sled"
        case .Smith: return "Smith"
        case .Suspended: return "Suspended"
        case .Assisted: return "Assisted"
        case .SelfAssisted: return "Self-assisted"
        case .AssistedMachine: return "Assisted (machine)"
        case .AssistedPartner: return "Assisted (partner)"
        case .Suspension: return "Suspension"
        case .Lever: return "Lever"
        }
    }
}
