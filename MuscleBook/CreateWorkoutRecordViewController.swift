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

import UIKit
import Eureka

class CreateWorkoutRecordViewController: FormViewController {

    private let db = DB.sharedInstance
    private let workoutID: Int64
    private let callback: Workset? -> Void
    private let formatter = NSDateFormatter()
    private let cal = NSCalendar.currentCalendar()
    private var defaultDate: NSDate
    private var exercise: ExerciseReference?
    private let exerciseSpecified: Bool

    private lazy var workout: Workout? = {
        self.db.get(Workout.self, workoutID: self.workoutID)
    }()

    lazy var minDate: NSDate? = {
        guard let workout = self.workout else { return nil }
        guard let prev = self.db.prev(workout) else { return nil }
        return self.cal.startOfDayForDate(prev.date)
    }()

    lazy var maxDate: NSDate? = {
        guard let
            workout = self.workout,
            next = self.db.next(workout)
            else { return NSDate() }
        return next.date
    }()
    
    init(workoutID: Int64, exercise: ExerciseReference? = nil, defaultDate: NSDate = NSDate(), callback: Workset? -> Void) {
        self.workoutID = workoutID
        self.defaultDate = defaultDate
        if let exercise = exercise {
            exerciseSpecified = true
            self.exercise = exercise
        } else {
            exerciseSpecified = false
            let last = db.newest(Workset)
            self.exercise = last?.exerciseReference
        }
        self.callback = callback
        super.init(style: .Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Data Point"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(CreateWorkoutRecordViewController.cancelButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(CreateWorkoutRecordViewController.saveButtonPressed))
        
        form

            +++ Section()

            <<< SelectExerciseRow("exercise") {
                $0.title = "Exercise"
                $0.value = exercise
                $0.disabled = self.exerciseSpecified ? true : false
                $0.onChange { row in
                    self.form.rowByTag("pr")?.updateCell()
                }
            }

            <<< DateTimeInlineRow("date") {
                let oneDay = NSDateComponents()
                oneDay.day = 1
                $0.minimumDate = self.minDate
                $0.maximumDate = self.maxDate
                $0.value = self.maxDate
                $0.cellUpdate { cell, row in
                    self.formatter.dateStyle = .MediumStyle
                    self.formatter.timeStyle = .NoStyle
                    let dayPart = self.formatter.stringFromDate(row.value!)
                    cell.textLabel?.text = dayPart
                    self.formatter.dateStyle = .NoStyle
                    self.formatter.timeStyle = .ShortStyle
                    let timePart = self.formatter.stringFromDate(row.value!)
                    cell.detailTextLabel?.text = timePart
                }
            }

            <<< IntRow("reps") {
                $0.title = "Reps"
                $0.onChange { row in
                    self.form.rowByTag("one_rep_max")?.updateCell()
                }
            }

            <<< DecimalRow("weight") {
                $0.title = "Weight"
                $0.onChange { row in
                    self.form.rowByTag("one_rep_max")?.updateCell()
                }
            }
            
            +++ Section()

            <<< LabelRow("pr") {
                $0.title = "Personal Best"
                self.formatter.dateStyle = .ShortStyle
                self.formatter.timeStyle = .NoStyle
                $0.hidden = "$pr == nil"
                $0.cellUpdate { cell, row in
                    let values = self.form.values()
                    guard let
                        exercise = values["exercise"] as? ExerciseReference,
                        exerciseID = exercise.exerciseID,
                        date = values["date"] as? NSDate
                        else {
                            row.value = nil
                            return
                    }
                    row.value = self.db.maxE1RM(exerciseID: exerciseID, todate: date).flatMap {
                        guard let weight = $0.weight else { return nil }
                        self.formatter.dateStyle = .ShortStyle
                        self.formatter.timeStyle = .NoStyle
                        let date = self.formatter.stringFromDate($0.date)
                        return "\(weight) (\(date))"
                    }
                    cell.detailTextLabel?.text = row.value
                }
            }

            <<< LabelRow("one_rep_max") {
                $0.title = "Estimated 1-rep max"
                $0.hidden = "$one_rep_max == nil"
                $0.cellUpdate { cell, row in
                    let values = self.form.values()
                    guard let
                        reps = values["reps"] as? Int,
                        weight = values["weight"] as? Double
                        else {
                            row.value = nil
                            return
                    }
                    row.value = Workset.estimate1RM(reps: reps, weight: weight).flatMap { String($0) }
                    cell.detailTextLabel?.text = row.value
                }
            }
    }
    
    func cancelButtonPressed() {
        callback(nil)
    }
    
    func saveButtonPressed() {
        guard let workset = worksetFromFields() else { return }
        callback(workset)
    }
    
    private func worksetFromFields() -> Workset? {
        let values = form.values()
        guard let
            exercise = values["exercise"] as? ExerciseReference,
            date = values["date"] as? NSDate,
            reps = values["reps"] as? Int,
            weight = values["weight"] as? Double
            else { return nil }
        let e1RM = values["one_rep_max"] as? Double
        let maxE1RM = values["pr"] as? Double
        return Workset(
            worksetID: nil,
            exerciseID: exercise.exerciseID,
            workoutID: workoutID,
            exerciseName: exercise.name,
            date: date,
            reps: reps,
            weight: weight,
            duration: nil,
            e1RM: e1RM,
            maxE1RM: maxE1RM,
            maxDuration: nil
        )
    }
}