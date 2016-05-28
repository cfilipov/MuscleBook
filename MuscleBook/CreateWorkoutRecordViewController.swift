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

    private let callback: Workset? -> Void
    private let formatter = NSDateFormatter()
    private let cal = NSCalendar.currentCalendar()
    private let recordsFormatter = RelativeRecordsFormatter()

    private var records: Records?  {
        didSet {
            updateRelativeRecords()
        }
    }

    private var relativeRecords: RelativeRecords? {
        didSet {
            updateCalculatedRows()
        }
    }

    private var exercise: ExerciseReference? {
        didSet {
            guard let input = input else { return }
            records = db.get(Records.self, input: input)
        }
    }

    private var startTime: NSDate = NSDate() {
        didSet {
            guard let input = input else { return }
            records = db.get(Records.self, input: input)
        }
    }

    private var failure: Bool = false {
        didSet {
            updateRelativeRecords()
        }
    }

    private var warmup: Bool = false {
        didSet {
            updateRelativeRecords()
        }
    }

    private var reps: Int? {
        didSet {
            guard let input = input else { return }
            records = db.get(Records.self, input: input)
        }
    }

    private var weight: Double? {
        didSet {
            guard let input = input else { return }
            records = db.get(Records.self, input: input)
        }
    }

    private var duration: Double? {
        didSet {
            updateRelativeRecords()
        }
    }

    private var input: Workset.Input? {
        guard let
            exercise = exercise
            else { return nil }
        return Workset.Input(
            exerciseID: exercise.exerciseID,
            exerciseName: exercise.name,
            startTime: startTime,
            duration: duration ?? 0,
            failure: failure,
            warmup: warmup,
            reps: reps,
            weight: weight
        )
    }

    private var workset: Workset? {
        guard let rec = relativeRecords else { return nil }
        return Workset(relativeRecords: rec)
    }

    private var strRM: String? {
        return recordsFormatter.format(
            value: relativeRecords?.records.maxWeight?.input.weight,
            percent: relativeRecords?.percentMaxWeight
        )
    }

    private var str1RM: String? {
        return recordsFormatter.format(
            value: relativeRecords?.records.max1RM?.input.weight,
            percent: relativeRecords?.percent1RM
        )
    }

    private var strE1RM: String? {
        return recordsFormatter.format(
            value: relativeRecords?.records.maxE1RM?.input.weight,
            percent: relativeRecords?.percentE1RM
        )
    }

    private var strXRM: String? {
        return recordsFormatter.format(
            value: relativeRecords?.records.maxXRM?.input.weight,
            percent: relativeRecords?.percentXRM
        )
    }

    private var strVolume: String? {
        return recordsFormatter.format(
            value: relativeRecords?.records.maxVolume?.calculations?.volume,
            percent: relativeRecords?.percentMaxVolume
        )
    }

    init(callback: Workset? -> Void) {
        self.callback = callback
        super.init(style: .Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Data Point"

        if exercise == nil {
            self.exercise = db.newest(Workset)?.exerciseReference
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Cancel,
            target: self,
            action: #selector(CreateWorkoutRecordViewController.cancelButtonPressed)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Save,
            target: self,
            action: #selector(CreateWorkoutRecordViewController.saveButtonPressed)
        )
        
        form

        +++ Section()

        <<< SelectExerciseRow("exercise") {
            $0.title = "Exercise"
            $0.value = exercise
            $0.onChange { row in
                self.exercise = row.value
            }
        }

        <<< DateTimeInlineRow("date") {
            $0.value = self.startTime
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
                self.reps = row.value
            }
        }

        <<< DecimalRow("weight") {
            $0.title = "Weight"
            $0.onChange { row in
                self.weight = row.value
            }
        }

        <<< SwitchRow("Failure") {
            $0.title = $0.tag
            $0.onChange { row in
                self.failure = row.value!
            }
        }

        <<< SwitchRow("Warmup"){
            $0.title = $0.tag
            $0.onChange { row in
                self.warmup = row.value!
            }
        }

        +++ Section()

        <<< LabelRow("e1rm") {
            $0.title = $0.tag
            $0.hidden = "$e1rm == nil"
            $0.cellUpdate { cell, row in
                row.value = self.recordsFormatter.format(value: self.workset?.calculations?.e1RM)
                cell.detailTextLabel?.text = row.value
            }
        }

        <<< LabelRow("Volume") {
            $0.title = $0.tag
            $0.hidden = "$Volume == nil"
            $0.cellUpdate { cell, row in
                row.value = self.recordsFormatter.format(value: self.workset?.calculations?.volume)
                cell.detailTextLabel?.text = row.value
            }
        }

        +++ Section("Personal Records")

        <<< LabelRow("RM") {
            $0.title = $0.tag
            $0.hidden = "$RM == nil"
            self.formatter.dateStyle = .ShortStyle
            self.formatter.timeStyle = .NoStyle
            $0.cellUpdate { cell, row in
                row.value = self.strRM
                cell.detailTextLabel?.text = row.value
            }
        }

        <<< LabelRow("OneRM") {
            $0.title = "1RM"
            $0.hidden = "$OneRM == nil"
            self.formatter.dateStyle = .ShortStyle
            self.formatter.timeStyle = .NoStyle
            $0.cellUpdate { cell, row in
                row.value = self.str1RM
                cell.detailTextLabel?.text = row.value
            }
        }

        <<< LabelRow("e1RM") {
            $0.title = $0.tag
            $0.hidden = "$e1RM == nil"
            self.formatter.dateStyle = .ShortStyle
            self.formatter.timeStyle = .NoStyle
            $0.cellUpdate { cell, row in
                row.value = self.strE1RM
                cell.detailTextLabel?.text = row.value
            }
        }

        <<< LabelRow("XRM") {
            $0.hidden = "$XRM == nil"
            self.formatter.dateStyle = .ShortStyle
            self.formatter.timeStyle = .NoStyle
            $0.cellUpdate { cell, row in
                if let reps = self.reps {
                    row.title = "\(reps)RM"
                    row.value = self.strXRM
                } else {
                    row.value = nil
                }
                cell.detailTextLabel?.text = row.value
            }
        }

        <<< LabelRow("PastVolume") {
            $0.title = "Volume"
            $0.hidden = "$PastVolume == nil"
            self.formatter.dateStyle = .ShortStyle
            self.formatter.timeStyle = .NoStyle
            $0.cellUpdate { cell, row in
                row.value = self.strVolume
                cell.detailTextLabel?.text = row.value
            }
        }

        <<< LabelRow("Intensity") {
            $0.title = $0.tag
            $0.hidden = "$Intensity == nil"
            $0.cellUpdate { cell, row in
                row.value = self.recordsFormatter.format(percent: self.relativeRecords?.intensity)
                cell.detailTextLabel?.text = row.value
            }
        }
    }

    private func updateRelativeRecords() {
        guard let input = input, records = records else { return }
        relativeRecords = RelativeRecords(input: input, records: records)
    }

    private func updateCalculatedRows() {
        form.rowByTag("e1rm")?.updateCell()
        form.rowByTag("Volume")?.updateCell()
        form.rowByTag("RM")?.updateCell()
        form.rowByTag("OneRM")?.updateCell()
        form.rowByTag("e1RM")?.updateCell()
        form.rowByTag("XRM")?.updateCell()
        form.rowByTag("PastVolume")?.updateCell()
        form.rowByTag("Intensity")?.updateCell()
    }
    
    func cancelButtonPressed() {
        callback(nil)
    }
    
    func saveButtonPressed() {
        guard let workset = workset else {
            Alert(message: "Could not save data point, mising required fields.")
            return
        }
        do {
            try db.save(workset)
        } catch let e {
            Alert(message: "\(e)")
        }
        callback(workset)
    }

}
