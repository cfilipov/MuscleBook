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

class ExercisesListViewController: UITableViewController {

    enum Mode {
        case Browse
        case Select(callback: ExerciseReference -> Void)

        var title: String {
            switch self {
            case .Browse: return "Exercises"
            case .Select(_): return "Select an Exercise"
            }
        }
    }

    private let db = DB.sharedInstance
    private let mode: Mode

    private var sort = Exercise.SortType.Alphabetical {
        didSet {
            updateFilteredExercises()
            updateUnfilteredExercises()
        }
    }

    private let formatter = NSDateFormatter()
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredExercises: [ExerciseReference] = []
    private var unfilteredExercises: [ExerciseReference] = []

    var exercises: [ExerciseReference] {
        return searchController.active ? filteredExercises : unfilteredExercises
    }

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Az", "123"])
        control.addTarget(self, action: #selector(orderSegmentValueChanged), forControlEvents: .ValueChanged)
        control.selectedSegmentIndex = 0
        return control
    }()

    private var flexibleItem: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    }

    private lazy var segmentBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(customView: self.segmentedControl)
        return item
    }()

    private lazy var items: [UIBarButtonItem] = {
        return [self.segmentBarButtonItem, self.flexibleItem]
    }()

    init(callback: ExerciseReference -> Void) {
        mode = .Select(callback: callback)
        super.init(style: .Plain)
    }

    init() {
        mode = .Browse
        super.init(style: .Plain)
    }

    required init?(coder aDecoder: NSCoder) {
        mode = .Browse
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = mode.title
        navigationItem.rightBarButtonItem = self.segmentBarButtonItem
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView?.setContentOffset(CGPoint(x: 0, y: 44), animated: false)
        tableView?.tableHeaderView = searchController.searchBar
        updateUnfilteredExercises()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExerciseCell")
        let ex = exercises[indexPath.row]
        if cell == nil { cell = UITableViewCell(style: .Value1, reuseIdentifier: "ExerciseCell") }
        cell?.textLabel?.text = ex.name
        cell?.detailTextLabel?.text = ex.count > 0 ? String(ex.count) : nil
        switch mode {
        case .Browse: cell?.accessoryType = .DisclosureIndicator
        case .Select(_): cell?.accessoryType = .DetailButton
        }
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ref = exercises[indexPath.row]
        switch mode {
        case .Browse:
            let ex = db.dereference(ref)
            let vc = ExerciseDetailViewController(exercise: ex!)
            showViewController(vc, sender: nil)
            searchController.active = false
        case .Select(let callback):
            callback(ref)
        }
    }

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let ref = exercises[indexPath.row]
        guard let exercise = db.dereference(ref) else { return }
        let vc = ExerciseDetailViewController(exercise: exercise)
        showViewController(vc, sender: nil)
        searchController.active = false
    }

    func orderSegmentValueChanged() {
        sort = Exercise.SortType(rawValue: segmentedControl.selectedSegmentIndex)!
    }

    private func updateFilteredExercises() {
        defer { tableView?.reloadData() }
        guard let searchText = searchController.searchBar.text where !searchText.isEmpty else {
            filteredExercises = unfilteredExercises
            return
        }
        filteredExercises = try! db.match(name: searchText, sort: sort)
    }

    private func updateUnfilteredExercises() {
        unfilteredExercises = try! self.db.all(Exercise.self, sort: sort)
        tableView?.reloadData()
    }
}

extension ExercisesListViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        updateFilteredExercises()
    }
}
