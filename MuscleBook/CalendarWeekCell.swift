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

import Foundation
import Eureka
import CVCalendar

class CalendarWeekCell : Cell<NSDate>, CellType, CVCalendarViewDelegate , CVCalendar.MenuViewDelegate, CVCalendarViewAppearanceDelegate {

    let cal = NSCalendar.currentCalendar()

    var numberOfDotsForDate: NSDate -> Int

    @IBOutlet var menuView: CVCalendarMenuView!
    @IBOutlet var calendarView: CVCalendarView!

    required init?(coder aDecoder: NSCoder) {
        numberOfDotsForDate = { _ in return 0 }
        super.init(coder: aDecoder)
    }

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        numberOfDotsForDate = { _ in return 0 }
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func setup() {
        super.setup()
        row.title = nil
        selectionStyle = .None
        menuView.menuViewDelegate = self
        calendarView.calendarDelegate = self
        calendarView.calendarAppearanceDelegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsUpdateConstraints()
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }

    override func update() {
        row.title = nil
        super.update()

        if let date = row.value {
            calendarView.presentedDate = CVDate(date: date)
            calendarView.contentController.refreshPresentedMonth()
//            calendarView.toggleCurrentDayView()
        }
    }

    func presentationMode() -> CVCalendar.CalendarMode {
        return .WeekView
    }

    func firstWeekday() -> CVCalendar.Weekday {
        return .Sunday
    }

    func shouldShowWeekdaysOut() -> Bool {
        return true
    }

    func shouldScrollOnOutDayViewSelection() -> Bool {
        return false
    }

    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        guard let date = dayView.date.convertedDate() else { return false }
        return numberOfDotsForDate(cal.startOfDayForDate(date)) > 0
    }

    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        guard let date = dayView.date.convertedDate() else { return [] }
        switch numberOfDotsForDate(cal.startOfDayForDate(date)) {
        case 0:
            return []
        case 1:
            return [UIColor.redColor()]
        case 2:
            return [UIColor.redColor(), UIColor.redColor()]
        default:
            return [UIColor.redColor(), UIColor.redColor(), UIColor.redColor()]
        }
    }

    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }

    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 14
    }

    func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat {
        return 10
    }

    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor.redColor()
    }

    func presentedDateUpdated(date: CVDate) {
        row.value = cal.startOfDayForDate(date.convertedDate()!)
    }

}

final class CalendarWeekRow: Row<NSDate, CalendarWeekCell>, RowType {

    var numberOfDotsForDate: NSDate -> Int {
        get {
            return cell.numberOfDotsForDate
        }
        set(newVal) {
            cell.numberOfDotsForDate = newVal
        }
    }

    required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<CalendarWeekCell>(nibName: "CalendarWeekCell")
    }
    
}
