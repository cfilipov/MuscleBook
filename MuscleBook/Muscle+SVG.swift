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

extension Muscle {
    var isDisplayable: Bool {
        return Muscle.displayableMuscles.contains(self)
    }

    static let displayableMuscles = [
        Muscle(rawValue: 13335)!,
        Muscle(rawValue: 13357)!,
        Muscle(rawValue: 13379)!,
        Muscle(rawValue: 13397)!,
        Muscle(rawValue: 22314)!,
        Muscle(rawValue: 22315)!,
        Muscle(rawValue: 22356)!,
        Muscle(rawValue: 22357)!,
        Muscle(rawValue: 22430)!,
        Muscle(rawValue: 22431)!,
        Muscle(rawValue: 22432)!,
        Muscle(rawValue: 22538)!,
        Muscle(rawValue: 22542)!,
        Muscle(rawValue: 32546)!,
        Muscle(rawValue: 32549)!,
        Muscle(rawValue: 32555)!,
        Muscle(rawValue: 32556)!,
        Muscle(rawValue: 32557)!,
        Muscle(rawValue: 34687)!,
        Muscle(rawValue: 34696)!,
        Muscle(rawValue: 37670)!,
        Muscle(rawValue: 37692)!,
        Muscle(rawValue: 37694)!,
        Muscle(rawValue: 37704)!,
        Muscle(rawValue: 38459)!,
        Muscle(rawValue: 38465)!,
        Muscle(rawValue: 38469)!,
        Muscle(rawValue: 38485)!,
        Muscle(rawValue: 38500)!,
        Muscle(rawValue: 38506)!,
        Muscle(rawValue: 38518)!,
        Muscle(rawValue: 38521)!,
        Muscle(rawValue: 45956)!,
        Muscle(rawValue: 45959)!,
        Muscle(rawValue: 51048)!,
        Muscle(rawValue: 71302)!,
        Muscle(rawValue: 74998)!,
        Muscle(rawValue: 83003)!,
        Muscle(rawValue: 83006)!,
        Muscle(rawValue: 83007)!,
        Muscle(rawValue: 9628)!,
    ]
}
