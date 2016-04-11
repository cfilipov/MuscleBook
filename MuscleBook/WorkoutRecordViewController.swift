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

class WorkoutRecordViewController : FormViewController {

    private let record: Workset

    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        return formatter
    }()

    private let timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    private let weightFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()
    
    init(record: Workset) {
        self.record = record
        super.init(style: .Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Data Point"

        let section = Section()

        if let exercise = record.exerciseReference.details {
            section <<< LabelRow("exercise") {
                $0.title = "Exercise"
                $0.value = record.exerciseName
                $0.onCellSelection { cell, row in
                    let vc = ExerciseDetailViewController(exercise: exercise)
                    self.showViewController(vc, sender: nil)
                }
                $0.cell.accessoryType = .DisclosureIndicator
            }
        } else {
            section.header = HeaderFooterView(stringLiteral: "Exercise not found, please select an existing exercise")
            section <<< SelectExerciseRow("exercise") {
                $0.title = "Exercise"
                $0.value = record.exerciseReference
            }
        }

        section <<< LabelRow() {
            $0.title = "Date"
            $0.value = dateFormatter.stringFromDate(self.record.date)
        }

        section <<< LabelRow() {
            $0.title = "Time"
            $0.value = timeFormatter.stringFromDate(self.record.date)
        }

        section <<< LabelRow() {
            $0.title = "Reps"
            $0.value = String(self.record.reps)
        }

        if let weight = self.record.weight {
            section <<< LabelRow() {
                $0.title = "Weight"
                $0.value = weightFormatter.stringFromNumber(weight)
            }
        }

        if let duration = self.record.duration {
            section <<< LabelRow() {
                $0.title = "Duration"
                $0.value = weightFormatter.stringFromNumber(duration)
            }
        }

        form +++ section
    }

}