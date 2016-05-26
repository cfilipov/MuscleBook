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

extension Workset {
    static func importFromDropbox(file: String, completion: (SuccessOrFail -> Void)?) {
        let t = Profiler.trace(String(Workset), #function).start()
        Dropbox.authorizedClient!
            .files
            .download(path: file, destination: self.dropboxDestination(NSURL.cacheUUID()))
            .response { response, error in
                t.end()
                Profiler.trace("Dropbox import").start()
                defer {
                    Profiler.trace("Dropbox import").end()
                    completion?(.Success)
                }
                guard let (_, url) = response else { return }
                let sets = Workset.fromYAML(url.path!)
                try! DB.sharedInstance.save(sets)
        }
    }

    static func downloadFromDropbox(file: String, completion: (NSURL? -> Void)?) {
        let t = Profiler.trace(String(Workset), #function).start()
        Dropbox.authorizedClient!
            .files
            .download(path: file, destination: self.dropboxDestination(NSURL.cacheUUID()))
            .response { response, error in
                t.end()
                completion?(response?.1)
        }
    }

    static func dropboxDestination(destination: NSURL) -> (url: NSURL, response: NSHTTPURLResponse) -> NSURL {
        return { _, _ in return destination }
    }

//    static func uploadToDropbox(file: String, completion: (SuccessOrFail -> Void)?) {
//        guard let sets = try! all() else { completion?(.Fail); return }
//        Dropbox.authorizedClient!
//            .files
//            .upload(path: file, mode: .Overwrite, body: sets.toYAML)
//            .response { response, error in
//                completion?(SuccessOrFail(error: error))
//        }
//    }

}