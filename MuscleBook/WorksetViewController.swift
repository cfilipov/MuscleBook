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

class WorksetViewController: FormViewController {

    enum Result {
        case Cancelled
        case Updated(Workset)
        case Created(Workset)
        case Deleted(Workset)
    }

    enum Mode {
        case ReadOnly
        case Creating
        case Editing(Workset)
        case Editable(Workset)

        static func isValidTransition(old old: Mode, new: Mode) -> Bool {
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
    private let callback: Result -> Void
    private let formatter = NSDateFormatter()
    private let cal = NSCalendar.currentCalendar()
    private let recordsFormatter = RelativeRecordsFormatter()
    private let originalWorkset: Workset?

    let numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private let timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        return formatter
    }()

    private var mode: Mode {
        willSet(newMode) {
            assert(Mode.isValidTransition(old: mode, new: newMode))
        }
        didSet {
            refreshMode()
            form.rowByTag("delete")?.evaluateHidden()
            form.sectionByTag("section_delete")?.evaluateHidden()
            form.sectionByTag("section_delete")?.reload()
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

    private var input = Workset.Input(
        exerciseID: nil,
        exerciseName: "",
        startTime: NSDate(),
        duration: nil,
        failure: false,
        warmup: false,
        reps: nil,
        weight: nil,
        bodyweight: nil,
        assistanceWeight: nil
    ) {
        didSet {
            records = db.get(Records.self, input: input)
        }
    }

    private var calculations: Workset.Calculations? {
        guard let relativeRecords = relativeRecords else { return nil }
        return relativeRecords.calculations
    }

    private var cancelButton: UIBarButtonItem {
        return UIBarButtonItem(
            barButtonSystemItem: .Cancel,
            target: self,
            action: #selector(WorksetViewController.cancelButtonPressed)
        )
    }

    private var saveButton: UIBarButtonItem {
        return UIBarButtonItem(
            barButtonSystemItem: .Save,
            target: self,
            action: #selector(WorksetViewController.saveButtonPressed)
        )
    }

    private var editButton: UIBarButtonItem {
        return UIBarButtonItem(
            barButtonSystemItem: .Edit,
            target: self,
            action: #selector(WorksetViewController.editButtonPressed)
        )
    }

    init(workset: Workset? = nil, callback: Result -> Void = { _ in }) {
        if let workset = workset {
            self.input = workset.input
            self.mode = .Editable(workset)
        } else {
            self.mode = .Creating
        }
        self.originalWorkset = workset
        self.callback = callback
        super.init(style: .Grouped)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
        
        if input.exerciseID == nil {
            input.exercise = db.newest(Workset)?.exerciseReference
        }
        
        form

        +++ Section() {
            $0.tag = "input"
        }

        <<< LabelRow() {
            $0.title = "Exercise"
            $0.tag = "exercise"
            $0.cellSetup { cell, row in
                cell.accessoryType = .DisclosureIndicator
                cell.showErrorAccessoryView(self.input.exercise?.exerciseID == nil)
            }
            $0.onCellSelection { cell, row in
                switch self.mode {
                case .Creating: fallthrough
                case .Editing(_):
                    let vc = ExercisesListViewController { ref in
                        self.navigationController?.popViewControllerAnimated(true)
                        self.input.exercise = ref
                    }
                    self.showViewController(vc, sender: nil)
                case .ReadOnly: fallthrough
                case .Editable(_):
                    if let ref = self.input.exercise, ex = self.db.dereference(ref) {
                        let vc = ExerciseDetailViewController(exercise: ex)
                        self.showViewController(vc, sender: nil)
                    }
                }
            }
        }

        <<< LabelRow() {
            $0.title = "Date"
            $0.tag = "date"
        }

        <<< LabelRow() {
            $0.title = "Time"
            $0.tag = "time"
        }

        <<< TimerRow() {
            $0.title = "Duration"
            $0.tag = "duration"
            $0.value = self.input.duration
            $0.onChange { row in
                print("Timer: \(row.value)")
                self.input.startTime ?= row.startTime
                self.input.duration = row.value
            }
        }

        <<< IntRow() {
            $0.title = "Reps"
            $0.value = self.input.reps
            $0.tag = "reps"
            $0.onChange { row in
                self.input.reps = row.value
            }
        }

        <<< DecimalRow() {
            $0.title = "Weight"
            $0.value = self.input.weight
            $0.tag = "weight"
            $0.formatter = self.numberFormatter
            $0.onChange { row in
                self.input.weight = row.value
            }
        }

        <<< DecimalRow() {
            $0.title = "Body Weight"
            $0.value = self.input.bodyweight
            $0.tag = "bodyweight"
            $0.formatter = self.numberFormatter
            $0.onChange { row in
                self.input.bodyweight = row.value
            }
        }

        <<< DecimalRow() {
            $0.title = "Assistance Weight"
            $0.value = self.input.assistanceWeight
            $0.tag = "assweight"
            $0.formatter = self.numberFormatter
            $0.onChange { row in
                self.input.assistanceWeight = row.value
            }
        }

        <<< SwitchRow("Failure") {
            $0.title = $0.tag
            $0.value = self.input.failure
            $0.onChange { row in
                self.input.failure = row.value!
            }
        }

        <<< SwitchRow("Warmup"){
            $0.title = $0.tag
            $0.value = self.input.warmup
            $0.onChange { row in
                self.input.warmup = row.value!
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
            $0.hidden = Condition.Function([]) { form -> Bool in
                return (form.sectionByTag("prs")?.count ?? 0) > 0 ? false : true
            }
        }

        <<< LabelRow("RM") {
            $0.title = $0.tag
            $0.hidden = "$RM == nil"
            $0.cellUpdate { cell, row in
                if let maxWeight = self.records?.maxWeight {
                    cell.accessoryType = .DisclosureIndicator
                    row.onCellSelection { _, _ in
                        let vc = WorksetViewController(workset: maxWeight)
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
                        let vc = WorksetViewController(workset: max1RM)
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
                        let vc = WorksetViewController(workset: maxE1RM)
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
                        let vc = WorksetViewController(workset: maxXRM)
                        self.showViewController(vc, sender: nil)
                    }
                } else {
                    cell.accessoryType = .None
                    row.onCellSelection { _, _ in }
                }
            }
        }

        <<< LabelRow("past_volume") {
            $0.title = "Volume"
            $0.hidden = "$past_volume == nil"
            $0.cellUpdate { cell, row in
                if let maxVolume = self.records?.maxVolume {
                    cell.accessoryType = .DisclosureIndicator
                    row.onCellSelection { _, _ in
                        let vc = WorksetViewController(workset: maxVolume)
                        self.showViewController(vc, sender: nil)
                    }
                } else {
                    cell.accessoryType = .None
                    row.onCellSelection { _, _ in }
                }
            }
        }

        <<< LabelRow() {
            $0.title = "Intensity"
            $0.tag = "intensity"
            $0.hidden = "$intensity == nil"
        }

        +++ Section() {
            $0.tag = "section_delete"
            $0.hidden = Condition.Function([]) { form -> Bool in
                return (form.sectionByTag("section_delete")?.count ?? 0) > 0 ? false : true
            }
        }

        <<< ButtonRow() {
            $0.title = "Delete"
            $0.tag = "delete"
            $0.hidden = Condition.Function([]) { form -> Bool in
                if case .Editing(_) = self.mode { return false }
                else { return true }
            }
            $0.cellUpdate { cell, _ in
                cell.textLabel?.textColor = UIColor.redColor()
                let font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                cell.textLabel?.font = UIFont.boldSystemFontOfSize(font.pointSize)
            }
            $0.onCellSelection { _, _ in
                if case .Editing(let workset) = self.mode {
                    let effectedWorkouts = self.db.count(Workout.self, after: workset.input.startTime)
                    var message = "Are you sure you want to delete this set?"
                    if effectedWorkouts > 0 {
                        message += "\n\nDeleting this set will effect \(effectedWorkouts) other workouts."
                    }
                    WarnAlert(message: message) {
                        AlertOnError {
                            try self.db.delete(workset)
                            self.callback(Result.Deleted(workset))
                        }
                    }
                } else { fatalError("Unexpected mode: \(self.mode)") }
            }
        }

        refreshMode()
        records = db.get(Records.self, input: input)
        updateRelativeRecords()
        updateCalculatedRows()
    }

    private func updateRelativeRecords() {
        guard let records = records, _ = input.exercise else { return }
        relativeRecords = RelativeRecords(input: input, records: records)
    }

    private func updateCalculatedRows() {
        if let ref = input.exercise, ex = db.dereference(ref) {
            form.rowByTag("reps")?.hidden = !ex.inputOptions.contains(.Reps) ? true : false
            form.rowByTag("reps")?.evaluateHidden()
            form.rowByTag("weight")?.hidden = !ex.inputOptions.contains(.Weight) ? true : false
            form.rowByTag("weight")?.evaluateHidden()
            // Duration is always shown, but is optional
            form.rowByTag("bodyweight")?.hidden = !ex.inputOptions.contains(.BodyWeight) ? true : false
            form.rowByTag("bodyweight")?.evaluateHidden()
            form.rowByTag("assweight")?.hidden = !ex.inputOptions.contains(.AssistanceWeight) ? true : false
            form.rowByTag("assweight")?.evaluateHidden()
        } else {
            form.rowByTag("reps")?.hidden = true
            form.rowByTag("weight")?.hidden = true
            // Duration is always shown, but is optional
            form.rowByTag("bodyweight")?.hidden = true
            form.rowByTag("assweight")?.hidden = true
        }
        form.rowByTag("exercise")?.value = input.exercise?.name
        form.rowByTag("date")?.value = dateFormatter.stringFromDate(input.startTime)
        form.rowByTag("date")?.updateCell() // wtf? why?
        form.rowByTag("time")?.value = timeFormatter.stringFromDate(input.startTime)
        form.rowByTag("time")?.updateCell()
        form.rowByTag("e1rm")?.value = recordsFormatter.format(
            value: relativeRecords?.calculations.e1RM
        )
        form.rowByTag("Volume")?.value = recordsFormatter.format(
            value: relativeRecords?.calculations.volume
        )
        form.rowByTag("RM")?.value = recordsFormatter.format(
            value: records?.maxWeight?.input.weight,
            percent: relativeRecords?.percentMaxWeight
        )
        form.rowByTag("OneRM")?.value = recordsFormatter.format(
            value: records?.max1RM?.input.weight,
            percent: relativeRecords?.percent1RM
        )
        form.rowByTag("e1RM")?.value = recordsFormatter.format(
            value: records?.maxE1RM?.input.weight,
            percent: relativeRecords?.percentE1RM
        )
        if let xrmRow = form.rowByTag("XRM") as? LabelRow {
            if let reps = input.reps {
                xrmRow.title = "\(reps)RM"
                xrmRow.value = recordsFormatter.format(
                    value: records?.maxXRM?.input.weight,
                    percent: relativeRecords?.percentXRM
                )
            } else {
                xrmRow.value = nil
            }
        }
        form.rowByTag("past_volume")?.value = self.recordsFormatter.format(
            value: self.records?.maxVolume?.calculations.volume,
            percent: self.relativeRecords?.percentMaxVolume
        )
        form.rowByTag("intensity")?.value = self.recordsFormatter.format(
            percent: self.relativeRecords?.intensity
        )
        form.sectionByTag("calculations")?.evaluateHidden()
        form.sectionByTag("prs")?.evaluateHidden()
        form.rowByTag("delete")?.evaluateHidden()
        form.sectionByTag("input")?.evaluateHidden()
        form.sectionByTag("section_delete")?.evaluateHidden()
        form.sectionByTag("calculations")?.reload()
        form.sectionByTag("prs")?.reload()
        form.sectionByTag("section_delete")?.reload()
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
            self.title = "Data Point"
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            disableInputFields()
        case .Creating:
            self.title = "Add Data Point"
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = saveButton
            enableInputFields()
        case .Editable:
            self.title = "Data Point"
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = editButton
            disableInputFields()
        case .Editing:
            self.title = "Editing"
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = saveButton
            enableInputFields()
        }
    }

    func cancelButtonPressed() {
        switch mode {
        case let .Editing(workset):
            mode = .Editable(workset)
        case .Creating:
            callback(Result.Cancelled)
        default:
            fatalError("Unexpected mode: \(mode)")
        }
    }
    
    func saveButtonPressed() {
        guard let ref = input.exercise, exercise = db.dereference(ref) else {
            Alert(message: "Could not save data point, mising required field: Exercise")
            return
        }
        if exercise.inputOptions.contains(.Reps) {
            guard let _ = input.reps else {
                Alert(message: "Could not save data point, mising required field: Reps")
                return
            }
        }
        if exercise.inputOptions.contains(.Weight) {
            guard let _ = input.weight else {
                Alert(message: "Could not save data point, mising required field: Weight")
                return
            }
        }
        if exercise.inputOptions.contains(.Duration) {
            guard let _ = input.duration else {
                Alert(message: "Could not save data point, mising required field: Duration")
                return
            }
        }
        if exercise.inputOptions.contains(.AssistanceWeight) {
            guard let _ = input.assistanceWeight else {
                Alert(message: "Could not save data point, mising required field: Assistance Weight")
                return
            }
        }
        switch mode {
        case let .Editing(workset):
            let effectedWorkouts = db.count(Workout.self, after: workset.input.startTime)
            WarnAlert(when: effectedWorkouts > 0, message: "Are you sure you want to save this change? Changes to this set will effect \(effectedWorkouts) other workouts.") {
                AlertOnError {
                    let newWorkset = try self.db.update(workset: workset, input: self.input)
                    self.mode = .Editable(newWorkset)
                }
            }
        case .Creating:
            AlertOnError {
                let workset = try self.db.save(self.input)
                self.callback(Result.Created(workset))
            }
        default:
            fatalError("Unexpected mode: \(mode)")
        }
    }

    func editButtonPressed() {
        switch mode {
        case let .Editable(workset):
            let effectedWorkouts = db.count(Workout.self, after: workset.input.startTime)
            WarnAlert(when: effectedWorkouts > 0, message: "Are you sure you want to edit this set? Changes to this set will effect \(effectedWorkouts) other workouts.") {
                self.mode = .Editing(workset)
            }
        default:
            fatalError("Unexpected mode: \(mode)")
        }
    }

}
