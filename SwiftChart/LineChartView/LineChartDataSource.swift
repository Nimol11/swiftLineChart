//
//  LineChartDataSource.swift
//  SwiftAnimation
//
//  Created by Nimol on 22/7/24.
//

import Foundation
// MARK: Chart DataSource
@objc public protocol LineChartDataSource: AnyObject {
    
    func numberOfItems(in lineChart: LineChartView) -> Int
    func numberOfVerticalLines(in lineChart: LineChartView) -> Int
    func lineChart(_ lineChart: LineChartView, xValueAt index: Int) -> Double
    func lineChart(_ lineChart: LineChartView, yValueAt index: Int) -> CGFloat
    @objc optional func lineChart(_ lineChart: LineChartView, viewXValueAt index: Int) -> String
    @objc optional  func lineChart(_ lineChart: LineChartView, verticalDashPatternAt index: Int) -> [NSNumber]
    @objc optional func lineChart(_ lineChart: LineChartView, horizontalDashPatternAt index: Int) -> [NSNumber]
}
