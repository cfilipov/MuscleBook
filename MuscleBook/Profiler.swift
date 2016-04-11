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
import Darwin

struct Profiler {

    private(set) static var sharedinstance = Profiler()
    private(set) var traces: [String: Trace] = [:]

    static func trace(title: String, @noescape _ block: Void -> Void) {
        Profiler.sharedinstance.traces[title] = Trace(title: title, block: block)
    }

    static func trace(titleComponents: String...) -> Trace {
        let title = titleComponents.joinWithSeparator(".")
        let trace = Profiler.sharedinstance.traces[title] ?? Trace(title: title)
        Profiler.sharedinstance.traces[title] = trace
        return trace
    }

    struct Trace {
        let title: String
        let startTime: UInt64
        let endTime: UInt64?

        private init(title: String, @noescape block: Void -> Void) {
            self.title = title
            startTime = mach_absolute_time()
            block()
            endTime = mach_absolute_time()
        }

        private init(title: String, startTime: UInt64 = mach_absolute_time(), endTime: UInt64? = nil) {
            self.title = title
            self.startTime = startTime
            self.endTime = endTime
        }

        var duration: CFTimeInterval {
            let end = endTime ?? mach_absolute_time()
            return Double(end - startTime) / 1_000_000_000
        }

        func start() -> Trace {
            let trace = Trace(title: title)
            Profiler.sharedinstance.traces[title] = trace
            return trace
        }

        func end() -> Trace {
            let trace = Trace(title: title, startTime: startTime, endTime: mach_absolute_time())
            Profiler.sharedinstance.traces[title] = trace
            return trace
        }
    }

}

extension Profiler.Trace: Comparable, Equatable { }

func ==(lhs: Profiler.Trace, rhs: Profiler.Trace) -> Bool {
    return lhs.title == rhs.title && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
}

func <(lhs: Profiler.Trace, rhs: Profiler.Trace) -> Bool {
    return lhs.startTime < rhs.startTime
}

