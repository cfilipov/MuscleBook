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

class CreditsViewController : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Credits"

        let info = NSBundle.mainBundle().infoDictionary!

        form

        +++ Section()

        <<< LabelRow() {
            $0.title = "Author"
            $0.value = "Cristian Filipov"
        }

        +++ Section("Tab Bar Icons")


        <<< LabelRow() {
            // noun_173848_cc
            $0.value = "Leonides Delgad"
            $0.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(named: "noun_173848_cc")
            }
        }

        <<< LabelRow() {
            // noun_7904_cc
            $0.value = "Dmitry Baranovskiy"
            $0.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(named: "noun_7904_cc")
            }
        }

        <<< LabelRow() {
            // noun_29606
            $0.value = "Vivian Ziereisen"
            $0.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(named: "noun_29606")
            }
        }

        <<< LabelRow() {
            // noun_356956_cc
            $0.value = "Ecem Afacan"
            $0.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(named: "noun_356956_cc")
            }
        }

        <<< LabelRow() {
            // noun_43008_cc
            $0.value = "Housin Aziz"
            $0.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(named: "noun_43008_cc")
            }
        }

        +++ Section("Libraries")

        <<< PushViewControllerRow() {
            $0.title = "SQLite"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://www.sqlite.org/")!) }
        }

        <<< PushViewControllerRow() {
            $0.title = "SQLite.swift"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://github.com/stephencelis/SQLite.swift")!) }
        }

        <<< PushViewControllerRow() {
            $0.title = "SQLiteMigrationManager"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://github.com/garriguv/SQLiteMigrationManager.swift")!) }
        }

        <<< PushViewControllerRow() {
            $0.title = "Eureka"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://github.com/xmartlabs/Eureka")!) }
        }

        <<< PushViewControllerRow() {
            $0.title = "JAMSVGImage"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://github.com/jmenter/JAMSVGImage")!) }
        }

        <<< PushViewControllerRow() {
            $0.title = "EFCalendarGraph"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://github.com/eliotfowler/EFCalendarGraph")!) }
        }

        <<< PushViewControllerRow() {
            $0.title = "HEXColor"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://github.com/yeahdongcn/UIColor-Hex-Swift")!) }
        }

        <<< PushViewControllerRow() {
            $0.title = "CVCalendar"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://github.com/Mozharovsky/CVCalendar")!) }
        }

        <<< PushViewControllerRow() {
            $0.title = "CHCSVParser"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://github.com/davedelong/CHCSVParser")!) }
        }

        <<< PushViewControllerRow() {
            $0.title = "YACYAML"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://github.com/th-in-gs/YACYAML")!) }
        }

        <<< PushViewControllerRow() {
            $0.title = "JSQNotificationObserverKit"
            $0.controller = { SFSafariViewController(URL: NSURL(string: "https://github.com/jessesquires/JSQNotificationObserverKit")!) }
        }
        
    }
    
}
