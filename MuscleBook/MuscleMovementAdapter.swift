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

extension MuscleMovement: KeyedModelType {
    typealias Adapter = MuscleMovementAdapter

    var identifier: Int64? {
        return muscleMovementID
    }
}

enum MuscleMovementAdapter: KeyedAdapterType, TableAdapterType {
    typealias Model = MuscleMovement
    static let table: SchemaType = Table("muscle_movement")

    /* Columns */

    static let muscleMovementID = Expression<Int64>("muscle_movement_id")
    static let exerciseID = Expression<Int64>("exercise_id")
    static let classificationID = Expression<MuscleMovement.Classification>("muscle_movement_class_id")
    static let muscleName = Expression<String>("muscle_name")
    static let muscleID = Expression<Muscle?>("muscle_id")

    static let identifier = muscleMovementID

    static func setters(model: Model) -> [SQLite.Setter] {
        return [
            exerciseID <- model.exerciseID!,
            classificationID <- model.classification,
            muscleName <- model.muscleName,
            muscleID <- model.muscle
        ]
    }

    static func mapRow(row: Row) -> Model {
        return MuscleMovement(
            muscleMovementID: row[muscleMovementID],
            exerciseID: row[exerciseID],
            classification: row.get(classificationID),
            muscleName: row[muscleName],
            muscle: row.get(muscleID)
        )
    }

}

extension MuscleMovementAdapter {

    static func find(exerciseID exerciseID: Int64) throws -> AnySequence<MuscleMovement> {
        let query = table.filter(self.exerciseID == exerciseID)
        return try db.prepare(query).adapterOf(MuscleMovement)
    }

    static func findIncomplete() throws -> AnySequence<MuscleMovement> {
        let query = table.filter(muscleID == nil).group(muscleName)
        return try db.prepare(query).adapterOf(MuscleMovement)
    }

}
