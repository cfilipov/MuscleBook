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

extension Exercise {
    enum SortType: Int {
        case Alphabetical = 0
        case Count

        private func column(scope scope: SchemaType) -> Expressible {
            typealias E = Exercise.Schema
            typealias W = Workset.Schema
            switch self {
            case .Alphabetical: return scope[E.name]
            case .Count: return W.workoutID.distinct.count.desc
            }
        }
    }
}

extension DB {

    func all(type: Exercise.Type) throws -> AnySequence<Exercise> {
        return try db.prepare(Exercise.Schema.table)
    }

    func all(type: Exercise.Type, sort: Exercise.SortType) throws -> [ExerciseReference] {
        typealias R = ExerciseReference.Schema
        typealias E = Exercise.Schema
        typealias W = Workset.Schema

        let rows = try db.prepare(E.table
            .select(E.table[E.exerciseID], E.table[E.name], W.workoutID.distinct.count)
            .join(.LeftOuter, W.table, on: W.table[W.exerciseID] == E.table[E.exerciseID])
            .group(E.table[E.exerciseID])
            .order(sort.column(scope: E.table))
        )
        return rows.map {
            return ExerciseReference(
                exerciseID: $0[R.exerciseID],
                name: $0[R.name],
                count: $0[W.workoutID.distinct.count]
            )
        }
    }

    func count(type: Exercise.Type) -> Int {
        return db.scalar(Exercise.Schema.table.count)
    }

    func count(type: Exercise.Type, exerciseID: Int64) -> Int {
        typealias WS = Workset.Schema
        return db.scalar(WS.table.select(WS.exerciseID.count).filter(WS.exerciseID == exerciseID))
    }

    func dereference(ref: ExerciseReference) -> Exercise? {
        guard let exerciseID = ref.exerciseID else { return nil }
        typealias S = Exercise.Schema
        let query = S.table.filter(S.exerciseID == exerciseID)
        return db.pluck(query)
    }

    func find(exactName name: String) -> ExerciseReference? {
        typealias E = Exercise.Schema
        return db.pluck(E.search
            .select(E.exerciseID, E.name)
            .filter(E.name == name)
        )
    }

    func find(exerciseID exerciseID: Int64) throws -> AnySequence<MuscleMovement> {
        return try db.prepare(
            MuscleMovement.Schema.table.filter(
                MuscleMovement.Schema.exerciseID == exerciseID
            )
        )
    }

    func findUnknownExercises() throws -> AnySequence<ExerciseReference> {
        let query = Workset.Schema.table
            .select(Workset.Schema.exerciseName)
            .filter(Workset.Schema.exerciseID == nil)
            .group(Workset.Schema.exerciseName)
        return try db.prepare(query)
    }

    func get(type: ExerciseReference.Type, date: NSDate) throws -> AnySequence<ExerciseReference> {
        typealias WS = Workset.Schema
        return try db.prepare(WS.table
            .select(WS.exerciseID, WS.exerciseName)
            .filter(WS.startTime.localDay == date.localDay)
            .group(WS.exerciseID)
        )
    }

    func match(name name: String, sort: Exercise.SortType) throws -> [ExerciseReference] {
        typealias E = Exercise.Schema
        typealias W = Workset.Schema
        let rows = try db.prepare(E.search
            .select(E.search[E.exerciseID], E.search[E.name], W.workoutID.distinct.count)
            .join(.LeftOuter, W.table, on: W.table[W.exerciseID] == E.search[E.exerciseID])
            .group(E.search[E.exerciseID])
            .match("*"+name+"*")
            .order(sort.column(scope: E.search))
        )
        return rows.map {
            return ExerciseReference(
                exerciseID: $0[E.search[E.exerciseID]],
                name: $0[E.name],
                count: $0[W.workoutID.distinct.count]
            )
        }
    }

    func save(exercise: Exercise) throws {
        try db.transaction { [unowned self] in
            try self.db.run(
                Exercise.Schema.table.insert(or: .Replace, exercise)
            )
            for movement in exercise.muscles! {
                try self.db.run(
                    MuscleMovement.Schema.table.insert(movement)
                )
            }
            try self.db.run(
                Exercise.Schema.search.insert(or: .Replace, exercise.exerciseReference)
            )
        }
    }

    func totalExercisesPerformed(sinceDate date: NSDate) -> Int {
        typealias W = Workset.Schema
        return db.scalar(W.table
            .select(W.exerciseID.distinct.count)
            .filter(W.startTime.localDay >= date)
        )
    }
    
}