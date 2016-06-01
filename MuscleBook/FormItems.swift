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

public final class PushViewControllerRow : _ButtonRowOf<String>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    public var controller: (Void -> UIViewController)? {
        didSet {
            guard let controller = controller else { return }
            presentationMode = .Show(
                controllerProvider: ControllerProvider.Callback {
                    return controller()
                },
                completionCallback: { vc in
                    vc.navigationController?.popViewControllerAnimated(true)
                }
            )
        }
    }
}

public final class ModelViewControllerRow : _ButtonRowOf<String>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }

    public var controller: (Void -> UIViewController)? {
        didSet {
            guard let controller = controller else { return }
            presentationMode = .PresentModally(
                controllerProvider: ControllerProvider.Callback {
                    return controller()
                },
                completionCallback: { vc in
                    vc.navigationController?.popViewControllerAnimated(true)
                }
            )
        }
    }
}


