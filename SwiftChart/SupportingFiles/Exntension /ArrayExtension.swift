//
//  ArrayExtension.swift
//  SwiftChart
//
//  Created by Nimol on 31/7/24.
//

import Foundation
extension Array where Element: Comparable {
    func calculateHorizontalLine() -> [Int] {
        var verticalNumber: [Int] = []
        var yValue: [Int] = []
        var count = 0

        let data = self.sorted()
        guard let maxValue = data.last as? Int else { return [] }

        if maxValue >= 10 {
            for element in data {
                if let value = element as? Int, value >= 10 {
                    yValue.append(value)
                }
            }
            yValue = yValue.sorted()
            count = Swift.min(yValue.count, 10)
            let spacing = yValue.last! / count
            for value in 1..<count + 3 {
                verticalNumber.append(spacing * value)
            }
        } else {  // for max value that is less than 10
            for element in data {
                if let value = element as? Int {
                    yValue.append(value)
                }
            }
            yValue = yValue.sorted()
            count = Swift.min(yValue.count, 10)
            if let yValueLast = yValue.last, yValueLast > 0 {
                let spacing = yValueLast / yValueLast
                for value in 1..<yValueLast + 2 {
                    verticalNumber.append(spacing * value)
                }
            } else {
                verticalNumber.append(1) // for all values that are equal to 0
            }
        }
        return verticalNumber
    }
}
