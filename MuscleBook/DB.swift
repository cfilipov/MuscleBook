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
import SQLiteMigrationManager

protocol SQLAdaptable {
    init(row: Row)
    var setters: [Setter] { get }
}

// MARK:

private typealias CurrentSchema = Schema20160410215418161

class DB {

    static let sharedInstance = DB()

    static let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask, true
        ).first! + "/musclebook.db"

    private let db: Connection

    private init() {
        do {

            let fileManager = NSFileManager.defaultManager()

            if !fileManager.fileExistsAtPath(DB.path) {
                let bundlePath = BundlePath(name: "musclebook", type: "db")
                try! fileManager.copyItemAtPath(bundlePath, toPath: DB.path)
            }

            db = try Connection(DB.path)

            #if DEBUG
                print("Database: " + DB.path)
                db.trace{print($0)}
            #endif

            let migrationManager = SQLiteMigrationManager(
                db: db,
                migrations: [
                    Schema20160410215418161.migration,
                    // Schema20160524095754146.migration
                ]
            )

            if !migrationManager.hasMigrationsTable() {
                try migrationManager.createMigrationsTable()
            }

            if migrationManager.needsMigration() {
                try migrationManager.migrateDatabase()
            }
            
        } catch {
            fatalError()
        }
    }

}

extension DB {

    func all(type: Workset.Type) throws -> AnySequence<Workset> {
        return try db.prepare(
            Workset.Schema.table.order(Workset.Schema.date.desc)
        )
    }

    func all(type: Exercise.Type) throws -> [ExerciseReference] {
        return Array(
            try db.prepare(
                Exercise.Schema.table.order(Exercise.Schema.name)
            )
        )
    }

    func all(type: Workout.Type) throws -> AnySequence<Workout> {
        return try db.prepare(Workout.Schema.table.order(Workout.Schema.date.desc))
    }

    func save(exercise: Exercise) throws -> Int64 {
        let rowid = try db.run(
            Exercise.Schema.table.insert(exercise)
        )
        try db.run(
            Exercise.Schema.search.insert(or: .Replace, exercise.exerciseReference)
        )
        return rowid
    }

    func save(movement: MuscleMovement) throws -> Int64 {
        return try db.run(MuscleMovement.Schema.table.insert(movement))
    }

    func save(workset: Workset) throws -> Int64 {
        return try db.run(Workset.Schema.table.insert(workset))
    }

    func save(records: [Workset]) throws {
        try db.transaction {
            for w in records {
                try self.save(w)
            }
        }
    }

    func count(type: Exercise.Type) -> Int {
        return db.scalar(Exercise.Schema.table.count)
    }

    func count(type: Muscle.Type) -> Int {
        return Muscle.allMuscles.count
    }

    func count(type: Workset.Type) -> Int {
        return db.scalar(Workset.Schema.table.count)
    }

    func count(type: Workout.Type) -> Int {
        return db.scalar(Workout.Schema.table.count)
    }

    func count(type: Workout.Type, date: NSDate) -> Int {
        return db.scalar(
            Workout.Schema.table.filter(
                Workout.Schema.date.localDay == date.localDay
            ).count
        )
    }

    func countByDay(type: Workout.Type) throws -> [(NSDate, Int)] {
        let cal = NSCalendar.currentCalendar()
        let date = Workout.Schema.date
        let count = Workout.Schema.workoutID.count
        let rows = try db.prepare(
            Workout.Schema.table.select(date, count).group(date.localDay)
        )
        return rows.map { row in
            return (
                cal.startOfDayForDate(row[date]),
                row[count]
            )
        }
    }

    func dereference(ref: ExerciseReference) -> Exercise? {
        guard let exerciseID = ref.exerciseID else { return nil }
        typealias S = Exercise.Schema
        let query = S.table.filter(S.exerciseID == exerciseID)
        return db.pluck(query)
    }

    func get(type: Workout.Type, workoutID: Int64) -> Workout? {
        return db.pluck(Workout.Schema.table.filter(Workout.Schema.workoutID == workoutID))
    }

    func match(name name: String) throws -> AnySequence<ExerciseReference> {
        return try db.prepare(Exercise.Schema.match(name: name))
    }

    func find(exactName name: String) -> ExerciseReference? {
        return db.pluck(Exercise.Schema.find(exactName: name))
    }

