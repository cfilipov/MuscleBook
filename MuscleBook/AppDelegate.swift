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
import Fabric
import Crashlytics
import HEXColor
import JSQNotificationObserverKit
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let dropboxAuthNotification = Notification<DropboxAuthResult, AnyObject>(name: "Dropbox.handleRedirectURL")
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window?.tintColor = UIColor(rgba: "#ff0000")
        UITableView.appearance().backgroundColor = UIColor(rgba: "#f7f7f7")
        Profiler.trace("Uptime").start()
        Profiler.trace("App Launch").start()
        Dropbox.setupWithAppKey("apsa8g46ubfs32k")
        Fabric.with([Crashlytics.self])
        DB.sharedInstance
        KingfisherManager.sharedManager.cache.maxCachePeriodInSecond = 31536000000
        Profiler.trace("App Launch").end()
        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .Success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
            case .Error(let error, let description):
                print("Error \(error): \(description)")
            }

            AppDelegate.dropboxAuthNotification.post(authResult)
        }

        return false
    }

    func applicationDidBecomeActive(application: UIApplication) {
        Profiler.trace("App Active")
    }

}
