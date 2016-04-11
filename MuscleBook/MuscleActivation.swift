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

struct MuscleActivation {
    let muscle: Muscle
    let movementClass: MuscleMovement.Classification
    let intensity: Activation
    let volume: Activation
}

extension MuscleActivation {
    var overallActivation: Activation {
        switch (intensity, volume) {
        case (.None, _): return volume
        case (_, .None): return .None
        case (.Light, _): return .Light
        case (_, .Light): return .Light
        case (.High, .Normal): return .High
        case (.Normal, .High): return .High
        case (.Max, .Max): return .Max
        default: return max(intensity, volume)
        }
    }

    var color: UIColor {
        return movementClass
            .color
            .colorWithAlphaComponent(overallActivation.alpha)
    }
}