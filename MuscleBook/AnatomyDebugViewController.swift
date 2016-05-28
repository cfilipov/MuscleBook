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

    lazy var colorGenerator: AnyGenerator<UIColor> = {
        let palette = [
            // http://www.graphviz.org/doc/info/colors.html
            UIColor(rgba: "#8dd3c7"),
            UIColor(rgba: "#ffffb3"),
            UIColor(rgba: "#bebada"),
            UIColor(rgba: "#fb8072"),
            UIColor(rgba: "#80b1d3"),
            UIColor(rgba: "#fdb462"),
            UIColor(rgba: "#b3de69"),
            UIColor(rgba: "#fccde5"),
            UIColor(rgba: "#d9d9d9"),
            UIColor(rgba: "#bc80bd"),
            UIColor(rgba: "#ccebc5"),
            UIColor(rgba: "#ffed6f"),
            ]
        return palette.repeatGenerator
    }()

    lazy var displayableMuscles: [Muscle: UIColor] = {
        let fillColors = Dictionary(Muscle.allMuscles.map { ($0, self.colorGenerator.next()!) })
        var anatomyConfig = AnatomyViewConfig(fillColors: fillColors, orientation: nil)
        let tmpAnatomyView = AnatomySplitView()
        anatomyConfig = tmpAnatomyView.configure(anatomyConfig)
        var displayableMuscles = Dictionary(anatomyConfig.fillColors.keys.map { ($0,self.colorGenerator.next()!) })
        return displayableMuscles
    }()

    var anatomyConfig: AnatomyViewConfig {
        return AnatomyViewConfig(fillColors: displayableMuscles, orientation: nil)
    }

    let whiteCircle = UIImage.circle(12, color: UIColor.whiteColor())

    func updateAnatomyView() {
        let anatomyRow = self.form.rowByTag("anatomy") as? SideBySideAnatomyViewRow
        anatomyRow?.value = anatomyConfig
        anatomyRow?.updateCell()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);

        title = "Anatomy Debug"

        form

        +++ Section()

        <<< SideBySideAnatomyViewRow("anatomy")

        +++ SelectableSection<ImageCheckRow<Bool>, Bool>("Displayable Muscles", selectionType: .MultipleSelection)

        for (muscle, color) in displayableMuscles {
            form.last! <<< ImageCheckRow<Bool>(){ lrow in
                lrow.title = muscle.name
                lrow.selectableValue = false
                lrow.value = nil
            }.cellSetup { cell, _ in
                cell.trueImage = UIImage.circle(12, color: color)
                cell.falseImage = self.whiteCircle
            }.onChange { row in
                if row.value ?? false {
                    self.displayableMuscles[muscle] = UIColor.whiteColor()
                }
                else {
                    self.displayableMuscles[muscle] = color
                }
                self.updateAnatomyView()
            }
        }

    }

}
