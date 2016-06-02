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

class ColorPaletteViewController: UITableViewController {

    init() {
        super.init(style: .Plain)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Colors"
        tableView.reloadData()
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorPalette.count
    }

    override func tableView(_: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") ?? UITableViewCell(style: .Value1, reuseIdentifier: "cell")
        let color = colorPalette[indexPath.row]
        cell.imageView?.image = UIImage.circle(25, color: color)
        cell.detailTextLabel?.text = color.hexString(false)
        cell.selectionStyle = .None
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
}

