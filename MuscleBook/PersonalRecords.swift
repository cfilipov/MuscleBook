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

protocol StringSummarizable {
    var summary: String { get }
}

enum PersonalRecord {
    case MaxWeight(worksetID: Int64, maxWeight: Double, curWeight: Double?)
    case MaxReps(worksetID: Int64, maxReps: Int, curReps: Int?)
    case Max1RM(worksetID: Int64, maxWeight: Double, curWeight: Double?)
    case MaxE1RM(worksetID: Int64, maxWeight: Double, curWeight: Double?)
    case MaxXRM(worksetID: Int64, maxWeight: Double, curWeight: Double?)
    case MaxDuration(worksetID: Int64, maxDuration: Double, curDuration: Double?)
    case MaxVolume(worksetID: Int64, maxVolume: Double, curVolume: Double?)
    case MaxEReps(worksetID: Int64, maxReps: Int, curReps: Int?)
}

struct Records {
    var maxWeight: Workset?
    var maxReps: Workset?
    var max1RM: Workset?
    var maxE1RM: Workset?
    var maxXRM: Workset?
    var maxDuration: Workset?
    var maxVolume: Workset?
}

struct RelativeRecords {
    let input: Workset.Input
    let records: Records?

    var e1RM: Double? {
        guard let
            reps = input.reps,
            weight = input.weight
            else { return nil }
        return estimate1RM(reps: reps, weight: weight)
    }

    var volume: Double? {
        guard let
            reps = input.reps,
            weight = input.weight
            else { return nil }
        return Double(reps) * weight
    }

    var wilks: Double? {
        guard let weight = input.weight else { return nil }
        fatalError()
    }

    var percentMaxWeight: Double? {
        guard let
            maxRM = records?.maxWeight?.input.weight,
            weight = input.weight
            else { return nil }
        return weight / maxRM
    }

    var percent1RM: Double? {
        guard let
            max1RM = records?.max1RM?.input.weight,
            weight = input.weight
            else { return nil }
        return weight / max1RM
    }

    var percentE1RM: Double? {
        guard let
            maxE1RM = records?.maxE1RM?.input.weight,
            e1RM = e1RM
            else { return nil }
        return e1RM / maxE1RM
    }

    var percentXRM: Double? {
        guard let
            maxXRM = records?.maxXRM?.input.weight,
            weight = input.weight
            else { return nil }
        return weight / maxXRM
    }

    var percentMaxVolume: Double? {
        guard let
            maxVolume = records?.maxVolume?.calculations.volume,
            volume = volume
            else { return nil }
        return volume / maxVolume
    }

//    var percentMaxReps: Double? {
//        guard let
//            r = records?.maxReps?.input.reps,
//            reps = input.reps
//            else { return nil }
//        return reps / maxReps
//    }

    var intensity: Double? {
        if records == nil { return 1.0 }
        return [percentMaxWeight, percent1RM].flatMap{$0}.maxElement()
    }

    var activation: ActivationLevel {
        guard input.warmup == false else { return .Light }
        if input.failure { return .Max }
        guard let
            intensity = intensity,
            percentMaxVolume = percentMaxVolume
            else { return .Light }
        let maxActivation = max(intensity, percentMaxVolume)
        return ActivationLevel(percent: maxActivation)
    }

    var calculations: Workset.Calculations {
        return Workset.Calculations(
            volume: volume,
            e1RM: e1RM,
            percentMaxVolume: percentMaxVolume,
            percentMaxDuration: nil,
            intensity: intensity,
            activation: activation
        )
    }
}

class RelativeRecordsFormatter {
    let decimalFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    func format(value value: Double? = nil, percent: Double? = nil) -> String? {
        guard let
            value = value,
            valueStr = self.decimalFormatter.stringFromNumber(value)
            else {
                guard let percent = percent, percentStr = self.decimalFormatter.stringFromNumber(percent * 100) else {
                    return nil
                }
                return "\(percentStr)%"
        }
        if let percent = percent, percentStr = self.decimalFormatter.stringFromNumber(percent * 100) {
            return "\(valueStr) (\(percentStr)%)"
        } else {
            return "\(valueStr)"
        }
    }
}

extension PersonalRecord {
    var recordTitle: String {
        switch self {
        case .MaxWeight(_, _, _): return "Weight"
        case .MaxReps(_, _, _): return "Reps"
        case .Max1RM(_, _, _): return "1RM"
        case .MaxE1RM(_, _, _): return "e1RM"
        case .MaxXRM(_, _, _): return "xRM"
        case .MaxDuration(_, _, _): return "Duration"
        case .MaxVolume(_, _, _): return "Volume"
        case .MaxEReps(_, _, _): return "eReps"
        }
    }

    var worksetID: Int64 {
        switch self {
        case let .MaxWeight(worksetID, _, _): return worksetID
        case let .MaxReps(worksetID, _, _): return worksetID
        case let .Max1RM(worksetID, _, _): return worksetID
        case let .MaxE1RM(worksetID, _, _): return worksetID
        case let .MaxXRM(worksetID, _, _): return worksetID
        case let .MaxDuration(worksetID, _, _): return worksetID
        case let .MaxVolume(worksetID, _, _): return worksetID
        case let .MaxEReps(worksetID, _, _): return worksetID
        }
    }

    var percent: Double? {
        switch self {
        case let .MaxWeight(_, maxVal, curVal?): return curVal / maxVal
        case let .MaxReps(_, maxVal, curVal?): return Double(curVal) / Double(maxVal)
        case let .Max1RM(_, maxVal, curVal?): return curVal / maxVal
        case let .MaxE1RM(_, maxVal, curVal?): return curVal / maxVal
        case let .MaxXRM(_, maxVal, curVal?): return curVal / maxVal
        case let .MaxDuration(_, maxVal, curVal?): return curVal / maxVal
        case let .MaxVolume(_, maxVal, curVal?): return curVal / maxVal
        case let .MaxEReps(_, maxVal, curVal?): return Double(curVal) / Double(maxVal)
        default: return nil
        }
    }

    var recordString: String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        switch self {
        case let .MaxWeight(_, val, _): return formatter.stringFromOptionalNumber(val)!
        case let .MaxReps(_, val, _): return formatter.stringFromOptionalNumber(val)!
        case let .Max1RM(_, val, _): return formatter.stringFromOptionalNumber(val)!
        case let .MaxE1RM(_, val, _): return formatter.stringFromOptionalNumber(val)!
        case let .MaxXRM(_, val, _): return formatter.stringFromOptionalNumber(val)!
        case let .MaxDuration(_, val, _): return formatter.stringFromOptionalNumber(val)!
        case let .MaxVolume(_, val, _): return formatter.stringFromOptionalNumber(val)!
        case let .MaxEReps(_, val, _): return formatter.stringFromOptionalNumber(val)!
        }
    }
}

extension PersonalRecord: StringSummarizable {
    var summary: String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        guard let percent = percent else { return recordString }
        return "\(recordString) (\(formatter.stringFromNumber(percent * 100)!)%)"
    }
}