    func find(exerciseID exerciseID: Int64) throws -> AnySequence<MuscleMovement> {
        return try db.prepare(
            MuscleMovement.Schema.table.filter(
                MuscleMovement.Schema.exerciseID == exerciseID
            )
        )
    }

    func worksets(workoutID workoutID: Int64) throws -> AnySequence<Workset> {
        return try db.prepare(
            Workset.Schema.table.filter(
                Workset.Schema.workoutID == workoutID
            )
        )
    }

    func nextAvailableRowID(type: Workout.Type) -> Int64 {
        typealias S = Workset.Schema
        let max = db.scalar(S.table.select(S.workoutID.max))
        return (max ?? 0) + 1
    }

    func maxE1RM(exerciseID exerciseID: Int64, todate date: NSDate = NSDate()) -> Workset? {
        return db.pluck(
            Workset.Schema.table
                .filter(
                    Workset.Schema.date.localDay < date.localDay &&
                        Workset.Schema.exerciseID == exerciseID &&
                        Workset.Schema.exerciseID != nil
                )
                .order(Workset.Schema.e1RM.desc)
                .limit(1)
        )
    }

    func volumeByDay() throws -> [(NSDate, Double)] {
        let cal = NSCalendar.currentCalendar()
        return try all(Workout).map { workout in
            let date = cal.startOfDayForDate(workout.date)
            return (date, workout.totalWeight ?? 0)
        }
    }

    func get(type: MuscleWorkSummary.Type, date: NSDate) throws -> [MuscleWorkSummary] {
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

    func get(type: MuscleWorkSummary.Type, workoutID: Int64) throws -> [MuscleWorkSummary] {
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
            writer.writeField(workset.date.datatypeValue)
            writer.writeField(workset.workoutID?.description ?? "")
            writer.writeField(workset.exerciseID?.description ?? "")
            writer.writeField(workset.exerciseName)
            writer.writeField(workset.reps.description)
            writer.writeField(workset.weight?.description ?? "")
            writer.writeField(workset.duration?.description ?? "")
            writer.finishLine()
        }
    }

    func dateRange(workoutID workoutID: Int64) -> (NSDate, NSDate)? {
        let row = db.pluck(Workset.Schema.table
            .select(Workset.Schema.date.min, Workset.Schema.date.max)
            .filter(Workset.Schema.workoutID == workoutID)
            .limit(1)
        )
        guard let min = row?[Workset.Schema.date.min] else { return nil }
        guard let max = row?[Workset.Schema.date.max] else { return nil }
        return (min, max)
    }

    func findUnknownExercises() throws -> AnySequence<ExerciseReference> {
        let query = Workset.Schema.table
            .select(Workset.Schema.exerciseName)
            .filter(Workset.Schema.exerciseID == nil)
            .group(Workset.Schema.exerciseName)
        return try db.prepare(query)
    }

    func startDate(workout: Workout) -> NSDate? {
        let row = db.pluck(Workset.Schema.table
            .select(Workset.Schema.date.min)
            .filter(Workset.Schema.workoutID == workout.workoutID!)
            .limit(1)
        )
        return row?[Workset.Schema.date.min]
    }

    func endDate(workout: Workout) -> NSDate? {
        let row = db.pluck(Workset.Schema.table
            .select(Workset.Schema.date.max)
            .filter(Workset.Schema.workoutID == workout.workoutID!)
            .limit(1)
        )
        return row?[Workset.Schema.date.max]
    }

    func prev(workout: Workout) -> Workout? {
        let date = Workset.Schema.date
        return db.pluck(Workset.Schema.table
            .order(date.desc)
            .filter(date < workout.date)
            .limit(1)
        )
    }

    func next(workout: Workout) -> Workout? {
        let date = Workset.Schema.date
        return db.pluck(Workset.Schema.table
            .order(date.asc)
            .filter(date > workout.date)
            .limit(1)
        )
    }

    func newest(type: Workset.Type) -> Workset? {
        return db.pluck(Workset.Schema.table.order(Workset.Schema.date.desc))
    }

    func delete(workset: Workset) throws -> Int {
        guard let worksetID = workset.worksetID else {
            fatalError("Identifier required to delete workset \(workset)")
        }
        let query = Workset.Schema.table.filter(Workset.Schema.worksetID == worksetID)
        return try db.run(query.delete())
    }

}

// MARK:

extension Exercise: SQLAdaptable {
    typealias Schema = CurrentSchema.Exercise

