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

struct InputOptions: OptionSetType {
    let rawValue: Int64

//    static let None = InputOptions(rawValue: 0)
    static let Reps = InputOptions(rawValue: 1 << 0)
    static let Weight  = InputOptions(rawValue: 1 << 1)
    static let BodyWeight  = InputOptions(rawValue: 1 << 2)
    static let Duration  = InputOptions(rawValue: 1 << 3)
    static let AssistanceWeight  = InputOptions(rawValue: 1 << 4)

    static let AllOptions: InputOptions = [.Reps, .Weight, .BodyWeight, .Duration, .AssistanceWeight]
    static let DefaultOptions: InputOptions = [.Reps, .Weight, .Duration]
}
