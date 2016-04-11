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

extension MuscleMovement.Classification: KeyedModelType {
    typealias Adapter = MuscleMovementClassificationAdapter

    var identifier: Int64? {
        return rawValue
    }
}

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

enum MuscleMovementClassificationAdapter: KeyedAdapterType {
    typealias Model = MuscleMovement.Classification
    static let table = Table("muscle_movement_classification")

    /* Columns */

    static let cMuscleMovementClassID = Expression<Int64>("muscle_movement_class_id")
    static let name = Expression<String>("name")

    static let identifier = cMuscleMovementClassID

    static func mapRow(row: Row) -> Model {
        return Model(rawValue: row[cMuscleMovementClassID])!
    }

}

extension MuscleMovement.Classification {

    static func count() -> Int {
        return MuscleMovement.Classification.all.count
    }

}