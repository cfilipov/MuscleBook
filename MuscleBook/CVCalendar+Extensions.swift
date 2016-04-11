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
import CVCalendar

extension CVDate {
    public override var hashValue: Int {
        return year ^ month ^ week ^ day
    }

    /* NSObjectProtocol */
    public override func isEqual(object: AnyObject?) -> Bool {
        guard let lhs = object else { return false }
        let rhs = self
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.week == rhs.week && lhs.day == rhs.day
    }

    public override var hash: Int {
        return year ^ month ^ week ^ day
    }
}

func == (lhs: CVDate, rhs: CVDate) -> Bool {
    return lhs.year == rhs.year &&
        lhs.month == rhs.month &&
        lhs.week == rhs.week &&
        lhs.day == rhs.day
}