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

final class WorkoutViewController: FormViewController {

    private let workout: Workout

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Right
        label.font = UIFont.systemFontOfSize(20)
        label.text = self.dateFormatter.stringFromDate(self.workout.date)
        return label
    }()
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        return formatter
    }()

    let weightFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()

    lazy var worksetsSection: Section = {
        let worksets = try! Workset.Adapter.all(workoutID: self.workout.workoutID!)
        var section = Section("Workout Sets")
        section += worksets.map(self.workoutRecordToRow)
        return section
    }()

    private let timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    init(workout: Workout) {
        self.workout = workout
        super.init(style: .Grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Workout"

        form

            +++ Section("Summary")

            <<< LabelRow() {
                $0.title = "Date"
                $0.value = dateFormatter.stringFromDate(self.workout.date)
            }

            <<< LabelRow() {
                $0.title = "Time"
                $0.value = timeFormatter.stringFromDate(self.workout.date)
            }

            // TODO: Duration Row
            <<< LabelRow() {
                $0.title = "Total Weight Moved"
                if let totalWeight = workout.totalWeight {
                    $0.value = weightFormatter.stringFromNumber(totalWeight)
                    $0.hidden = false
                } else {
                    $0.hidden = true
                }
            }

            <<< SideBySideAnatomyViewRow("anatomy") {
                if let workoutID = self.workout.workoutID {
                    $0.value = try! AnatomyViewConfig(MuscleWorkSummary.Adapter.forWorkout(workoutID))
                }
            }

            <<< LabelRow() {
                $0.title = "Add Data Point"
            }.cellSetup { cell, row in
                cell.accessoryType = .DisclosureIndicator
            }.onCellSelection { _, _ in
                let vc = CreateWorkoutRecordViewController(workoutID: self.workout.workoutID!) { record in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    if var record = record {
                        record.worksetID = try! Workset.Adapter.save(record)
                        self.worksetsSection <<< self.workoutRecordToRow(record)
                    }
                }
                self.presentModalViewController(vc)
            }


        form +++ worksetsSection
    }

    private func workoutRecordToRow(record: Workset) -> BaseRow {
        let row = LabelRow()
        row.title = record.exerciseName
        row.value = record.valueString
        row.onCellSelection { cell, row in
            let vc = WorkoutRecordViewController(record: record)
            self.showViewController(vc, sender: nil)
        }
        row.cellSetup { cell, row in
            cell.accessoryType = .DisclosureIndicator
        }
        return row
    }

}
