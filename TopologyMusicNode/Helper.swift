//
//  Helper.swift
//  TopologyMusicNode
//
//  Created by Pofat Tseng on 2018/3/14.
//  Copyright © 2018年 Pofat. All rights reserved.
//

// Helper free function
import Foundation
import SwiftGraph

/// Return a random integer in given range, not handle overflow
///
/// - Parameter range: range of random integer
/// - Returns: Result integer
func randomInt(from range: CountableClosedRange<Int>) -> Int {
    let offset = UInt32(range.lowerBound)
    let upperBound = UInt32(range.count)
    return Int(arc4random_uniform(upperBound) + offset)
}


/// Return a non-repeating random integer if given range is larger than given numbers of random integer
///
/// - Parameters:
///   - range: Range of random integer
///   - number: Number of desired integers array
/// - Returns: Result integer array
func randomInts(from range: CountableClosedRange<Int>, number: Int) -> [Int] {
    
    var result = [Int]()
    
    // if desired number is larger than range count, do not check repeated value
    let checkRepeatingValue = range.count >= number
    
    while result.count < number {
        let newInt = randomInt(from: range)
        if checkRepeatingValue, result.contains(newInt) { continue }
        
        result.append(newInt)
    }
    
    return result
}



/// Choose random number of arbitrary nodes in given array. Help us choose candiates
///
/// - Parameter array: Source array
/// - Returns: A set of chosen elements
func selectRandomNumberOfElements<T: Hashable>(from array: [T]) -> Set<T> {
    let numberOfElements = randomInt(from: 1...array.count)
    var result: Set<T> = []
    while result.count < numberOfElements {
        let newElement = array[randomInt(from: 0...array.count - 1)]
        
        if !result.contains(newElement) {
            result.insert(newElement)
        }
    }
    
    return result
}
