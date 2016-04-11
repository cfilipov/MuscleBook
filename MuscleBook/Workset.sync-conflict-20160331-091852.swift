//
//  WorkoutSet.swift
//  BodyBook
//
//  Created by Cristian Filipov on 2/23/16.
//  Copyright © 2016 Cristian Filipov. All rights reserved.
//

import Foundation

struct Workset {
    let identifier: Int64?
    let exercise: String
    let date: NSDate
    let sets: Int
    let reps: Int
    let weight: Double?
    let duration: Double?
}

extension Workset: Equatable { }

func == (lhs: Workset, rhs: Workset) -> Bool {
    return lhs.date == rhs.date && lhs.sets == rhs.sets && lhs.reps == rhs.reps && lhs.exercise == rhs.exercise && lhs.weight == rhs.weight && lhs.duration == rhs.duration
}

extension Workset {
    var valueString: String {
        if let weight = weight {
            return "\(sets)x\(reps)@\(weight)"
        }
        preconditionFailure() // TODO: Hanlde other cases
    }
}