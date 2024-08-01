//
//  LineChartDataSource.swift
//  SwiftAnimation
//
//  Created by Nimol on 22/7/24.
//

import Foundation
// MARK: Chart DataSource
 @objc public protocol LineChartDataSource: AnyObject {
     
     /*
        This function need for prepare point to drawn in graph
        The value is number of point to show
        Value can't negative number
      */
    func numberOfItems(in lineChart: LineChartView) -> Int

     /*
        This function use to draw  vertical grid line
       The value should be Integer cannot be String, Float of Double .etc
      */
    func numberOfVerticalLines(in lineChart: LineChartView) -> Int
     
     /*
         This function use to show grid bottom horizontal value
         it can be display String or Number
      */
    @objc optional func lineChart(_ lineChart: LineChartView, viewXValueAt index: Int) -> String
     
    func lineChart(_ lineChart: LineChartView, xValueAt index: Int) -> Double
     
     /*
         This function use to set point AxisY on graph
         The Should be Number
        @Rquired
      */
    func lineChart(_ lineChart: LineChartView, yValueAt index: Int) -> CGFloat
     
     /*
       This function use to set dash line on vertical grid line
      */
   @objc optional  func lineChart(_ lineChart: LineChartView, verticalDashPatternAt index: Int) -> [NSNumber]
     
     /*
       This function user to set dash line on horizontal grid line 
      */
   @objc optional func lineChart(_ lineChart: LineChartView, horizontalDashPatternAt index: Int) -> [NSNumber]
}
