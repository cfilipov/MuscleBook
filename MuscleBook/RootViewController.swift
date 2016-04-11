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
import CVCalendar
import JSQNotificationObserverKit

class RootViewController: FormViewController {

    private let mainMenuSection = Section()
    private let mainQueue = NSOperationQueue.mainQueue()
    private var workoutCounts: [NSDate: Int] = [:]
    private var observer: CocoaObserver? = nil

    deinit {
        observer = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let notification = CocoaNotification(name: UIApplicationDidReceiveMemoryWarningNotification)
        observer = CocoaObserver(notification, queue: self.mainQueue, handler: { (notification: NSNotification) in
            self.refresh()
        })

        tableView?.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);

        title = "Muscle Book"

        let date = NSDate()

        form +++ mainMenuSection

            <<< CalendarWeekRow("workout_week") {
                $0.numberOfDotsForDate = { date -> Int in
                    self.workoutCounts[date] ?? 0
                }
                $0.onChange { row in
                    let anatomyRow = self.form.rowByTag("anatomy") as? SideBySideAnatomyViewRow
                    let date = self.form.rowByTag("workout_week")?.baseValue as! NSDate
                    anatomyRow?.value = try! AnatomyViewConfig(MuscleWorkSummary.Adapter.forDay(date))
                    anatomyRow?.updateCell()
                }
                $0.value = date
            }

            <<< SideBySideAnatomyViewRow("anatomy")

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

    private func refresh() {
        workoutCounts = Dictionary(try! Workout.countByDay())
        self.form.rowByTag("anatomy")?.updateCell()
        self.form.rowByTag("workout_week")?.updateCell()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

}
