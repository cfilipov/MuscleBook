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
import SafariServices

class AboutViewController : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "About"

        let info = NSBundle.mainBundle().infoDictionary!

        form

        +++ Section()

        <<< LabelRow() {
            $0.title = "App Name"
            $0.value = info["CFBundleDisplayName"] as? String
        }

        <<< LabelRow() {
            $0.title = "Version"
            $0.value = info["CFBundleShortVersionString"] as? String
        }

        <<< LabelRow() {
            $0.title = "Build"
            $0.value = info["CFBundleVersion"] as? String
        }

        <<< PushViewControllerRow() {
            $0.title = "Credits"
            $0.controller = { CreditsViewController() }
        }

        +++ Section() {
            $0.footer = HeaderFooterView(title: "Copyright (C) 2016  Cristian Filipov")
        }

        <<< PushViewControllerRow() {
            // TODO: Load this w/o network access
            $0.title = "License"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "http://www.gnu.org/licenses/gpl-3.0-standalone.html")!) }
        }
    }
    
}

