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

extension Exercise: KeyedModelType {
    typealias Adapter = ExerciseAdapter

    var identifier: Int64? {
        return exerciseID
    }
}

enum ExerciseAdapter: KeyedAdapterType, TableAdapterType {
    
    typealias Model = Exercise
    static let table: SchemaType = Table("exercise")
    static let search = VirtualTable("exercise_search")

    /* Columns */
    
    static let exerciseID = Expression<Int64>("exercise_id")
    static let name = Expression<String>("name")
    static let equipment = Expression<ArrayBox<String>>("equipment")
    static let gif = Expression<String?>("gif")
    static let force = Expression<String?>("force")
    static let level = Expression<String?>("level")
    static let mechanics = Expression<String?>("mechanics")
    static let type = Expression<String>("type")
    static let instructions = Expression<ArrayBox<String>?>("instructions")
    static let link = Expression<String>("link")
    static let source = Expression<String?>("source")

    static let identifier = exerciseID

    static func setters(model: Model) -> [SQLite.Setter] {
        return [
            name <- model.name,
            equipment <- ArrayBox(array: model.equipment),
            gif <- model.gif,
            force <- model.force,
            level <- model.level,
            mechanics <- model.mechanics,
            type <- model.type,
            instructions <- ArrayBox(array: model.instructions ?? []),
            link <- model.link,
            source <- model.source
        ]
    }

    static func mapRow(row: Row) -> Model {
        return Exercise(
            exerciseID: row[exerciseID],
            name: row[name],
            equipment: row.get(self.equipment).array,
            gif: row[gif],
            force: row[force],
            level: row[level],
            muscles: nil,
            mechanics: row[mechanics],
            type: row[type],
            instructions: row.get(self.instructions)?.array,
            link: row[link],
            source: row[source]
        )
    }

}

extension ExerciseAdapter {

    static func save(item: Exercise) throws -> Int64 {
        let rowid = try db.run(
            table.insert(setters(item))
        )
        try db.run(
            search.insert(
                or: .Replace,
                exerciseID <- rowid,
                name <- item.name
            )
        )
        return rowid
    }

    static func find(exactMatchName name: String) throws -> ExerciseReference? {
        let query: QueryType = search
            .select(exerciseID, self.name)
            .filter(self.name == name)
            .limit(1)
        guard let row = db.pluck(query) else { return nil }
        return ExerciseReference.Adapter.mapRow(row)
    }

    static func find(name name: String) throws -> AnySequence<ExerciseReference> {
        let query: QueryType = search
            .select(exerciseID, self.name)
            .match("*"+name+"*")
        return try db.prepare(query).adapterOf(ExerciseReference)
    }

}

extension ExerciseAdapter {

    func importFromYAML(path: String) throws {
        Profiler.trace("Loading Exercises").start()
        let exercises = Exercise.fromYAML(path)
        for ex in exercises {
            let rowid = try Exercise.Adapter.save(ex)
            try ex.muscles?.forEach { m in
                try MuscleMovement.Adapter.save(
                    MuscleMovement(
                        muscleMovementID: m.muscleMovementID,
                        exerciseID: rowid,
                        classification: m.classification,
                        muscleName: m.muscleName,
                        muscle: try Muscle.Adapter.find(m.muscleName).first
                    )
                )
            }
        }
        Profiler.trace("Loading Exercises").end()
        let muscles = try MuscleMovement.Adapter.findIncomplete()
        muscles.forEach{print("Muscle not found: \($0.muscleName)")}
    }

}
