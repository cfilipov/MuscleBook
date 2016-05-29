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

class StatisticsViewController : FormViewController {
    
    private let db = DB.sharedInstance

    private let startDate = NSDate(timeIntervalSince1970: 0)

    private let numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Statistics"

        form

        +++ Section("Totals")

        <<< LabelRow() {
            $0.title = "Workouts"
            $0.value = self
                .numberFormatter
                .stringFromNumber(db.count(Workout))
        }

        <<< LabelRow() {
            $0.title = "Sets"
            $0.value = self
                .numberFormatter
                .stringFromNumber(db.count(Workset))
        }

        <<< LabelRow() {
            $0.title = "Reps"
            $0.value = self
                .numberFormatter
                .stringFromOptionalNumber(db.totalReps(sinceDate: self.startDate))
        }

        <<< LabelRow() {
            $0.title = "Distinct Exercises"
            $0.value = self
                .numberFormatter
                .stringFromNumber(db.totalExercisesPerformed(sinceDate: self.startDate))
        }

        <<< LabelRow("volume") {
            $0.title = "Volume"
            $0.value = self
                .numberFormatter
                .stringFromOptionalNumber(db.totalVolume(sinceDate: self.startDate))
            $0.hidden = "$volume == nil"
        }

        <<< LabelRow() {
            $0.title = "PRs"
            $0.value = self
                .numberFormatter
                .stringFromNumber(db.totalPRs(sinceDate: self.startDate))
        }

        <<< LabelRow("active_time") {
            $0.title = "Active Time (min)"
            if let d = db.totalActiveDuration(sinceDate: self.startDate) {
                $0.value = self
                    .numberFormatter
                    .stringFromOptionalNumber(d / 60)
            }
            $0.hidden = "$active_time == nil"
        }

        +++ Section("\"Big 3\"")

        <<< LabelRow() {
            $0.title = "Squat"
            $0.value = self
                .numberFormatter
                .stringFromOptionalNumber(db.maxSquat(sinceDate: self.startDate)) ?? "N/A"
        }

        <<< LabelRow() {
            $0.title = "Deadlift"
            $0.value = self
                .numberFormatter
                .stringFromOptionalNumber(db.maxDeadlift(sinceDate: self.startDate)) ?? "N/A"
        }

        <<< LabelRow() {
            $0.title = "Bench Press"
            $0.value = self
                .numberFormatter
                .stringFromOptionalNumber(db.maxBench(sinceDate: self.startDate)) ?? "N/A"
        }

        <<< LabelRow() {
            var total: Double = 0
            total += db.maxSquat(sinceDate: self.startDate) ?? 0
            total += db.maxDeadlift(sinceDate: self.startDate) ?? 0
            total += db.maxBench(sinceDate: self.startDate) ?? 0
            $0.title = "Total"
            $0.value = self.numberFormatter.stringFromNumber(total)
        }

    }
}
