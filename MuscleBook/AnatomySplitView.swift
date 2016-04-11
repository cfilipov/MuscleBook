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

@IBDesignable class AnatomySplitView: UIView {

    var orientation: AnatomicalOrientation? {
        didSet {
            guard let orientation = orientation else {
                splitView.visibleSide = .Both
                return
            }
            switch orientation {
            case .Anterior:
                splitView.visibleSide = .Left
            case .Posterior:
                splitView.visibleSide = .Right
            }
        }
    }

    private var splitView = SplitSwipeView()
    private(set) var anteriorView = AnatomyView(orientation: AnatomicalOrientation.Anterior)
    private(set) var posteriorView = AnatomyView(orientation: AnatomicalOrientation.Posterior)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func canDisplay(muscle muscle: Muscle) -> Bool {
        return anteriorView.canDisplay(muscle: muscle) || posteriorView.canDisplay(muscle: muscle)
    }

    func reset() {
        anteriorView.reset()
        posteriorView.reset()
    }

    func setFillColor(color: UIColor, muscle: Muscle) -> SuccessOrFail {
        if anteriorView.setFillColor(color, muscle: muscle) == .Success {
            return .Success
        }
        if posteriorView.setFillColor(color, muscle: muscle) == .Success {
            return .Success
        }
        return .Fail
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        splitView.frame = bounds
    }

    private func commonInit() {
        splitView.left = anteriorView
        splitView.right = posteriorView
        addSubview(splitView)
    }

    func configure(config: AnatomyViewConfig) -> AnatomyViewConfig {
        var displayableConfig = config.fillColors
        config.fillColors.forEach { muscle, color in
            if setFillColor(color, muscle: muscle) == .Fail {
                displayableConfig[muscle] = nil
                print("Missing SVG for muscle: \(muscle)")
            }
        }
        orientation = config.orientation
        return AnatomyViewConfig(fillColors: displayableConfig, orientation: nil)
    }

}

