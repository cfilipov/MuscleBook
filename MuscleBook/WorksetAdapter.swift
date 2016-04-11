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

extension Workset: KeyedModelType, DateModelType {
    typealias Adapter = WorksetAdapter

    var identifier: Int64? {
        return worksetID
    }
}

enum WorksetAdapter: TableAdapterType, KeyedAdapterType, DateAdapterType {

    typealias Model = Workset
    static let table: SchemaType = Table("workset")

    /* Columns */

    static let worksetID = Expression<Int64>("workset_id")
    static let exerciseID = Expression<Int64?>("exercise_id")
    static let workoutID = Expression<Int64>("workout_id")
    static let exerciseName = Expression<String>("exercise_name")
    static let date = Expression<NSDate>("date")
    static let reps = Expression<Int>("reps")
    static let weight = Expression<Double?>("weight")
    static let duration = Expression<Double?>("duration")
    static let e1RM = Expression<Double?>("e1rm")
    static let maxE1RM = Expression<Double?>("max_e1rm")
    static let maxDuration = Expression<Double?>("max_duration")

    static let identifier = worksetID

    static func setters(model: Model) -> [SQLite.Setter] {
        precondition(model.workoutID != nil)
        return [
            exerciseName <- model.exerciseName,
            exerciseID <- model.exerciseID,
            workoutID <- model.workoutID!,
            date <- model.date,
            reps <- model.reps,
            weight <- model.weight,
            duration <- model.duration,
            e1RM <- model.e1RM,
            maxE1RM <- model.maxE1RM,
            maxDuration <- model.maxDuration
        ]
    }

    static func mapRow(row: Row) -> Model {
        return Workset(
            worksetID: row[worksetID],
            exerciseID: row[exerciseID],
            workoutID: row[workoutID],
            exerciseName: row[exerciseName],
            date: row[date],
            reps: row[reps],
            weight: row[weight],
            duration: row[duration],
            e1RM: row[e1RM],
            maxE1RM: row[maxE1RM],
            maxDuration: row[maxDuration]
        )
    }
    
}

extension WorksetAdapter {

    static func all() throws -> AnySequence<Workset> {
        let rows = try db.prepare(
            table.order(date.desc)
        )
        return rows.adapterOf(Workset)
    }

    static func all(date date: NSDate) throws -> AnySequence<Workset> {
        let rows = try db.prepare(
            table.filter(self.date.day == date.day)
        )
        return rows.adapterOf(Workset)
    }

    static func all(workoutID workoutID: Int64) throws -> AnySequence<Workset> {
        let rows = try db.prepare(
            table.filter(self.workoutID == workoutID)
        )
        return rows.adapterOf(Workset)
    }

    static func dateRange(workoutID workoutID: Int64) -> (NSDate, NSDate)? {
        let row = db.pluck(table
            .select(date.min, date.max)
            .filter(self.workoutID == workoutID)
            .limit(1)
        )
        guard let min = row?[date.min] else { return nil }
        guard let max = row?[date.max] else { return nil }
        return (min, max)
    }

    static func unknownExercises() throws -> AnySequence<ExerciseReference> {
        let query = table.select(exerciseName).filter(exerciseID == nil).group(exerciseName)
        let rows = try db.prepare(query)
        return AnySequence { Void -> AnyGenerator<ExerciseReference> in
            let generator = rows.generate()
            return AnyGenerator {
                guard let row = generator.next() else { return nil }
                return ExerciseReference(exerciseID: nil, name: row[exerciseName])
            }
        }
    }

    static func findMax1RM(exerciseID exerciseID: Int64, todate date: NSDate = NSDate()) -> Workset? {
        let query = table
            .filter(
                self.date.localDay < date.localDay &&
                    self.exerciseID == exerciseID &&
                    self.exerciseID != nil
            )
            .order(e1RM.desc)
            .limit(1)
        guard let row = db.pluck(query) else { return nil }
        return Workset.Adapter.mapRow(row)
    }

}
