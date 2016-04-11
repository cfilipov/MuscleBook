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

import Foundation
import Eureka

func <<< <C : CollectionType where C.Generator.Element == BaseRow>(lhs: Eureka.Section, rhs: C) -> Eureka.Section {
    lhs.appendContentsOf(rhs)
    return lhs
}

extension BaseCell {
    private var errorAccessoryView: UIView {
        let errorImage = JAMSVGImage(named: "noun_179916_cc")
        errorImage.styledPaths.forEach{$0.fillColor=UIColor.redColor()}
        let errorView = UIImageView(image: errorImage.imageAtSize(CGSize(width: 22, height: 22)))
        errorView.contentMode = .Right
        errorView.frame = CGRect(x: 0, y: 0, width: 33, height: 22)
        return errorView
    }

    func showErrorAccessoryView(show: Bool) {
        switch show {
        case true:
            accessoryType = .None
            accessoryView = self.errorAccessoryView
        case false:
            accessoryView = nil
            accessoryType = .DisclosureIndicator
        }
    }
}