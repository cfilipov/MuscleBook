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

class ExercisesListViewController: UITableViewController, TypedRowControllerType {

    enum SortBy: Int {
        case Alpha = 0
        case Count
    }

    private let db = DB.sharedInstance

    var row: RowOf<ExerciseReference>!
    var completionCallback : ((UIViewController) -> ())?

    private var sortBy = SortBy.Alpha {
        didSet {
            tableView.reloadData()
        }
    }

    private let formatter = NSDateFormatter()
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredExercises: [ExerciseReference] = []

    private lazy var allExercises: [ExerciseReference] = {
        return (try? self.db.all(Exercise)) ?? []
    }()

    var exercises: [ExerciseReference] {
        let ex = searchController.active ? filteredExercises : allExercises
        switch sortBy {
        case .Alpha: return ex.sort { a, b in a.name < b.name }
        case .Count: return ex.sort { a, b in a.count > b.count }
        }
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

    init() {
        super.init(style: .Plain)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Exercises"
        navigationItem.rightBarButtonItem = self.segmentBarButtonItem
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView?.tableHeaderView = searchController.searchBar
        tableView?.reloadData()
        tableView?.setContentOffset(CGPoint(x: 0, y: 44), animated: false)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExerciseCell")
        let ex = exercises[indexPath.row]
        if cell == nil { cell = UITableViewCell(style: .Value1, reuseIdentifier: "ExerciseCell") }
        cell!.textLabel?.text = ex.name
        cell?.detailTextLabel?.text = ex.count > 0 ? String(ex.count) : nil
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ref = exercises[indexPath.row]
        let ex = db.dereference(ref)
        let vc = ExerciseDetailViewController(exercise: ex!)
        showViewController(vc, sender: nil)
        searchController.active = false
    }

    private func filterContentForSearchText(searchText: String, scope: String = "All") {
        guard !searchText.isEmpty else {
            filteredExercises = allExercises
            tableView!.reloadData()
            return
        }
        filteredExercises = try! db.match2(name: searchText)
        tableView!.reloadData()
    }

    func orderSegmentValueChanged() {
        sortBy = SortBy(rawValue: segmentedControl.selectedSegmentIndex)!
    }
}

extension ExercisesListViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
