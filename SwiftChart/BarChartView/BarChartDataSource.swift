//
//  BarChartDataSource.swift
//  SwiftChart
//
//  Created by Nimol on 30/7/24.
//

import Foundation
@objc public protocol BarChartDataSource: AnyObject {
    func numberOfItem(in barChart: BarChartView) -> Int
    func barChart( _ barChart: BarChartView, xValueAt index: Int) -> CGFloat
    func barChart(_ barChart: BarChartView, yValueAt index: Int) -> CGFloat
//    func numberOfHorizontal(in barChart: BarChartView, horizontalViewAt index: Int) -> Int
//    func numberOfHorizontalLines(in barChart: BarChartView) -> Int
    func numberOfVerticalLines(in barChart: BarChartView) -> Int
    func numberOfVertical(in barChart: BarChartView, verticalViewAt index: Int) -> String
    
    @objc optional func barChart(_ barChart: BarChartView, verticalDashPatternAt index: Int) -> [NSNumber]
    @objc optional func barChart(_ barChart: BarChartView, horizontalDashPatternAt index: Int) -> [NSNumber]
}
