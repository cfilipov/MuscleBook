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

@objc class MuscleMovementCoder: NSObject, NSCoding {

    let target: [String]
    let agonists: [String]?
    let antagonists: [String]?
    let synergists: [String]?
    let stabilizers: [String]?
    let dynamicStabilizers: [String]?
    let antagonistStabilizers: [String]?
    let other: [String]?

    required init?(coder aDecoder: NSCoder) {
        self.target = (aDecoder.decodeObjectForKey("Target") as? [String]) ?? []
        self.agonists = aDecoder.decodeObjectForKey("Agonists") as? [String]
        self.antagonists = aDecoder.decodeObjectForKey("Antagonists") as? [String]
        self.synergists = aDecoder.decodeObjectForKey("Synergists") as? [String]
        self.stabilizers = aDecoder.decodeObjectForKey("Stabilizers") as? [String]
        self.dynamicStabilizers = aDecoder.decodeObjectForKey("Dynamic Stabilizers") as? [String]
        self.antagonistStabilizers = aDecoder.decodeObjectForKey("Antagonist Stabilizer") as? [String]
        self.other = aDecoder.decodeObjectForKey("Other") as? [String]
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
        var dict: [MuscleMovement.Classification: [String]] = [:]
        for movement in movements {
            var items = (dict[movement.classification] ?? [])
            items.append(movement.muscleName)
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

    func muscleMovements() -> [MuscleMovement] {
        var movement: [MuscleMovement] = []
        movement.appendContentsOf(
            target.map { name in
                MuscleMovement(
                    muscleMovementID: nil,
                    exerciseID: nil,
                    classification: MuscleMovement.Classification.Target,
                    muscleName: name,
                    muscle: nil
                )
            }
        )
        movement.appendContentsOf(
            agonists?.map { name in
                MuscleMovement(
                    muscleMovementID: nil,
                    exerciseID: nil,
                    classification: MuscleMovement.Classification.Agonist,
                    muscleName: name,
                    muscle: nil
                )
                } ?? []
        )
        movement.appendContentsOf(
            antagonists?.map { name in
                MuscleMovement(
                    muscleMovementID: nil,
                    exerciseID: nil,
                    classification: MuscleMovement.Classification.Antagonist,
                    muscleName: name,
                    muscle: nil
                )
                } ?? []
        )
        movement.appendContentsOf(
            synergists?.map { name in
                MuscleMovement(
                    muscleMovementID: nil,
                    exerciseID: nil,
                    classification: MuscleMovement.Classification.Synergist,
                    muscleName: name,
                    muscle: nil
                )
                } ?? []
        )
        movement.appendContentsOf(
            stabilizers?.map { name in
                MuscleMovement(
                    muscleMovementID: nil,
                    exerciseID: nil,
                    classification: MuscleMovement.Classification.Stabilizer,
                    muscleName: name,
                    muscle: nil
                )
                } ?? []
        )
        movement.appendContentsOf(
            dynamicStabilizers?.map { name in
                MuscleMovement(
                    muscleMovementID: nil,
                    exerciseID: nil,
                    classification: MuscleMovement.Classification.DynamicStabilizer,
                    muscleName: name,
                    muscle: nil
                )
                } ?? []
        )
        movement.appendContentsOf(
            antagonistStabilizers?.map { name in
                MuscleMovement(
                    muscleMovementID: nil,
                    exerciseID: nil,
                    classification: MuscleMovement.Classification.AntagonistStabilizer,
                    muscleName: name,
                    muscle: nil
                )
                } ?? []
        )
        movement.appendContentsOf(
            other?.map { name in
                MuscleMovement(
                    muscleMovementID: nil,
                    exerciseID: nil,
                    classification: MuscleMovement.Classification.Other,
                    muscleName: name,
                    muscle: nil
                )
                } ?? []
        )
        return movement
    }
}
