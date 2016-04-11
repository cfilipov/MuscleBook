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

final class MuscleListViewController: FormViewController, TypedRowControllerType {

    var row: RowOf<ExerciseReference>!
    var completionCallback : ((UIViewController) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Muscles"

        form += Muscle.muscleGroups.sort{$0.name < $1.name}.map(sectionForMuscleGroup)
    }

    private func sectionForMuscleGroup(group: Muscle) -> Section {
        precondition(group.isMuscleGroup)
        var section = Section(group.name)
        section += group.components.sort{$0.name < $1.name}.map(rowForMuscle)
        return section
    }

    private func rowForMuscle(muscle: Muscle) -> LabelRow {
        let row = LabelRow()
        row.title = muscle.name
        row.onCellSelection{ cell, row in
            let vc = AnatomyDiagramViewController(muscle: muscle)
            self.showViewController(vc, sender: nil)
        }
        return row
    }

}
