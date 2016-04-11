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

@IBDesignable class SplitSwipeView: UIView, UIScrollViewDelegate {

    enum Side: CGFloat {
        case Both = 1
        case Left = 0
        case Right = 2
    }

    var visibleSide: Side = .Both {
        didSet {
            let offset = CGPoint(x: bounds.width * visibleSide.rawValue, y: 0)
            pageView.setContentOffset(offset, animated: true)
        }
    }

    private let divider = UIView()
    private let pageView = UIScrollView()
    private let leftMaskLayer = CAShapeLayer()
    private let rightMaskLayer = CAShapeLayer()

    var left = UIView() {
        didSet(oldValue) {
            insertSubview(left, atIndex: 0)
            oldValue.removeFromSuperview()
        }
    }

    var right = UIView() {
        didSet(oldValue) {
            oldValue.removeFromSuperview()
            insertSubview(right, atIndex: 1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        insertSubview(left, atIndex: 0)
        insertSubview(right, atIndex: 1)
        pageView.delegate = self
        pageView.pagingEnabled = true
        pageView.scrollEnabled = true
        pageView.alwaysBounceVertical = false
        pageView.alwaysBounceHorizontal = true
        pageView.directionalLockEnabled = true
        pageView.showsHorizontalScrollIndicator = false
        pageView.showsVerticalScrollIndicator = false
        addSubview(pageView)
        divider.backgroundColor = UIColor.blackColor()
        addSubview(divider)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        divider.frame = CGRect(x: bounds.midX, y: 0, width: 0.5, height: bounds.height)
        pageView.frame = bounds
        pageView.contentSize = CGSize(width: bounds.width * 3, height: bounds.width)
        pageView.contentOffset = CGPoint(x: bounds.width * visibleSide.rawValue, y: 0)
        left.frame = bounds
        left.layer.mask = rightMaskLayer
        right.frame = bounds
        right.layer.mask = leftMaskLayer;
        updateMaskLayerPath()
    }

    private func updateMaskLayerPath() {
        let div = pageView.contentOffset.x / 2
        let (leftMaskRect, rightMaskRect) = bounds.divide(div, fromEdge: .MaxXEdge)
        leftMaskLayer.path = CGPathCreateWithRect(leftMaskRect, nil)
        rightMaskLayer.path = CGPathCreateWithRect(rightMaskRect, nil)
        divider.frame.origin.x = leftMaskRect.minX
    }

    @objc func scrollViewDidScroll(scrollView: UIScrollView) {
        updateMaskLayerPath()
    }
}

