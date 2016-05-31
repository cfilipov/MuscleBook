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

class ExerciseDetailViewController : FormViewController {

    private let db = DB.sharedInstance

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

    let formatter = NSDateFormatter()
    var muscleColorImages: [Muscle: UIImage] = [:]
    var musclesDictionary: [MuscleMovement.Classification: [Muscle]] = [:]
    let exercise: Exercise
    let anatomyRow = SideBySideAnatomyViewRow("anatomy")
    let whiteCircle = UIImage.circle(12, color: UIColor.whiteColor())

    private var performanceCount: Int {
        return db.count(Exercise.self, exerciseID: exercise.exerciseID!)
    }

    init(exercise: Exercise) {
        self.exercise = exercise
        super.init(style: .Grouped)
        let muscles = exercise.exerciseID.flatMap {
            try! db.find(exerciseID: $0)
        }
        musclesDictionary ?= muscles?.dictionary()
        let muscleColorCoding = Dictionary(
            Set<Muscle>(musclesDictionary.values.flatMap{$0})
                .map{($0,self.colorGenerator.next()!)}
        )
        var anatomyConfig = AnatomyViewConfig(fillColors: muscleColorCoding, orientation: nil)
        let tmpAnatomyView = AnatomySplitView()
        anatomyConfig = tmpAnatomyView.configure(anatomyConfig)
        anatomyRow.value = anatomyConfig
        muscleColorImages = anatomyConfig.fillColors.mapValues{UIImage.circle(12, color: $0)}
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
        
        title = "Exercise"

        form +++ Section()

        <<< LabelRow() {
            $0.title = "Name"
            $0.value = exercise.name
        }

        <<< LabelRow() {
            $0.title = "Equipment"
            $0.value = exercise.equipment.joinWithSeparator(", ")
        }

        <<< LabelRow() {
            $0.title = "Force"
            $0.value = exercise.force
        }

        <<< LabelRow() {
            $0.title = "Mechanics"
            $0.value = exercise.mechanics
        }

        <<< LabelRow() {
            $0.title = "Type"
            $0.value = exercise.type
        }

        <<< anatomyRow

        <<< PushViewControllerRow() {
            $0.title = "Statistics"
            $0.controller = { ExerciseStatisticsViewController(exercise: self.exercise.exerciseReference) }
            $0.hidden = self.performanceCount == 0 ? true : false
        }

        if let s = musclesDictionary[.Target] where !s.isEmpty {
            form +++ Section("Target Muscles") <<< s.map(rowForMuscle)
        }

        if let s = musclesDictionary[.Stabilizer] where !s.isEmpty {
            form +++ Section("Stabilizers") <<< s.map(rowForMuscle)
        }

        if let s = musclesDictionary[.Synergist] where !s.isEmpty {
            form +++ Section("Synergists") <<< s.map(rowForMuscle)
        }

        if let s = musclesDictionary[.DynamicStabilizer] where !s.isEmpty {
            form +++ Section("Dynamic Stabilizers") <<< s.map(rowForMuscle)
        }

    }

    private func rowForString(name: String) -> LabelRow {
        let row = LabelRow()
        row.title = name
        row.cellSetup(cellSetupHandler)
        return row
    }

    private func rowForMuscle(muscle: Muscle) -> LabelRow {
        let row = LabelRow()
        row.title = muscle.name
        row.cellSetup(cellSetupHandler)
        row.cellSetup { cell, row in
            cell.imageView?.image = self.muscleColorImages[muscle] ?? self.whiteCircle
        }
        return row
    }

    private func cellSetupHandler(cell: LabelCell, row: LabelRow) {
        cell.detailTextLabel?.hidden = true
    }

}
