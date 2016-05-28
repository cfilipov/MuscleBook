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

extension SQLite.Connection {
    func prepare<T: SQLAdaptable>(query: QueryType) throws -> AnySequence<T> {
        let rows = try prepare(query)
        return AnySequence { Void -> AnyGenerator<T> in
            let generator = rows.generate()
            return AnyGenerator {
                guard let row = generator.next() else { return nil }
                return T(row: row)
            }
        }
    }

    func pluck<T: SQLAdaptable>(query: QueryType) -> T? {
        guard let row = pluck(query) else { return nil }
        return T(row: row)
    }
}

extension SQLite.QueryType {
    func insert<T: SQLAdaptable>(model: T) -> SQLite.Insert {
        return insert(model.setters)
    }

    func insert<T: SQLAdaptable>(or onConflict: SQLite.OnConflict, _ model: T) -> SQLite.Insert {
        return insert(or: .Replace, model.setters)
    }
}

extension ExpressionType where UnderlyingType : Value {
    func asName(name: String) -> Expression<UnderlyingType> {
        return Expression("\(template) AS \(name)", bindings)
    }
}

extension ExpressionType where UnderlyingType : _OptionalType, UnderlyingType.WrappedType : Value {
    func asName(name: String) -> Expression<UnderlyingType> {
        return Expression("\(template) AS \"\(name)\"", bindings)
    }
}

extension Expression where Datatype: NSDate {
    var day: Expression<NSDate> {
        return Expression<NSDate>("date(\(template))", bindings)
    }

    var localDay: Expression<NSDate> {
        return Expression<NSDate>("date(\(template), 'localtime')", bindings)
    }
}

extension NSDate {
    /*
     TODO: Parse more strictly
     Use the implementation of unixDate() from this gist: https://gist.github.com/AnuragMishra/6482177 to parse the specific format stored in the DB and fail if the date doesn't meet the format. Do the same for parsing and outputting the date string. This has several advantages:

     1. It's faster to focus on a single format and date parsing is by far one of the most expensive parts of the process
     2. There really should only be one format saved in the DB, nothing else should have gotten in there. During CSV import we can be lineient on the format, but not when it comes to reading writing the frield from the DB.
     */
    class func fromDatatypeValue(stringValue: String) -> NSDate {
        // Faster date parsing than NSDateFormatter
        let date = NSDate.parseISO8601Date(stringValue)
        return date
    }
    var datatypeValue: String {
        return self.YACYAMLScalarString()
    }
}

extension NSDate {
    var day: Expression<NSDate> {
        return Expression<NSDate>("date(?)", [self.datatypeValue])
    }

    var localDay: Expression<NSDate> {
        return Expression<NSDate>("date(?, 'localtime')", [self.datatypeValue])
    }
}

struct ArrayBox<T: SQLite.Value where T.Datatype == String, T.ValueType == T> {
    let array: [T]
}

extension ArrayBox: SQLite.Value {
    internal static var declaredDatatype: String {
        return String.declaredDatatype
    }

    static func fromDatatypeValue(stringValue: String) -> ArrayBox<T> {
        return ArrayBox(array: stringValue.componentsSeparatedByString(",").map{T.fromDatatypeValue($0)})
    }

    var datatypeValue: String {
        return array.map{$0.datatypeValue}.joinWithSeparator(",")
    }
}
