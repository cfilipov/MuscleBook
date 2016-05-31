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

    private let db = DB.sharedInstance
    private let mainQueue = NSOperationQueue.mainQueue()
    private var workoutCounts: [NSDate: Int] = [:]
    private var observer: CocoaObserver? = nil
    private let cal = NSCalendar.currentCalendar()

    let weightFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()

    private var selectedDate: NSDate = NSDate() {
        didSet {
            refresh()
        }
    }

    private var daysSinceWorkout: Int? {
        guard let startDate = db.lastWorkoutDay() else { return nil }
        let endDate = NSDate()
        let unit = NSCalendarUnit.Day
        let components = cal.components(unit, fromDate: startDate, toDate: endDate, options: [])
        guard components.day > 0 else { return nil }
        return components.day
    }

    private var daysSinceRestDay: Int? {
        guard let startDate = db.lastRestDay() else { return nil }
        let endDate = NSDate()
        let unit = NSCalendarUnit.Day
        let components = cal.components(unit, fromDate: startDate, toDate: endDate, options: [])
        guard components.day > 0 else { return nil }
        return components.day
    }

    deinit {
        observer = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: #selector(onAddButtonPressed)
        )

        let notification = CocoaNotification(name: UIApplicationDidReceiveMemoryWarningNotification)
        observer = CocoaObserver(notification, queue: self.mainQueue, handler: { (notification: NSNotification) in
            self.refresh()
        })

        tableView?.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)

        title = "Days"
        navigationItem.title = "Muscle Book"

        let date = NSDate()

        form

        +++ Section()

        <<< PunchcardRow("punchcard") {
            $0.value = WorkoutPunchcardDelegate()
            $0.onCellSelection { _, _ in
                let vc = AllWorkoutsViewController()
                self.showViewController(vc, sender: nil)
            }
        }

        <<< LabelRow() {
            $0.title = "Last Workout"
            $0.tag = "last_workout"
            $0.hidden = "$last_workout == nil"
        }

        <<< LabelRow() {
            $0.title = "Last Rest Day"
            $0.tag = "last_rest_day"
            $0.hidden = "$last_rest_day == nil"
        }

        <<< CalendarWeekRow("workout_week") {
            $0.numberOfDotsForDate = { date -> Int in
                self.workoutCounts[date] ?? 0
            }
            $0.onChange { row in
                self.selectedDate = row.value!
            }
            $0.value = date
        }

        <<< SideBySideAnatomyViewRow("anatomy")

        <<< TextAreaRow() {
            $0.tag = "exercises"
            $0.hidden = "$exercises == nil"
            $0.textAreaHeight = .Dynamic(initialTextViewHeight: 20)
            $0.disabled = true
        }

        form.rowByTag("workout_week")?.baseValue = NSDate()

        refresh()
    }

    private func refresh() {
        workoutCounts = Dictionary(try! db.countByDay(Workout))
        form.rowByTag("anatomy")?.value = try! AnatomyViewConfig(
            db.get(MuscleWorkSummary.self, date: selectedDate, movementClass: .Target)
        )
        form.rowByTag("anatomy")?.updateCell()
        form.rowByTag("workout_week")?.updateCell()
        form.rowByTag("last_workout")?.value = formatDaysAgo(daysSinceWorkout)
        form.rowByTag("last_rest_day")?.value = formatDaysAgo(daysSinceRestDay)
        form.rowByTag("exercises")?.value = exercises
        form.rowByTag("exercises")?.updateCell()
    }

    private var exercises: String? {
        let exercises = try! db.get(ExerciseReference.self, date: selectedDate).map { $0.name }
        guard exercises.count > 0 else { return nil }
        return exercises.joinWithSeparator(", ")
    }

    private func formatDaysAgo(days: Int?) -> String? {
        guard let days = days else { return nil }
        return "\(days) days ago"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    func onAddButtonPressed() {
        let vc = WorksetViewController { record in
            self.refresh()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        presentModalViewController(vc)
    }

}

private class WorkoutPunchcardDelegate: PunchcardDelegate {
    private let db = DB.sharedInstance
    private let cal = NSCalendar.currentCalendar()
    private let activations: [NSDate: Activation]

    override init() {
        activations = try! db.activationByDay()
    }

    override func calendarGraph(calendarGraph: EFCalendarGraph!, valueForDate date: NSDate!, daysAfterStartDate: UInt, daysBeforeEndDate: UInt) -> AnyObject! {
        guard let activation = activations[cal.startOfDayForDate(date)] else { return 0 }
        switch activation {
        case .None: return 0
        case .Light: return 1
        case .Medium: return 1
        case .High: return 5
        case .Max: return 5
        }
    }
}
