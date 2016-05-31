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

class ExerciseStatisticsViewController : FormViewController {

    private let db = DB.sharedInstance
    private let exerciseRef: ExerciseReference

    let numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private var exerciseID: Int64 {
        return exerciseRef.exerciseID!
    }

    init(exercise: ExerciseReference) {
        self.exerciseRef = exercise
        super.init(style: .Grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
        
        title = exerciseRef.name

        form

        +++ Section()

        <<< LabelRow() {
            $0.title = "Name"
            $0.value = exerciseRef.name
        }

        <<< PunchcardRow() {
            $0.tag = "punchcard"
            $0.value = ExercisePunchcardDelegate(exerciseID: self.exerciseID)
        }

        <<< IntRow() {
            $0.title = "Days"
            $0.tag = "days"
            $0.hidden = "$days == nil"
            $0.disabled = true
        }

        <<< IntRow() {
            $0.title = "Sets"
            $0.tag = "sets"
            $0.hidden = "$sets == nil"
            $0.disabled = true
        }

        +++ Section("Records")

        <<< DecimalRow() {
            $0.title = "RM"
            $0.tag = "rm"
            $0.hidden = "$rm == nil"
            $0.disabled = true
            $0.formatter = self.numberFormatter
            $0.cellUpdate { cell, row in
                cell.accessoryType = row.value == nil ? .None : .DisclosureIndicator
            }
        }

        <<< DecimalRow() {
            $0.title = "1RM"
            $0.tag = "rm1"
            $0.hidden = "$rm1 == nil"
            $0.disabled = true
            $0.formatter = self.numberFormatter
            $0.cellUpdate { cell, row in
                cell.accessoryType = row.value == nil ? .None : .DisclosureIndicator
            }
        }

        <<< DecimalRow() {
            $0.title = "e1RM"
            $0.tag = "e1rm"
            $0.hidden = "$e1rm == nil"
            $0.disabled = true
            $0.formatter = self.numberFormatter
            $0.cellUpdate { cell, row in
                cell.accessoryType = row.value == nil ? .None : .DisclosureIndicator
            }
        }

        <<< DecimalRow() {
            $0.title = "Volume"
            $0.tag = "past_volume"
            $0.hidden = "$past_volume == nil"
            $0.disabled = true
            $0.formatter = self.numberFormatter
            $0.cellUpdate { cell, row in
                cell.accessoryType = row.value == nil ? .None : .DisclosureIndicator
            }
        }

        updateRows()
    }

    private func updateRows() {
        form.rowByTag("days")?.value = try? db.activationByDay(exerciseID: exerciseID).count ?? 0
        form.rowByTag("sets")?.value = db.count(Exercise.self, exerciseID: exerciseID)
        if let row = form.rowByTag("rm") as? DecimalRow {
            let maxWeight = db.maxRM(exerciseID: exerciseID)
            row.value = maxWeight?.input.weight
            row.onCellSelection { _, _ in self.showWorkset(maxWeight) }
        }
        if let row = form.rowByTag("rm1") as? DecimalRow {
            let max1rm = db.max1RM(exerciseID: exerciseID)
            row.value = max1rm?.input.weight
            row.onCellSelection { _, _ in self.showWorkset(max1rm) }
        }
        if let row = form.rowByTag("e1rm") as? DecimalRow {
            let maxe1rm = db.maxE1RM(exerciseID: exerciseID)
            row.value = maxe1rm?.calculations.e1RM
            row.onCellSelection { _, _ in self.showWorkset(maxe1rm) }
        }
        if let row = form.rowByTag("past_volume") as? DecimalRow {
            let maxvol = db.maxVolume(exerciseID: exerciseID)
            row.value = maxvol?.calculations.volume
            row.onCellSelection { _, _ in self.showWorkset(maxvol) }
        }
        
    }

    private func showWorkset(workset: Workset?) {
        let vc = WorksetViewController(workset: workset)
        self.showViewController(vc, sender: nil)
    }
}

private class ExercisePunchcardDelegate: PunchcardDelegate {
    private let db = DB.sharedInstance
    private let cal = NSCalendar.currentCalendar()
    private let activations: [NSDate: Activation]
    private let exerciseID: Int64

    init(exerciseID: Int64) {
        self.exerciseID = exerciseID
        activations = try! db.activationByDay(exerciseID: exerciseID)
    }

    override func calendarGraph(calendarGraph: EFCalendarGraph!, valueForDate date: NSDate!, daysAfterStartDate: UInt, daysBeforeEndDate: UInt) -> AnyObject! {
        guard let activation = activations[cal.startOfDayForDate(date)] else { return 0 }
        switch activation {
        case .None: return 0
        case .Light: return 1
        case .Medium: return 1
        case .High: return 1
        case .Max: return 5
        }
    }
}
