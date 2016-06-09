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
        let name = aDecoder.decodeObjectForKey("Name") as! String
        let equipment = aDecoder.decodeObjectForKey("Equipment") as! String
        let gif = aDecoder.decodeObjectForKey("Gif") as? String
        let force = aDecoder.decodeObjectForKey("Force") as? String
        let level = aDecoder.decodeObjectForKey("Level") as? String
        let musclesCoder = aDecoder.decodeObjectForKey("Muscles") as! MuscleMovementCoder
        let mechanics = aDecoder.decodeObjectForKey("Mechanics") as? String
        let type = aDecoder.decodeObjectForKey("Type") as! String
        let instructions = aDecoder.decodeObjectForKey("Instructions") as? [String]
        let link = aDecoder.decodeObjectForKey("Link") as! String
        let source = aDecoder.decodeObjectForKey("Source") as? String
        value = Exercise(
            exerciseID: nil,
            name: name,
            inputOptions: InputOptions.DefaultOptions, // TODO: Fixme
            equipment: Exercise.Equipment(name: equipment)!,
            gif: gif,
            force: force,
            level: level,
            muscles: musclesCoder.muscleMovements(),
            mechanics: mechanics,
            type: type,
            instructions: instructions,
            link: link,
            source: source
        )
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.name, forKey: "Name")
        aCoder.encodeObject(value.equipment.name, forKey: "Equipment")
        aCoder.encodeObject(value.gif, forKey: "Gif")
        aCoder.encodeObject(value.force, forKey: "Force")
        aCoder.encodeObject(value.level, forKey: "Level")
        let musclesCoder = MuscleMovementCoder(movements: value.muscles!)
        aCoder.encodeObject(musclesCoder, forKey: "Muscles")
        aCoder.encodeObject(value.mechanics, forKey: "Mechanics")
        aCoder.encodeObject(value.type, forKey: "Type")
        aCoder.encodeObject(value.instructions, forKey: "Instructions")
        aCoder.encodeObject(value.link, forKey: "Link")
        aCoder.encodeObject(value.source, forKey: "Source")
    }
    
}