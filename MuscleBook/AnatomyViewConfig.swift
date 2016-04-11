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

class AnatomyViewConfig: Equatable {
    let fillColors: [Muscle: UIColor]
    var orientation: AnatomicalOrientation? = nil

    init(fillColors: [Muscle: UIColor], orientation: AnatomicalOrientation? = nil) {
        self.fillColors = fillColors
        self.orientation = orientation
    }
}

func ==(lhs: AnatomyViewConfig, rhs: AnatomyViewConfig) -> Bool {
    return lhs === rhs
}

extension AnatomyViewConfig {
    convenience init(_ summary: [MuscleWorkSummary]) {
        let colorMapping = Dictionary(summary
            .flatMap { $0.activation }
            .map { return ($0.muscle, $0.color) }
        )
        self.init(fillColors: colorMapping)
    }
}