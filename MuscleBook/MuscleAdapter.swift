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

extension Muscle: KeyedModelType {
    typealias Adapter = MuscleAdapter

    var identifier: Int64? {
        return rawValue
    }
}

extension Muscle: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> Muscle {
        return Muscle(rawValue: intValue)!
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}

enum MuscleAdapter: KeyedAdapterType {

    typealias Model = Muscle
    static let search = VirtualTable("muscle_search")

    /* Columns */

    static let muscleID = Expression<Int64>("muscle_id")
    static let name = Expression<String>("name")
    static let fmaID = Expression<String?>("fma_id")
    static let synonyms = Expression<ArrayBox<String>>("synonyms")
    static let isMuscleGroup = Expression<Bool>("is_muscle_group")

    static let identifier = muscleID

    static func mapRow(row: Row) -> Model {
        return Muscle(rawValue: row[muscleID])!
    }

}

extension MuscleAdapter {

    static func find(muscleID muscleID: Int64) -> Muscle? {
        return Muscle(rawValue: muscleID)
    }

    static func find(name: String) throws -> [Muscle] {
        let query: QueryType = search.select(muscleID).match("*"+name+"*")
        let res = Array(try db.prepare(query))
        return res.flatMap{Muscle(rawValue: $0[muscleID])}
    }

    static func all() throws -> [Muscle] {
        return Muscle.allMuscles
    }

    static func count() -> Int {
        return Muscle.allMuscles.count
    }
}

