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

    var intensity: Double? {
        return [percentMaxWeight, percent1RM]
            .flatMap{$0}.maxElement()
    }

    var activation: Activation {
        guard input.warmup == false else { return .None }
        if input.failure { return .Max }
        guard let
            intensity = intensity,
            percentMaxWeight = percentMaxWeight
            else { return .None }
        let maxActivation = max(intensity, percentMaxWeight)
        return Activation(percent: maxActivation)
    }

    var calculations: Workset.Calculations {
        return Workset.Calculations(
            volume: volume,
            e1RM: e1RM,
            percentMaxVolume: percentMaxVolume,
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
