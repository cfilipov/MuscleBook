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
import SQLite

extension DB {

    func exportYAML(type: Exercise.Type, toURL url: NSURL) throws {
        var yaml = ""
        for exercise in try all(Exercise) {
            yaml += "---\n"
            var ex = exercise
            ex.muscles = Array(try! find(exerciseID: ex.exerciseID))
            yaml += YACYAMLKeyedArchiver.archivedStringWithRootObject(ex.encoded)!
        }
        yaml += "..."
        try yaml.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
    }

    func importYAML(type: Exercise.Type, fromURL url: NSURL) throws {
        let exercises = Exercise.decode(YACYAMLKeyedUnarchiver.unarchiveObjectWithFile(url.path, options: YACYAMLKeyedUnarchiverOptionPresentDocumentsAsArray) as? [AnyObject])
        for ex in exercises { try save(ex) }
    }

}
