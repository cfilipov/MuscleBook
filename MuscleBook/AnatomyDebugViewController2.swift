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

class AnatomyDebugViewController2: UIViewController {

    let anteriorColorGenerator = colorPalette.repeatGenerator
    let posteriorColorGenerator = colorPalette.repeatGenerator

    typealias Section = (title: String, muscles: [Muscle], colors: [UIColor])

    lazy var sections: [Section] = {
        [
            (
                title: "Anterior",
                muscles: Muscle.displayableMuscles.filter { (m: Muscle) -> Bool in m.orientation == .Anterior },
                colors: Muscle.displayableMuscles.indices.map { _ in self.anteriorColorGenerator.next()! }
            ),
            (
                title: "Posterior",
                muscles: Muscle.displayableMuscles.filter { (m: Muscle) -> Bool in m.orientation == .Posterior },
                colors: Muscle.displayableMuscles.indices.map { _ in self.posteriorColorGenerator.next()! }
            )
        ]
    }()

    lazy var anatomyView: SideBySideAnatomyView = {
        let anatomyView = SideBySideAnatomyView()
        anatomyView.translatesAutoresizingMaskIntoConstraints = false
        return anatomyView
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .Plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    let whiteCircle = UIImage.circle(14, color: UIColor.whiteColor())

    var selections = Set<NSIndexPath>()

    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
        automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        view.addSubview(anatomyView)

        tableView.backgroundColor = UIColor.whiteColor()
        view.backgroundColor = UIColor.whiteColor()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Function",
            style: .Plain,
            target: self,
            action: #selector(functionButtonPressed)
        )

        anatomyView
            .heightAnchor
            .constraintEqualToConstant(200)
            .active = true
        anatomyView
            .topAnchor
            .constraintEqualToAnchor(topLayoutGuide.bottomAnchor)
            .active = true
        anatomyView
            .bottomAnchor
            .constraintEqualToAnchor(tableView.topAnchor)
            .active = true
        anatomyView
            .leadingAnchor
            .constraintEqualToAnchor(
                self.view.leadingAnchor
            ).active = true
        anatomyView
            .trailingAnchor
            .constraintEqualToAnchor(
                self.view.trailingAnchor
            ).active = true

        tableView
            .topAnchor
            .constraintEqualToAnchor(anatomyView.bottomAnchor)
            .active = true
        tableView
            .bottomAnchor
            .constraintEqualToAnchor(bottomLayoutGuide.topAnchor)
            .active = true
        tableView
            .leadingAnchor
            .constraintEqualToAnchor(view.leadingAnchor)
            .active = true
        tableView
            .trailingAnchor
            .constraintEqualToAnchor(view.trailingAnchor)
            .active = true

        tableView.reloadData()
        self.selectAll()
    }

    func functionButtonPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Select All", style: .Destructive) { _ in
            self.selectAll()
            })
        alert.addAction(UIAlertAction(title: "Reset", style: .Destructive) { _ in
            self.reset()
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    func selectAll() {
        sections[0].muscles.indices.forEach {
            selectMuscle(atindexPath: NSIndexPath(forRow: $0, inSection: 0))
        }
        sections[1].muscles.indices.forEach {
            selectMuscle(atindexPath: NSIndexPath(forRow: $0, inSection: 1))
        }
        tableView.reloadData()
    }

    func reset() {
        selections.removeAll()
        anatomyView.reset()
        tableView.reloadData()
    }

    func selectMuscle(atindexPath path: NSIndexPath) {
        selections.insert(path)
        anatomyView.setFillColor(
            sections[path.section].colors[path.row],
            muscle: sections[path.section].muscles[path.row]
        )
        anatomyView.setNeedsDisplay()
    }

    func deselectMuscle(atindexPath path: NSIndexPath) {
        selections.remove(path)
        anatomyView.setFillColor(
            UIColor.whiteColor(),
            muscle: sections[path.section].muscles[path.row]
        )
        anatomyView.setNeedsDisplay()
    }
}

extension AnatomyDebugViewController2: UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(_: UITableView) -> Int {
        return sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].muscles.count
    }

    func tableView(_: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let muscle = sections[indexPath.section].muscles[indexPath.row]
        let color = sections[indexPath.section].colors[indexPath.row]
        cell.textLabel?.text = muscle.name
        cell.imageView?.image = selections.contains(indexPath) ? UIImage.circle(12, color: color) : whiteCircle
        cell.selectionStyle = .None
        return cell
    }

    func tableView(_: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selections.contains(indexPath) {
            deselectMuscle(atindexPath: indexPath)
        } else {
            selectMuscle(atindexPath: indexPath)
        }
        _ = tableView(tableView, cellForRowAtIndexPath: indexPath)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.whiteColor()
    }

}
