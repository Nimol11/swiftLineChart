//
//  LineChartData.swift
//  SwiftAnimation
//
//  Created by Nimol on 22/7/24.
//

import Foundation
// MARK: Chart data
public protocol LineChartData {
    associatedtype FloatingPoint
    var xValue: FloatingPoint { get }
    var yValue: FloatingPoint { get }
}
