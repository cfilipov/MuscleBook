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

@objc class PunchcardDelegate: NSObject, EFCalendarGraphDataSource {
    func numberOfDataPointsInCalendarGraph(calendarGraph: EFCalendarGraph!) -> UInt {
        return 364
    }

    func calendarGraph(calendarGraph: EFCalendarGraph!, valueForDate date: NSDate!, daysAfterStartDate: UInt, daysBeforeEndDate: UInt) -> AnyObject! {
        return 0
    }
}

class PunchcardCell : Cell<PunchcardDelegate>, CellType {
    
    let punchcardView: EFCalendarGraph = {
        let v = EFCalendarGraph(endDate: NSDate())
        v.baseColor = UIColor.redColor()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { 60 }
    }
    
    override func setup() {
        super.setup()
        row.title = nil
        selectionStyle = .None
        contentView.addSubview(punchcardView)
        let views : [String: AnyObject] =  ["punchcardView": punchcardView]
        contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[punchcardView]|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-15-[punchcardView]-15-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        punchcardView.dataSource = row.value
        punchcardView.reloadData()
    }
    
    override func update() {
        row.title = nil
        super.update()
    }
    
}

final class PunchcardRow: Row<PunchcardDelegate, PunchcardCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
    
}