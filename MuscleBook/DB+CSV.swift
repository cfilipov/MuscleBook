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

// TODO: CSV import/export needs lots of attention
extension DB {

    func importCSV(type: Workset.Type, fromURL url: NSURL) throws -> Int {
        let importer = WorksetCSVImporter(url: url)
        return try importer.importCSV()
    }

    func exportCSV(type: Workset.Type, toURL url: NSURL) throws {
        let writer = CHCSVWriter(forWritingToCSVFile: url.path)
        writer.writeField("Date")
        writer.writeField("WorkoutID")
        writer.writeField("ExerciseID")
        writer.writeField("Exercise")
        writer.writeField("Reps")
        writer.writeField("Weight")
        writer.writeField("Duration")
        writer.finishLine()
        try all(Workset).forEach { workset in
            writer.writeField(workset.input.startTime.datatypeValue)
            writer.writeField(workset.workoutID.description)
            writer.writeField(workset.input.exerciseID?.description ?? "")
            writer.writeField(workset.input.exerciseName)
            writer.writeField(workset.input.reps?.description ?? "")
            writer.writeField(workset.input.weight?.description ?? "")
            writer.writeField(workset.input.duration?.description ?? "")
            writer.finishLine()
        }
    }

}