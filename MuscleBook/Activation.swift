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

enum Activation: Int64, Comparable {
    case None = 1
    case Light // Below average intensity and volume
    case Medium // Above average intensity or volume
    case High // High intensity or volume (> 80% best)
    case Max // New PR or failure set
}

func <(lhs: Activation, rhs: Activation) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

extension Activation {
    init(percent: Double) {
        if percent == 0 { self = .None }
        else if percent > 1.0 { self = .Max }
        else if percent >= 0.8 { self = .High }
        else if percent < 0.5 { self = .Light }
        else { self = .Medium }
    }

    var color: UIColor {
        switch self {
        case .None: return UIColor.whiteColor()
        case .Light: return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.15)
        case .Medium: return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
        case .High: return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.8)
        case .Max: return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }

    static var all: [Activation] {
        return [.None, .Light, .Medium, .High, .Max]
    }

    var name: String {
        switch self {
        case .None: return "None"
        case .Light: return "Light"
        case .Medium: return "Medium"
        case .High: return "High"
        case .Max: return "Max"
        }
    }
}
