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

private func objectToMovement(obj: AnyObject, _ classification: MuscleMovement.Classification, _ exerciseID: Int64) -> MuscleMovement {
    var muscle: Muscle? = nil
    if let muscleID = obj as? NSInteger {
        muscle = Muscle(rawValue: Int64(muscleID))
    }
    var muscleName: String? = nil
    if let name = obj as? NSString {
        muscleName = String(name)
    }
    return MuscleMovement(
        muscleMovementID: nil,
        exerciseID: exerciseID,
        classification: classification,
        muscleName: muscle?.name ?? muscleName!,
        muscle: muscle
    )
}

@objc class MuscleMovementCoder: NSObject, NSCoding {

    let target: NSArray
    let agonists: NSArray?
    let antagonists: NSArray?
    let synergists: NSArray?
    let stabilizers: NSArray?
    let dynamicStabilizers: NSArray?
    let antagonistStabilizers: NSArray?
    let other: NSArray?

    required init?(coder aDecoder: NSCoder) {
        self.target = (aDecoder.decodeObjectForKey("Target") as? NSArray) ?? []
        self.agonists = aDecoder.decodeObjectForKey("Agonists") as? NSArray
        self.antagonists = aDecoder.decodeObjectForKey("Antagonists") as? NSArray
        self.synergists = aDecoder.decodeObjectForKey("Synergists") as? NSArray
        self.stabilizers = aDecoder.decodeObjectForKey("Stabilizers") as? NSArray
        self.dynamicStabilizers = aDecoder.decodeObjectForKey("Dynamic Stabilizers") as? NSArray
        self.antagonistStabilizers = aDecoder.decodeObjectForKey("Antagonist Stabilizer") as? NSArray
        self.other = aDecoder.decodeObjectForKey("Other") as? NSArray
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.target, forKey: "Target")
        if let agonists = self.agonists {
            aCoder.encodeObject(agonists, forKey: "Agonists")
        }
        if let antagonists = self.antagonists {
            aCoder.encodeObject(antagonists, forKey: "Antagonists")
        }
        if let synergists = self.synergists {
            aCoder.encodeObject(synergists, forKey: "Synergists")
        }
        if let stabilizers = self.stabilizers {
            aCoder.encodeObject(stabilizers, forKey: "Stabilizers")
        }
        if let dynamicStabilizers = self.dynamicStabilizers {
            aCoder.encodeObject(dynamicStabilizers, forKey: "Dynamic Stabilizers")
        }
        if let antagonistStabilizer = self.antagonistStabilizers {
            aCoder.encodeObject(antagonistStabilizer, forKey: "Antagonist Stabilizers")
        }
        if let other = self.other {
            aCoder.encodeObject(other, forKey: "Other")
        }
    }

    init(movements: [MuscleMovement]) {
        var dict: [MuscleMovement.Classification: NSMutableArray] = [:]
        for movement in movements {
            let items = (dict[movement.classification] ?? NSMutableArray())
            if let muscle = movement.muscle {
                items.addObject(Int(muscle.rawValue))
            } else {
                items.addObject(movement.muscleName)
            }
            dict[movement.classification] = items
        }
        self.target = dict[MuscleMovement.Classification.Target] ?? []
        self.agonists = dict[MuscleMovement.Classification.Agonist]
        self.antagonists = dict[MuscleMovement.Classification.Antagonist]
        self.synergists = dict[MuscleMovement.Classification.Synergist]
        self.stabilizers = dict[MuscleMovement.Classification.Stabilizer]
        self.dynamicStabilizers = dict[MuscleMovement.Classification.DynamicStabilizer]
        self.antagonistStabilizers = dict[MuscleMovement.Classification.AntagonistStabilizer]
        self.other = dict[MuscleMovement.Classification.Other]
    }

    func muscleMovements(exerciseID: Int64) -> [MuscleMovement] {
        var movement: [MuscleMovement] = []
        target.forEach { movement.append(objectToMovement($0, .Target, exerciseID)) }
        agonists?.forEach { movement.append(objectToMovement($0, .Agonist, exerciseID)) }
        antagonists?.forEach { movement.append(objectToMovement($0, .Antagonist, exerciseID)) }
        synergists?.forEach { movement.append(objectToMovement($0, .Synergist, exerciseID)) }
        stabilizers?.forEach { movement.append(objectToMovement($0, .Stabilizer, exerciseID)) }
        dynamicStabilizers?.forEach { movement.append(objectToMovement($0, .DynamicStabilizer, exerciseID)) }
        antagonistStabilizers?.forEach { movement.append(objectToMovement($0, .AntagonistStabilizer, exerciseID)) }
        other?.forEach { movement.append(objectToMovement($0, .Other, exerciseID)) }
        return movement
    }

}
