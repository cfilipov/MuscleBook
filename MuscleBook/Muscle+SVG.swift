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

class MuscleDisplay {
    static let sharedInstance = MuscleDisplay()
    let displayableMuscles: Set<Muscle>

    private init() {
        let anatomy = AnatomySplitView()
        displayableMuscles = Set(Muscle.allMuscles.filter {anatomy.canDisplay(muscle: $0)})
    }
}

extension Muscle {
    static var displayableMuscles: Set<Muscle> {
        return MuscleDisplay.sharedInstance.displayableMuscles
    }

    var isDisplayable: Bool {
        return MuscleDisplay.sharedInstance.displayableMuscles.contains(self)
    }
}
