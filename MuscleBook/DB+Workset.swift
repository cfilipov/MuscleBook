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

extension DB {

    func all(type: Workset.Type) throws -> AnySequence<Workset> {
        return try db.prepare(
            Workset.Schema.table.order(Workset.Schema.startTime.desc)
        )
    }

    func count(type: Workset.Type) -> Int {
        return db.scalar(Workset.Schema.table.count)
    }
    
    func delete(workset: Workset) throws {
        precondition(workset.worksetID != 0)
        precondition(workset.workoutID != 0)
        typealias WS = Workset.Schema
        typealias WO = Workout.Schema
        try db.transaction { [unowned self] in
            try self.db.run(WS.table.filter(WS.worksetID == workset.worksetID).delete())
            let count = self.db.scalar(WS.table.select(WS.worksetID.count).filter(WS.workoutID == workset.workoutID))
            if count == 0 {
                try self.db.run(WO.table.filter(WO.workoutID == workset.workoutID).delete())
            } else {
                try self.recalculate(workoutID: workset.workoutID)
            }
        }
    }

    func get(type: Workset.Type, worksetID: Int64) -> Workset? {
        return db.pluck(Workset.Schema.table.filter(Workset.Schema.worksetID == worksetID))
    }

    func newest(type: Workset.Type) -> Workset? {
        typealias W = Workset.Schema
        return db.pluck(W.table.order(W.startTime.desc))
    }
    
    func save(workset: Workset) throws -> Int64 {
        precondition(workset.worksetID == 0)
        precondition(workset.workoutID != 0)
        return try self.db.run(Workset.Schema.table.insert(workset))
    }

    func save(input: Workset.Input) throws -> Workset {
        let records = get(Records.self, input: input)
        let relativeRecords = RelativeRecords(input: input, records: records)
        var workset: Workset?
        var workoutID: Int64 = 0
        try db.transaction {
            workoutID = try self.getOrCreate(Workout.self, input: input)
            assert(workoutID != 0)
            let incompleteWorkset = Workset(
                worksetID: 0,
                workoutID: workoutID,
                input: input,
                calculations: relativeRecords.calculations
            )
            let worksetID = try self.save(incompleteWorkset)
            workset = incompleteWorkset.copy(worksetID: worksetID)
            try self.recalculate(workoutID: workoutID)
        }
        assert(workoutID != 0)
        assert(workset!.worksetID != 0)
        assert(workset!.workoutID != 0)
        return workset!
    }

    func save(worksetInputs: [Workset.Input]) throws {
        try db.transaction {
            for i in worksetInputs {
                try self.save(i)
            }
        }
    }

    func worksets(workoutID workoutID: Int64) throws -> AnySequence<Workset> {
        return try db.prepare(
            Workset.Schema.table.filter(
                Workset.Schema.workoutID == workoutID
            )
        )
    }

    func update(workset workset: Workset, input: Workset.Input) throws -> Workset {
        let records = get(Records.self, input: input)
        let relativeRecords = RelativeRecords(input: input, records: records)
        let newWorkset = workset.copy(input: input, calculations: relativeRecords.calculations)
        try update(newWorkset)
        try recalculateAll(after: newWorkset.input.startTime)
        return newWorkset
    }

    func update(workset: Workset) throws {
        precondition(workset.worksetID != 0)
        precondition(workset.workoutID != 0)
        typealias W = Workset.Schema
        try db.run(W.table
            .filter(W.worksetID == workset.worksetID)
            .update(workset.setters)
        )
    }
    
}