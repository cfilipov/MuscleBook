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
        formatter.dateFormat = "dd EEE"
        return formatter
    }()

    let timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
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
        let allWorkouts = try! db.all(Workout)
        var curMonth: String? = nil
        var curSection: Section? = nil
        for w in allWorkouts {
            let month = monthFormatter.stringFromDate(w.startTime)
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
        let row = activeDayRow(workout)
        //let row = workout.reps > 0 ? activeDayRow(workout) : restDayRow(workout)
        return row
    }

    private func restDayRow(workout: Workout) -> BaseRow {
        let row = LabelRow()
        row.value = "Rest"
        row.hidden = "$show_rest_days == false"
        row.title = dateFormatter.stringFromDate(workout.startTime)
        return row
    }

    private func activeDayRow(workout: Workout) -> BaseRow {
        let row = LabelRow()
        row.title = dateFormatter.stringFromDate(workout.startTime)
        row.cellSetup { cell, row in
            cell.detailTextLabel?.textColor = UIColor.blackColor()
            cell.accessoryType = .DisclosureIndicator
        }
        row.cellUpdate { cell, row in
            cell.detailTextLabel?.text = self.timeFormatter.stringFromDate(workout.startTime)
        }
        row.onCellSelection { cell, row in
            let vc = WorkoutViewController(workout: workout)
            self.showViewController(vc, sender: nil)
        }
        return row
    }

}
