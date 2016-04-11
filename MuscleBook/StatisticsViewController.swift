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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Statistics"

        form +++ Section()

            <<< LabelRow() {
                $0.title = "Total Exercises"
                $0.value = String(Exercise.Adapter.count())
            }

            <<< LabelRow() {
                $0.title = "Total Muscles"
                $0.value = String(Muscle.Adapter.count())
            }

            <<< LabelRow() {
                $0.title = "Total Workout Records"
                $0.value = String(Workset.Adapter.count())
            }

            <<< LabelRow() {
                $0.title = "Total Workouts"
                $0.value = String(Workout.Adapter.count())
            }

    }
}
