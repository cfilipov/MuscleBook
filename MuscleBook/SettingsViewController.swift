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

class SettingsViewController : FormViewController {

    private let db = DB.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        
        form

        +++ Section()

        <<< PushViewControllerRow() {
            $0.title = "About"
            $0.controller = { AboutViewController() }
        }
        
        <<< PushViewControllerRow() {
            $0.title = "Debug Menu"
            $0.controller = { DebugMenuViewController() }
        }

        +++ Section()

        <<< ButtonRow() {
            $0.title = "Export Workouts Database"
            $0.cellUpdate { cell, _ in
                cell.textLabel?.textColor = UIColor.redColor()
            }
            $0.onCellSelection { _, _ in
                let vc = UIActivityViewController(
                    activityItems: [NSURL(fileURLWithPath: DB.path)],
                    applicationActivities: nil
                )
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }

        <<< ButtonRow() {
            $0.title = "Export Workouts to CSV"
            $0.cellUpdate { cell, _ in
                cell.textLabel?.textColor = UIColor.redColor()
            }
            $0.onCellSelection { _, _ in
                let url = NSURL.cacheUUID() // TODO: Don't use UUID, timestamp instead
                try! self.db.exportCSV(Workset.self, toURL: url)
                let vc = UIActivityViewController(
                    activityItems: [url],
                    applicationActivities: nil
                )
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
        
        <<< ButtonRow() {
            $0.title = "Export Exercises"
            $0.cellUpdate { cell, _ in
                cell.textLabel?.textColor = UIColor.redColor()
            }
            $0.onCellSelection { _, _ in
                let url = NSFileManager
                    .defaultManager()
                    .URLsForDirectory(
                        .CachesDirectory,
                        inDomains: .UserDomainMask
                    )[0]
                    .URLByAppendingPathComponent("exercises.yaml")
                try! self.db.exportYAML(Exercise.self, toURL: url)
                let vc = UIActivityViewController(
                    activityItems: [url],
                    applicationActivities: nil
                )
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }

}
