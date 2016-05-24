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

class MenuViewController : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);

        title = "Menu"

        form

            +++ Section()

            <<< PushViewControllerRow() {
                $0.title = "Workouts"
                $0.controller = { WorkoutsByDayViewController() }
            }

            <<< PushViewControllerRow() {
                $0.title = "Exercises"
                $0.controller = { ExercisesListViewController() }
            }

            <<< PushViewControllerRow() {
                $0.title = "Muscles"
                $0.controller = { MuscleListViewController() }
            }

            <<< PushViewControllerRow() {
                $0.title = "Statistics"
                $0.controller = { StatisticsViewController() }
            }

            <<< PushViewControllerRow() {
                $0.title = "Settings"
                $0.controller = { SettingsViewController() }
        }
    }
}