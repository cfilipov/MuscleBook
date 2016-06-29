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

    struct InputOptions: OptionSetType {
        let rawValue: Int64

        static let Reps = InputOptions(rawValue: 1 << 0)
        static let Weight  = InputOptions(rawValue: 1 << 1)
        static let BodyWeight  = InputOptions(rawValue: 1 << 2)
        static let Duration  = InputOptions(rawValue: 1 << 3)
        static let AssistanceWeight  = InputOptions(rawValue: 1 << 4)
        static let Failure  = InputOptions(rawValue: 1 << 5)
        static let Warmup  = InputOptions(rawValue: 1 << 6)
        static let StartTime  = InputOptions(rawValue: 1 << 7)

        static let AllOptions: InputOptions = [.Reps, .Weight, .BodyWeight, .Duration, .AssistanceWeight]
        static let DefaultOptions: InputOptions = [.Reps, .Weight, .Duration]
        static let UniversalOptions: InputOptions = [.StartTime, .Warmup, .Failure]
    }

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
    
    enum Force: Int64 {
        case Push = 1
        case Pull
        case PushAndPull
    }
    
    enum Mechanics: Int64 {
        case Isolation = 1
        case Compound
    }
    
    enum ExerciseType: Int64 {
        case BasicOrAuxiliary = 1
        case Auxiliary
        case Basic
        case Specialized
    }
    
    enum SkillLevel: Int64 {
        case Beginer = 1
        case Intermediate
        case Advanced
    }
    
    let exerciseID: Int64
    let name: String
    let inputOptions: InputOptions
    let equipment: Equipment
    let gif: String?
    let force: Force?
    let skillLevel: SkillLevel?
    var muscles: [MuscleMovement]?
    let mechanics: Mechanics?
    let exerciseType: ExerciseType
    let instructions: [String]?
    let link: String?
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

extension Exercise.Force {
    init?(name: String) {
        switch name {
        case "Push": self = .Push
        case "Pull": self = .Pull
        case "PushAndPull": self = .PushAndPull
        default: return nil
        }
    }
    
    var name: String {
        switch self {
        case Push: return "Push"
        case Pull: return "Pull"
        case PushAndPull: return "PushAndPull"
        }
    }
}

extension Exercise.Mechanics {
    init?(name: String) {
        switch name {
        case "Isolation": self = .Isolation
        case "Compound": self = .Compound
        default: return nil
        }
    }
    
    var name: String {
        switch self {
        case Isolation: return "Isolation"
        case Compound: return "Compound"
        }
    }
}

extension Exercise.ExerciseType {
    init?(name: String) {
        switch name {
        case "Basic or Auxiliary": self = .BasicOrAuxiliary
        case "Auxiliary or Basic": self = .BasicOrAuxiliary
        case "Auxiliary": self = .Auxiliary
        case "Basic": self = .Basic
        case "Specialized": self = .Specialized
        default: return nil
        }
    }
    
    var name: String {
        switch self {
        case BasicOrAuxiliary: return "Basic or Auxiliary"
        case Auxiliary: return "Auxiliary"
        case Basic: return "Basic"
        case Specialized: return "Specialized"
        }
    }
}

extension Exercise.SkillLevel {
    init?(name: String) {
        switch name {
        case "Beginer": self = .Beginer
        case "Intermediate": self = .Intermediate
        case "Advanced": self = .Advanced
        default: return nil
        }
    }
    
    var name: String {
        switch self {
        case Beginer: return "Beginer"
        case Intermediate: return "Intermediate"
        case Advanced: return "Advanced"
        }
    }
}
