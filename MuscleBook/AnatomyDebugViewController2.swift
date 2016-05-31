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

    let muscles = [
        (muscle: Muscle(rawValue: 13335)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 13357)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 13379)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 13397)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 22314)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 22315)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 22356)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 22357)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 22430)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 22431)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 22432)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 22538)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 22542)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 32546)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 32549)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 32555)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 32556)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 32557)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 34687)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 34696)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 37670)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 37692)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 37694)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 37704)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 38459)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 38465)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 38469)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 38485)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 38500)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 38506)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 38518)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 38521)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 45956)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 45959)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 51048)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 71302)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 74998)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 83003)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 83006)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 83007)!, color: generateRandomColor()),
        (muscle: Muscle(rawValue: 9628)!, color: generateRandomColor()),
    ]

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

    let whiteCircle = UIImage.circle(12, color: UIColor.whiteColor())

    var selections = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        view.addSubview(tableView)
        view.addSubview(anatomyView)

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
    }

    func functionButtonPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Select All", style: .Destructive) { _ in
            self.muscles.indices.forEach { self.selectMuscle(atRow: $0) }
            self.tableView.reloadData()
            })
        alert.addAction(UIAlertAction(title: "Reset", style: .Destructive) { _ in
            self.selections.removeAll()
            self.anatomyView.reset()
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    func selectMuscle(atRow row: Int) {
        selections.insert(row)
        anatomyView.setFillColor(
            muscles[row].color,
            muscle: muscles[row].muscle
        )
        anatomyView.setNeedsDisplay()
    }

    func deselectMuscle(atRow row: Int) {
        selections.remove(row)
        anatomyView.setFillColor(
            UIColor.whiteColor(),
            muscle: muscles[row].muscle
        )
        anatomyView.setNeedsDisplay()
    }
}

extension AnatomyDebugViewController2: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return muscles.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = muscles[indexPath.row].muscle.name
        cell.imageView?.image = selections.contains(indexPath.row) ? UIImage.circle(12, color: muscles[indexPath.row].color) : whiteCircle
        cell.selectionStyle = .None
        return cell
    }

    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selections.contains(indexPath.row) {
            deselectMuscle(atRow: indexPath.row)
        } else {
            selectMuscle(atRow: indexPath.row)
        }
        _ = tableView(table, cellForRowAtIndexPath: indexPath)
        table.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }

}
