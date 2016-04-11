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

class AnatomyDebugViewController: FormViewController {

    let anatomyRow = AnatomyViewRow()
    let anatomyView = AnatomySplitView()

    func config(forSelection string: String) -> AnatomyViewConfig {
        switch string {
        case Muscle.Legs.name:
            return AnatomyViewConfig(
                fillColors: [Muscle.Legs: UIColor.redColor()],
                orientation: Muscle.Legs.orientation
            )
        case Muscle.PectoralisMajorSternal.name:
            return AnatomyViewConfig(
                fillColors: [Muscle.PectoralisMajorSternal: UIColor.redColor()],
                orientation: Muscle.Legs.orientation
            )
        default: preconditionFailure()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Anatomy Debug"

        form +++ Section() <<< SegmentedRow<String>("segments"){
            $0.options = [Muscle.Legs.name, Muscle.PectoralisMajorSternal.name]
            $0.value = Muscle.Legs.name
        }.onChange { row in
            self.anatomyRow.value = self.config(forSelection: row.value!)
            self.anatomyRow.updateCell()
            self.anatomyView.reset()
            self.anatomyView.configure(self.config(forSelection: row.value!))
        }

        form +++ Section() <<< anatomyRow
        anatomyRow.value = self.config(forSelection: Muscle.Legs.name)

        anatomyView.frame = view.bounds.insetBy(dx: 0, dy: 80)
        tableView?.tableFooterView = anatomyView
        anatomyView.configure(config(forSelection: Muscle.Legs.name))
    }
    
}
