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

public final class ImageCheckRow<T: Equatable>: Row<T, ImageCheckCell<T>>, SelectableRowType, RowType {
    public var selectableValue: T?
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class ImageCheckCell<T: Equatable> : Cell<T>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    lazy public var trueImage: UIImage = {
        return UIImage(named: "selected")!
    }()

    lazy public var falseImage: UIImage = {
        return UIImage(named: "unselected")!
    }()

    public override func update() {
        super.update()
        accessoryType = .None
        imageView?.image = row.value != nil ? trueImage : falseImage
    }

    public override func setup() {
        super.setup()
    }

    public override func didSelect() {
        row.reload()
        row.select()
        row.deselect()
    }

}