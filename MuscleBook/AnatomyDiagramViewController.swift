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

class AnatomyDiagramViewController: FormViewController {

    let muscle: Muscle

    init(muscle: Muscle) {
        self.muscle = muscle
        super.init(style: .Grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Muscle"

        form +++ Section()
            <<< LabelRow() {
                $0.title = muscle.name
            }
            <<< AnatomyViewRow() {
                $0.value = AnatomyViewConfig(fillColors: [muscle: UIColor.redColor()], orientation: muscle.orientation)
                $0.hidden = self.muscle.isDisplayable ? false : true
            }

        if muscle.isMuscleGroup {
            var section = Section("Component Muscles")
            section += muscle.components.map(rowForMuscle)
            form +++ section
        }
    }

    private func rowForMuscle(muscle: Muscle) -> LabelRow {
        let row = LabelRow()
        row.title = muscle.name
        row.onCellSelection{ cell, row in
            let vc = AnatomyDiagramViewController(muscle: muscle)
            self.showViewController(vc, sender: nil)
        }
        row.cellSetup { cell, row in
            if muscle.isDisplayable {
                cell.accessoryType = .DisclosureIndicator
            }
        }
        return row
    }

}
