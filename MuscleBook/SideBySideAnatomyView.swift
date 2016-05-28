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

class SideBySideAnatomyView: UIView {

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
        let (leftRect, rightRect) = bounds.divide(bounds.midX, fromEdge: .MinXEdge)
        anteriorView.frame = leftRect
        posteriorView.frame = rightRect
    }

    private func commonInit() {
        addSubview(anteriorView)
        addSubview(posteriorView)
    }

    func configure(config: AnatomyViewConfig) -> AnatomyViewConfig {
        reset()
        var displayableConfig = config.fillColors
        for (muscle, color) in config.fillColors {
            if setFillColor(color, muscle: muscle) == .Fail {
                displayableConfig[muscle] = nil
                print("Missing SVG for muscle: \(muscle)")
            }
            break
        }
        return AnatomyViewConfig(fillColors: displayableConfig, orientation: nil)
    }
}
