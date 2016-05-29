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

    enum Mode {
        case ReadOnly
        case Creating
        case Editing
        case Editable

        static func isValidTransition(old: Mode, new: Mode) -> Bool {
            switch (old, new) {
            case (.Editing, .Editable): return true
            case (.Editable, .Editing): return true
            case (.ReadOnly, _): return false
            case (.Creating, _): return false
            default: return false
            }
        }
    }

    private let db = DB.sharedInstance
    private let callback: Workset? -> Void
    private let formatter = NSDateFormatter()
    private let cal = NSCalendar.currentCalendar()
    private let recordsFormatter = RelativeRecordsFormatter()

    private var mode: Mode {
        willSet(newMode) {
            assert(Mode.isValidTransition(mode, new: newMode))
        }
        didSet {
            refreshMode()
        }
    }

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

    private var cancelButton: UIBarButtonItem {
        return UIBarButtonItem(
            barButtonSystemItem: .Cancel,
            target: self,
            action: #selector(CreateWorkoutRecordViewController.cancelButtonPressed)
        )
    }

    private var saveButton: UIBarButtonItem {
        return UIBarButtonItem(
            barButtonSystemItem: .Save,
            target: self,
            action: #selector(CreateWorkoutRecordViewController.saveButtonPressed)
        )
    }

    private var editButton: UIBarButtonItem {
        return UIBarButtonItem(
            barButtonSystemItem: .Edit,
            target: self,
            action: #selector(CreateWorkoutRecordViewController.editButtonPressed)
        )
    }

    init(workset: Workset? = nil, callback: Workset? -> Void = { _ in }) {
        if let workset = workset {
            self.startTime = workset.input.startTime
            self.duration = workset.input.duration
            self.exercise = workset.exerciseReference
            self.reps = workset.input.reps
            self.weight = workset.input.weight
            self.warmup = workset.input.warmup
            self.failure = workset.input.failure
        }
        self.mode = workset == nil ? .Creating : .Editable
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
        
        form

        +++ Section() {
            $0.tag = "input"
        }

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
            $0.value = self.reps
            $0.onChange { row in
                self.reps = row.value
            }
        }

        <<< DecimalRow("weight") {
            $0.title = "Weight"
            $0.value = self.weight
            $0.onChange { row in
                self.weight = row.value
            }
        }

        <<< SwitchRow("Failure") {
            $0.title = $0.tag
            $0.value = self.failure
            $0.onChange { row in
                self.failure = row.value!
            }
        }

        <<< SwitchRow("Warmup"){
            $0.title = $0.tag
            $0.value = self.warmup
            $0.onChange { row in
                self.warmup = row.value!
            }
        }

        +++ Section("Calculations")  {
            $0.tag = "calculations"
            $0.hidden = .Function([], { form -> Bool in
                return (form.sectionByTag("calculations")?.count ?? 0) > 0 ? false : true
            })
        }

        <<< LabelRow("e1rm") {
            $0.title = $0.tag
            $0.hidden = "$e1rm == nil"
        }

        <<< LabelRow("Volume") {
            $0.title = $0.tag
            $0.hidden = "$Volume == nil"
        }

        +++ Section("Personal Records") {
            $0.tag = "prs"
            $0.hidden = .Function([], { form -> Bool in
                return (form.sectionByTag("prs")?.count ?? 0) > 0 ? false : true
            })
        }

        <<< LabelRow("RM") {
            $0.title = $0.tag
            $0.hidden = "$RM == nil"
            $0.cellUpdate { cell, row in
                if let maxWeight = self.records?.maxWeight {
                    cell.accessoryType = .DisclosureIndicator
                    row.onCellSelection { _, _ in
                        let vc = CreateWorkoutRecordViewController(workset: maxWeight)
                        self.showViewController(vc, sender: nil)
                    }
                } else {
                    cell.accessoryType = .None
                    row.onCellSelection { _, _ in }
                }
            }
        }

        <<< LabelRow("OneRM") {
            $0.title = "1RM"
            $0.hidden = "$OneRM == nil"
            $0.cellUpdate { cell, row in
                if let max1RM = self.records?.max1RM {
                    cell.accessoryType = .DisclosureIndicator
                    row.onCellSelection { _, _ in
                        let vc = CreateWorkoutRecordViewController(workset: max1RM)
                        self.showViewController(vc, sender: nil)
                    }
                } else {
                    cell.accessoryType = .None
                    row.onCellSelection { _, _ in }
                }
            }
        }

        <<< LabelRow("e1RM") {
            $0.title = $0.tag
            $0.hidden = "$e1RM == nil"
            $0.cellUpdate { cell, row in
                if let maxE1RM = self.records?.maxE1RM {
                    cell.accessoryType = .DisclosureIndicator
                    row.onCellSelection { _, _ in
                        let vc = CreateWorkoutRecordViewController(workset: maxE1RM)
                        self.showViewController(vc, sender: nil)
                    }
                } else {
                    cell.accessoryType = .None
                    row.onCellSelection { _, _ in }
                }
            }
        }

        <<< LabelRow("XRM") {
            $0.hidden = "$XRM == nil"
            $0.cellUpdate { cell, row in
                if let maxXRM = self.records?.maxXRM {
                    cell.accessoryType = .DisclosureIndicator
                    row.onCellSelection { _, _ in
                        let vc = CreateWorkoutRecordViewController(workset: maxXRM)
                        self.showViewController(vc, sender: nil)
                    }
                } else {
                    cell.accessoryType = .None
                    row.onCellSelection { _, _ in }
                }
            }
        }

        <<< LabelRow("PastVolume") {
            $0.title = "Volume"
            $0.hidden = "$PastVolume == nil"
            $0.cellUpdate { cell, row in
                if let maxVolume = self.records?.maxVolume {
                    cell.accessoryType = .DisclosureIndicator
                    row.onCellSelection { _, _ in
                        let vc = CreateWorkoutRecordViewController(workset: maxVolume)
                        self.showViewController(vc, sender: nil)
                    }
                } else {
                    cell.accessoryType = .None
                    row.onCellSelection { _, _ in }
                }
            }
        }

        <<< LabelRow("Intensity") {
            $0.title = $0.tag
            $0.hidden = "$Intensity == nil"
        }

        refreshMode()

        if let input = input {
            records = db.get(Records.self, input: input)
            updateRelativeRecords()
        }

        updateCalculatedRows()
    }

    private func updateRelativeRecords() {
        guard let input = input, records = records else { return }
        relativeRecords = RelativeRecords(input: input, records: records)
    }

    private func updateCalculatedRows() {
        form.rowByTag("e1rm")?.value = recordsFormatter.format(
            value: workset?.calculations?.e1RM
        )
        form.rowByTag("Volume")?.value = recordsFormatter.format(
            value: workset?.calculations?.volume
        )
        form.rowByTag("RM")?.value = recordsFormatter.format(
            value: relativeRecords?.records.maxWeight?.input.weight,
            percent: relativeRecords?.percentMaxWeight
        )
        form.rowByTag("OneRM")?.value = recordsFormatter.format(
            value: relativeRecords?.records.max1RM?.input.weight,
            percent: relativeRecords?.percent1RM
        )
        form.rowByTag("e1RM")?.value = recordsFormatter.format(
            value: relativeRecords?.records.maxE1RM?.input.weight,
            percent: relativeRecords?.percentE1RM
        )
        if let xrmRow = form.rowByTag("XRM") as? LabelRow {
            if let reps = reps {
                xrmRow.title = "\(reps)RM"
                xrmRow.value = recordsFormatter.format(
                    value: relativeRecords?.records.maxXRM?.input.weight,
                    percent: relativeRecords?.percentXRM
                )
            } else {
                xrmRow.value = nil
            }
        }
        form.rowByTag("PastVolume")?.value = self.recordsFormatter.format(
            value: self.relativeRecords?.records.maxVolume?.calculations?.volume,
            percent: self.relativeRecords?.percentMaxVolume
        )
        form.rowByTag("Intensity")?.value = self.recordsFormatter.format(
            percent: self.relativeRecords?.intensity
        )
        form.sectionByTag("calculations")?.evaluateHidden()
        form.sectionByTag("prs")?.evaluateHidden()
        form.sectionByTag("calculations")?.reload()
        form.sectionByTag("prs")?.reload()
    }

    private func enableInputFields() {
        if let section = form.sectionByTag("input") {
            for row in section {
                row.disabled = false
                row.evaluateDisabled()
            }
        }
    }

    private func disableInputFields() {
        if let section = form.sectionByTag("input") {
            for row in section {
                row.disabled = true
                row.evaluateDisabled()
            }
        }
    }

    private func refreshMode() {
        switch mode {
        case .ReadOnly:
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            disableInputFields()
        case .Creating:
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = saveButton
            enableInputFields()
        case .Editable:
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = editButton
            disableInputFields()
        case .Editing:
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = saveButton
            enableInputFields()
        }
    }

    func cancelButtonPressed() {
        assert(mode == .Editing || mode == .Creating)
        if mode == .Editing { mode = .Editable }
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
        assert(mode == .Editing || mode == .Creating)
        if mode == .Editing { mode = .Editable }
        callback(workset)
    }

    func editButtonPressed() {
        assert(mode == .Editable)
        mode = .Editing
        updateCalculatedRows()
    }

}
