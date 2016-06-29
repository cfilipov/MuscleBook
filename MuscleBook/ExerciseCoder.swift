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

extension Exercise: ValueCoding {
    typealias Coder = ExerciseCoder
}

@objc class ExerciseCoder: NSObject, NSCoding, CodingType {

    let value: Exercise

    required init(_ v: Exercise) {
        value = v
    }

    required init?(coder aDecoder: NSCoder) {
        let identifier = aDecoder.decodeObjectForKey("Identifier") as! NSNumber
        let name = aDecoder.decodeObjectForKey("Name") as! String
        let input = aDecoder.decodeObjectForKey("Input") as! NSNumber
        let equipment = aDecoder.decodeObjectForKey("Equipment") as! String
        let gif = aDecoder.decodeObjectForKey("Gif") as? String
        let force = aDecoder.decodeObjectForKey("Force") as? String
        let level = aDecoder.decodeObjectForKey("Level") as? String
        let musclesCoder = aDecoder.decodeObjectForKey("Muscles") as! MuscleMovementCoder
        let mechanics = aDecoder.decodeObjectForKey("Mechanics") as? String
        let type = aDecoder.decodeObjectForKey("Type") as! String
        let instructions = aDecoder.decodeObjectForKey("Instructions") as? [String]
        let link = aDecoder.decodeObjectForKey("Link") as? String
        let source = aDecoder.decodeObjectForKey("Source") as? String
        value = Exercise(
            exerciseID: identifier.longLongValue,
            name: name,
            inputOptions: Exercise.InputOptions(rawValue: input.longLongValue),
            equipment: Exercise.Equipment(name: equipment)!,
            gif: gif,
            force: force.flatMap { Exercise.Force(name: $0) },
            skillLevel: level.flatMap { Exercise.SkillLevel(name: $0) },
            muscles: musclesCoder.muscleMovements(identifier.longLongValue),
            mechanics: mechanics.flatMap { Exercise.Mechanics(name: $0) },
            exerciseType: Exercise.ExerciseType(name: type)!,
            instructions: instructions,
            link: link,
            source: source
        )
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(NSNumber(longLong: value.exerciseID), forKey: "Identifier")
        aCoder.encodeObject(value.name, forKey: "Name")
        aCoder.encodeObject(NSNumber(longLong: value.inputOptions.rawValue), forKey: "Input")
        aCoder.encodeObject(value.equipment.name, forKey: "Equipment")
        if let gif = value.gif {
            aCoder.encodeObject(gif, forKey: "Gif")
        }
        if let force = value.force {
            aCoder.encodeObject(force.name, forKey: "Force")
        }
        if let level = value.skillLevel {
            aCoder.encodeObject(level.name, forKey: "Level")
        }
        let musclesCoder = MuscleMovementCoder(movements: value.muscles!)
        aCoder.encodeObject(musclesCoder, forKey: "Muscles")
        if let mechanics = value.mechanics {
            aCoder.encodeObject(mechanics.name, forKey: "Mechanics")
        }
        aCoder.encodeObject(value.exerciseType.name, forKey: "Type")
        if let instructions = value.instructions {
            aCoder.encodeObject(instructions, forKey: "Instructions")
        }
        if let link = value.link {
            aCoder.encodeObject(link, forKey: "Link")
        }
        if let source = value.source {
            aCoder.encodeObject(source, forKey: "Source")
        }
    }
    
}