    init(row: Row) {
        exerciseID = row[Schema.exerciseID]
        name = row[Schema.name]
        equipment = row.get(Schema.equipment).array
        gif = row[Schema.gif]
        force = row[Schema.force]
        level = row[Schema.level]
        muscles = nil
        mechanics = row[Schema.mechanics]
        type = row[Schema.type]
        instructions = row.get(Schema.instructions)?.array
        link = row[Schema.link]
        source = row[Schema.source]
    }

    var setters: [Setter] {
        return [
            Schema.name <- self.name,
            Schema.equipment <- ArrayBox(array: self.equipment),
            Schema.gif <- self.gif,
            Schema.force <- self.force,
            Schema.level <- self.level,
            Schema.mechanics <- self.mechanics,
            Schema.type <- self.type,
            Schema.instructions <- ArrayBox(array: self.instructions ?? []),
            Schema.link <- self.link,
            Schema.source <- self.source
        ]
    }
}

// MARK:

extension ExerciseReference: SQLAdaptable {
    typealias Schema = CurrentSchema.Exercise

    init(row: Row) {
        exerciseID = row[Schema.exerciseID]
        name = row[Schema.name]
    }

    var setters: [Setter] {
        return [
            Schema.exerciseID <- rowid,
            Schema.name <- self.name
        ]
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

extension Muscle: SQLAdaptable {
    typealias Schema = CurrentSchema.Muscle

    init(row: Row) {
        self = Muscle(rawValue: row[Schema.muscleID])!
    }

    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Activation: SQLite.Value {
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    static func fromDatatypeValue(intValue: Int64) -> Activation {
        return Activation(rawValue: intValue)!
    }
    var datatypeValue: Int64 {
        return self.rawValue
    }
}

//extension Activation: SQLAdaptable {
//    typealias Schema = CurrentSchema.Activation
//
//    init(row: Row) {
//        self = Activation(rawValue: row[Schema.activationID])!
//    }
//
//    var setters: [Setter] {
//        fatalError("This table cannot be modified")
//    }
//}

extension MuscleMovement: SQLAdaptable {
    typealias Schema = CurrentSchema.MuscleMovement

    init(row: Row) {
        muscleMovementID = row[Schema.muscleMovementID]
        exerciseID = row[Schema.exerciseID]
        classification = row.get(Schema.muscleMovementClassID)
        muscleName = row[Schema.muscleName]
        muscle = row.get(Schema.muscleID)
    }

    var setters: [Setter] {
        return [
            Schema.exerciseID <- self.exerciseID!,
            Schema.muscleMovementClassID <- self.classification,
            Schema.muscleName <- self.muscleName,
            Schema.muscleID <- self.muscle
        ]
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

extension MuscleMovement.Classification: SQLAdaptable {
    typealias Schema = CurrentSchema.MuscleMovementClassification

    init(row: Row) {
        self = MuscleMovement.Classification(rawValue: row[Schema.muscleMovementClassID])!
    }

    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Workout: SQLAdaptable {
    typealias Schema = CurrentSchema.Workout

    init(row: Row) {
        workoutID = row[Schema.workoutID]
        date = row[Schema.date]
        totalWeight = row[Schema.weight]
        totalDuration = row[Schema.duration]
        count = row[Schema.reps]
    }

    var setters: [Setter] {
        fatalError("This table cannot be modified")
    }
}

extension Workset: SQLAdaptable {
    typealias Schema = CurrentSchema.Workset

    init(row: Row) {
        worksetID = row[Schema.worksetID]
        exerciseID = row[Schema.exerciseID]
        workoutID = row[Schema.workoutID]
        exerciseName = row[Schema.exerciseName]
        date = row[Schema.date]
        reps = row[Schema.reps]
        weight = row[Schema.weight]
        duration = row[Schema.duration]
        e1RM = row[Schema.e1RM]
        maxE1RM = row[Schema.maxE1RM]
        maxDuration = row[Schema.maxDuration]
    }

    var setters: [Setter] {
        return [
            Schema.exerciseName <- exerciseName,
            Schema.exerciseID <- exerciseID,
            Schema.workoutID <- workoutID!,
            Schema.date <- date,
            Schema.reps <- reps,
            Schema.weight <- weight,
            Schema.duration <- duration,
            Schema.e1RM <- e1RM,
            Schema.maxE1RM <- maxE1RM,
            Schema.maxDuration <- maxDuration
        ]
    }
}
