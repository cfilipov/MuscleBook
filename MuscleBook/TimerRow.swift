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

public class TimerCell : Cell<Double>, CellType {

    public typealias Value = Bool
    private var timer: NSTimer?

    enum State {
        case Clear
        case Timing(startTime: NSDate)
        case Paused(startTime: NSDate, endTime: NSDate)

        static func isValidTransition(old old: State, new: State) -> Bool {
            switch (old, new) {
            case (.Clear, .Timing): return true
            case (.Timing, .Paused): return true
            case (.Paused, .Clear): return true
            case (.Paused, .Timing): return true
            default: return false
            }
        }
    }

    private let timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    var state = State.Clear {
        willSet(newState) {
            assert(State.isValidTransition(old: state, new: newState))
        }
        didSet {
            switch state {
            case .Clear:
                row.value = nil
                accessoryView = startButton
                editingAccessoryView = accessoryView
                updateTime()
            case .Timing(_):
                row.value = nil
                accessoryView = pauseButton
                editingAccessoryView = accessoryView
                timer = NSTimer.scheduledTimerWithTimeInterval(
                    0.05,
                    target:self,
                    selector: #selector(TimerCell.updateTime),
                    userInfo: nil,
                    repeats: true
                )
            case .Paused(let startTime, let endTime):
                row.value = endTime.timeIntervalSinceDate(startTime)
                accessoryView = startButton
                editingAccessoryView = accessoryView
                timer?.invalidate()
                timer = nil
                updateTime()
            }
        }
    }

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public lazy var startButton: UIButton = {
        let button = UIButton(type: .System)
        button.setTitle("START", forState: .Normal)
        button.addTarget(self, action: #selector(TimerCell.start), forControlEvents: .TouchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 30)
        button.contentHorizontalAlignment = .Right;
        return button
    }()

    public lazy var pauseButton: UIButton = {
        let button = UIButton(type: .System)
        button.setTitle("STOP", forState: .Normal)
        button.addTarget(self, action: #selector(TimerCell.pause), forControlEvents: .TouchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 30)
        button.contentHorizontalAlignment = .Right;
        return button
    }()

    public override func setup() {
        super.setup()
        selectionStyle = .None
        startButton.enabled = !row.isDisabled
        pauseButton.enabled = !row.isDisabled
        accessoryView = startButton
        editingAccessoryView = accessoryView
        detailTextLabel?.textAlignment = .Center
        detailTextLabel?.font = UIFont(name: "Menlo", size: UIFont.systemFontSize())
    }

    public override func update() {
        super.update()
        if row.isDisabled {
            accessoryView = nil
            editingAccessoryView = accessoryView
        }
        updateTime()
    }

    deinit {
        startButton.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        pauseButton.removeTarget(self, action: nil, forControlEvents: .AllEvents)
    }

    func start() {
        switch state {
        case .Clear:
            state = .Timing(startTime: NSDate())
        case .Paused(let startTime, _):
            state = .Timing(startTime: startTime)
        default: fatalError("Unexpected state: \(state)")
        }
    }

    func pause() {
        switch state {
        case .Timing(let startTime):
            state = .Paused(startTime: startTime, endTime: NSDate())
        default: fatalError("Unexpected state: \(state)")
        }
    }

    func reset() {
        switch state {
        case .Paused(_, _):
            state = .Clear
        default: fatalError("Unexpected state: \(state)")
        }
    }

    func updateTime() {
        switch state {
        case .Clear:
            detailTextLabel?.text = row.displayValueFor?(row.value ?? 0)
        case .Timing(let startTime):
            detailTextLabel?.text = row.displayValueFor?(NSDate().timeIntervalSinceDate(startTime))
        case .Paused(_, _):
            detailTextLabel?.text = row.displayValueFor?(row.value)
        }
    }
}

// MARK: TimerRow

public class _TimerRow: Row<Double, TimerCell>, NoValueDisplayTextConformance {
    public var noValueDisplayText: String? = "00:00:000"

    public var startTime: NSDate? {
        guard case let .Paused(startTime, _) = cell.state else { return nil }
        return startTime
    }

    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { value in
            guard let value = value else { return nil }
            let min = String(format: "%02d", Int(value / 60.0))
            let sec = String(format: "%02d", Int(value % 60))
            let mil = String(format: "%03d", Int((value % 1) * 1000))
            return "\(min):\(sec):\(mil)"
        }
    }

    public override func customDidSelect() {
        super.customDidSelect()
        if case let .Paused(startTime, _) = cell.state {
            let alert = UIAlertController(title: "Timer Actions", message: "Start Time: \(self.cell.timeFormatter.stringFromDate(startTime))", preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Reset", style: .Destructive, handler: { _ in self.cell.reset()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            cell.formViewController()!.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

public final class TimerRow: _TimerRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
