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

extension ExerciseReference: KeyedModelType {
    typealias Adapter = ExerciseReferenceAdapter

    var identifier: Int64? {
        return exerciseID
    }
}

enum ExerciseReferenceAdapter: KeyedAdapterType, TableAdapterType {

    typealias Model = ExerciseReference
    static let table: SchemaType = Table("exercise")
    static let search = VirtualTable("exercise_search")

    /* Columns */

    static let exerciseID = Expression<Int64>("exercise_id")
    static let name = Expression<String>("name")

    static let identifier = exerciseID

    static func setters(model: Model) -> [SQLite.Setter] {
        fatalError("Can't save an ExerciseReference")
    }

    static func mapRow(row: Row) -> Model {
        return ExerciseReference(
            exerciseID: row[exerciseID],
            name: row[name]
        )
    }

}

extension ExerciseReferenceAdapter {

    static func all() throws -> AnySequence<ExerciseReference> {
        return try db
            .prepare(table.order(name))
            .adapterOf(ExerciseReference)
    }

}
