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

class AnatomyView: UIView {
    let orientation: AnatomicalOrientation

    private lazy var image: JAMSVGImage = {
        let image = JAMSVGImage(named: self.orientation.name)
        image.pathsDict["body-background"]!.fillColor = UIColor.whiteColor()
        image.classDict["muscle"]!.forEach{$0.fillColor = UIColor.whiteColor()}
        return image
    }()

    private lazy var svgView: JAMSVGImageView = {
        let view = JAMSVGImageView(SVGImage: self.image)
        view.backgroundColor = UIColor.whiteColor()
        view.contentMode = .ScaleAspectFit
        return view
    }()

    init(orientation: AnatomicalOrientation) {
        self.orientation = orientation
        super.init(frame: CGRectZero)
        layer.contentsGravity = kCAGravityCenter
        layer.opaque = true
        addSubview(svgView)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    func reset() {
        svgView.svgImage = nil
        svgView.svgImage = image
        image.pathsDict["body-background"]!.fillColor = UIColor.whiteColor()
        image.classDict["muscle"]!.forEach{$0.fillColor = UIColor.whiteColor()}
    }

    func canDisplay(muscle muscle: Muscle) -> Bool {
        for m in muscle.flattenedComponents {
            if let fmaID = m.fmaID, _ = image.pathsDict[fmaID] {
                return true
            }
        }
        return false
    }

    func setFillColor(color: UIColor, muscle: Muscle) -> SuccessOrFail {
        var status = SuccessOrFail.Fail
        for m in muscle.flattenedComponents {
            if let fmaID = m.fmaID, path = image.pathsDict[fmaID] {
                path.fillColor = color
                status = .Success
            }
        }
        svgView.setNeedsDisplay()
        return status
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach{$0.frame=self.bounds}
    }
}