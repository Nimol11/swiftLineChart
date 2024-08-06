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
       
        let yValue = self.sorted()

        var data:[Double] =  []
        for element in yValue {
            data.append(Double(element as? Int ?? 0 ))
        }
        let majorUnit = calculateMajorUnit(data: data )
        guard let maxValue = data.last  else { return [] }
        var index = 1
        var y = Int((majorUnit).rounded(.up) * Double(index))
        while y <= Int(maxValue + majorUnit) {
            verticalNumber.append(y)
            index += 1
            y = Int((majorUnit).rounded(.up) * Double(index))
        }      
        return verticalNumber
    }

    func calculateMajorUnit(data: [Double]) -> Double {
        // Ensure data array is not empty
        guard !data.isEmpty else {
            return 1
        }
        
        // Calculate data range
        let dataMin = data.min() ?? 0
        let dataMax = data.max() ?? 0
        let dataRange = dataMax - dataMin
       
        if dataMax == dataMin {
            return 1
        }
        let magnitude = pow(10, floor(log10(dataRange)))
        let factors = dataRange / magnitude
        
        let niceFactors: [Double] = [1, 2, 5]
        var niceFactor = niceFactors[0]
        for factor in niceFactors {
            if factor >= factor {
                niceFactor = factor
                break
            }
        }
        
        let interval = niceFactor * magnitude
    
        // Adjust number of ticks based on interval
        let numTicks = Int(round(dataRange / interval))
       
        if numTicks < 10 / 2 && numTicks >= 3 {         // 10: Target line
            return interval / 2
        } else if numTicks > 10 * 2 {
            return interval * 2
        } else if numTicks  < 3 {
            return interval / 5
        }
        else {
            return interval
        }
        
    }
}
