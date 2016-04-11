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

extension MuscleWorkSummary {
    typealias Adapter = MuscleWorkSummaryAdapter
}

enum MuscleWorkSummaryAdapter {
    typealias Model = MuscleWorkSummary
}

extension MuscleWorkSummaryAdapter {

    static func forDay(date: NSDate) throws -> [MuscleWorkSummary] {
        let query = " SELECT " +
            "\n     m.muscle_id, " +
            "\n     w.exercise_id, " +
            "\n     w.exercise_name, " +
            "\n     m.muscle_movement_class_id, " +
            "\n     avg(e1rm) as 'e1rm', " +
            "\n     max_e1rm, " +
            "\n     " +
            "\n     ( -- 'avg_e1rm' " +
            "\n         SELECT avg(e1rm) " +
            "\n         FROM workset as ws " +
            "\n         WHERE date(date, 'localtime') < date(?, 'localtime') " +
            "\n             AND ws.exercise_id = m.exercise_id " +
            "\n     ) as 'avg_e1rm', " +
            "\n     " +
            "\n     ( -- 'volume' " +
            "\n         SELECT sum(reps * weight) " +
            "\n         FROM workset as ws " +
            "\n         WHERE date(date, 'localtime') = date(?, 'localtime') " +
            "\n             AND ws.exercise_id = m.exercise_id " +
            "\n     ) as 'volume', " +
            "\n     " +
            "\n     ( -- 'max_volume' " +
            "\n         SELECT max(reps * weight) " +
            "\n         FROM workset as ws " +
            "\n         WHERE date(date, 'localtime') < date(?, 'localtime') " +
            "\n             AND ws.exercise_id = m.exercise_id " +
            "\n         GROUP BY ws.workout_id " +
            "\n         ORDER BY max(reps * weight) DESC " +
            "\n         LIMIT 1 " +
            "\n     ) as 'max_volume', " +
            "\n     " +
            "\n     ( -- 'avg_volume' " +
            "\n         SELECT avg(reps * weight) " +
            "\n         FROM workset as ws " +
            "\n         WHERE date(date, 'localtime') < date(?, 'localtime') " +
            "\n             AND ws.exercise_id = m.exercise_id " +
            "\n     ) as 'avg_volume' " +
            "\n     " +
            "\n FROM workset as w " +
            "\n JOIN muscle_movement as m " +
            "\n     ON w.exercise_id = m.exercise_id " +
            "\n WHERE date(date, 'localtime') == date(?, 'localtime') " +
            "\n     AND w.exercise_id NOT NULL AND m.muscle_id NOT NULL " +
        "\n GROUP BY muscle_movement_class_id, m.muscle_id "
        let db = DB.sharedInstance.connection
        let stmt = try db.prepare(query).generate()
        stmt.bind(date.datatypeValue, date.datatypeValue, date.datatypeValue, date.datatypeValue, date.datatypeValue)
        return stmt.map { row in
            return MuscleWorkSummary(
                muscle: Muscle(rawValue: row[0] as! Int64)!,
                exercise: ExerciseReference(exerciseID: (row[1] as! Int64), name: (row[2] as! String)),
                movementClass: MuscleMovement.Classification(rawValue: row[3] as! Int64)!,
                e1RM: row[4] as? Double,
                maxE1RM: row[5] as? Double,
                avgE1RM: row[6] as? Double,
                volume: row[7] as! Double,
                maxVolume: row[8] as? Double,
                avgVolume: row[9] as? Double
            )
        }
    }

    static func forWorkout(workoutID: Int64) throws -> [MuscleWorkSummary] {
        let query = " SELECT " +
            "\n     m.muscle_id, " +
            "\n     w.exercise_id, " +
            "\n     w.exercise_name, " +
            "\n     m.muscle_movement_class_id, " +
            "\n     avg(e1rm) as 'e1rm', " +
            "\n     max_e1rm, " +
            "\n     " +
            "\n     ( -- 'avg_e1rm' " +
            "\n         SELECT avg(e1rm) " +
            "\n         FROM workset as ws " +
            "\n         WHERE date(date, 'localtime') < date(w.date, 'localtime') " +
            "\n             AND ws.exercise_id = m.exercise_id " +
            "\n     ) as 'avg_e1rm', " +
            "\n     " +
            "\n     ( -- 'volume' " +
            "\n         SELECT sum(reps * weight) " +
            "\n         FROM workset as ws " +
            "\n         WHERE w.workout_id == ? " +
            "\n             AND ws.exercise_id = m.exercise_id " +
            "\n     ) as 'volume', " +
            "\n     " +
            "\n     ( -- 'max_volume' " +
            "\n         SELECT max(reps * weight) " +
            "\n         FROM workset as ws " +
            "\n         WHERE date(date, 'localtime') < date(w.date, 'localtime') " +
            "\n             AND ws.exercise_id = m.exercise_id " +
            "\n         GROUP BY ws.workout_id " +
            "\n         ORDER BY max(reps * weight) DESC " +
            "\n         LIMIT 1 " +
            "\n     ) as 'max_volume', " +
            "\n     " +
            "\n     ( -- 'avg_volume' " +
            "\n         SELECT avg(reps * weight) " +
            "\n         FROM workset as ws " +
            "\n         WHERE date(date, 'localtime') < date(w.date, 'localtime') " +
            "\n             AND ws.exercise_id = m.exercise_id " +
            "\n     ) as 'avg_volume' " +
            "\n     " +
            "\n FROM workset as w " +
            "\n JOIN muscle_movement as m " +
            "\n     ON w.exercise_id = m.exercise_id " +
            "\n WHERE w.workout_id == ? " +
            "\n     AND w.exercise_id NOT NULL AND m.muscle_id NOT NULL " +
        "\n GROUP BY muscle_movement_class_id, m.muscle_id "
        let db = DB.sharedInstance.connection
        let stmt = try db.prepare(query).generate()
        stmt.bind(workoutID, workoutID)
        return stmt.map { row in
            return MuscleWorkSummary(
                muscle: Muscle(rawValue: row[0] as! Int64)!,
                exercise: ExerciseReference(exerciseID: (row[1] as! Int64), name: (row[2] as! String)),
                movementClass: MuscleMovement.Classification(rawValue: row[3] as! Int64)!,
                e1RM: row[4] as? Double,
                maxE1RM: row[5] as? Double,
                avgE1RM: row[6] as? Double,
                volume: row[7] as! Double,
                maxVolume: row[8] as? Double,
                avgVolume: row[9] as? Double
            )
        }
    }

}