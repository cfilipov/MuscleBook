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

class WorkoutsByDayViewController: FormViewController {

    private let db = DB.sharedInstance

    let weightFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE, dd, hh:mm a"
        return formatter
    }()

    let monthFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
        return formatter
    }()

    let filterControl: UISegmentedControl = {
        let v = UISegmentedControl(items: [])
        return v
    }()

    let restDaySwitch: UISwitch = {
        let v = UISwitch()
        return v
    }()

    let cal = NSCalendar.currentCalendar()

    init() {
        super.init(style: .Grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Workouts"
        rebuildForm()
    }

    private func rebuildForm() {
        form.removeAll()
        form +++ Section() <<< LabelRow() {
            $0.title = "New Workout"
        }.cellSetup { cell, row in
            cell.accessoryType = .DisclosureIndicator
        }.onCellSelection { cell, row in
            let workoutID = self.db.nextAvailableRowID(Workout)
            let vc = CreateWorkoutRecordViewController(workoutID: workoutID) { record in
                if let record = record {
                    try! self.db.save(record)
                }
                self.rebuildForm()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentModalViewController(vc)
        }

        let allWorkouts = try! db.all(Workout)
        var curMonth: String? = nil
        var curSection: Section? = nil
        for w in allWorkouts {
            let month = monthFormatter.stringFromDate(w.date)
            if month != curMonth {
                curMonth = month
                let section = Section(month)
                form +++ section
                curSection = section
            }
            if let curSection = curSection {
                curSection <<< workoutToRow(w)
            }
        }
    }

    private func workoutToRow(workout: Workout) -> BaseRow {
        let row = workout.count > 0 ? activeDayRow(workout) : restDayRow(workout)
        row.title = dateFormatter.stringFromDate(workout.date)
        return row
    }

    private func restDayRow(workout: Workout) -> BaseRow {
        let row = LabelRow()
        row.value = "Rest"
        row.hidden = "$show_rest_days == false"
        return row
    }

    private func activeDayRow(workout: Workout) -> BaseRow {
        let row = LabelRow()
        if let totalWeight = workout.totalWeight {
            row.value = weightFormatter.stringFromNumber(totalWeight)
        }
        row.onCellSelection { cell, row in
            let vc = WorkoutViewController(workout: workout)
            self.showViewController(vc, sender: nil)
        }
        row.cellSetup { cell, row in
            cell.detailTextLabel?.textColor = UIColor.blackColor()
            cell.accessoryType = .DisclosureIndicator
        }
        return row
    }

}
