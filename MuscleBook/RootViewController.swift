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

    let weightFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()

    private var selectedDate: NSDate = NSDate() {
        didSet {
            let anatomyRow = self.form.rowByTag("anatomy") as? SideBySideAnatomyViewRow
            anatomyRow?.value = try! AnatomyViewConfig(
                db.get(MuscleWorkSummary.self, date: selectedDate, movementClass: .Target)
            )
            anatomyRow?.updateCell()
        }
    }

    deinit {
        observer = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "✻", style: .Plain, target: self, action: #selector(onMenuButtonPresed))

        let notification = CocoaNotification(name: UIApplicationDidReceiveMemoryWarningNotification)
        observer = CocoaObserver(notification, queue: self.mainQueue, handler: { (notification: NSNotification) in
            self.refresh()
        })

        tableView?.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);

        title = "Muscle Book"

        let date = NSDate()

        form

        +++ Section()

        <<< PunchcardRow("punchcard") {
            $0.value = EFCalendarGraphAdapterDelegate()
            $0.onCellSelection { _, _ in
                let vc = WorkoutsByDayViewController()
                self.showViewController(vc, sender: nil)
            }
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

        form.rowByTag("workout_week")?.baseValue = NSDate()
    }

    private func refresh() {
        workoutCounts = Dictionary(try! db.countByDay(Workout))
        self.form.rowByTag("anatomy")?.updateCell()
        self.form.rowByTag("workout_week")?.updateCell()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    func onMenuButtonPresed() {
        let vc = MenuViewController()
        self.showViewController(vc, sender: nil)
    }

}
