//
//  LineChartDelegate.swift
//  SwiftAnimation
//
//  Created by Nimol on 22/7/24.
//

import Foundation

// MARK: Chart Delegate
@objc public protocol LineChartDelegate: AnyObject {
    
    /*
       This function work when graph is stating draw
       You can do some task in this action
     */
   @objc optional func lineChartDidStartRender(_ lineChart: LineChartView)
    
    /*
      This function work when graph is finished draw
     */
   @objc optional func lineChartDidFinishRender(_ lineChart: LineChartView)
    
    /*
     This function work when graph have some wrong while drawing
     */
   @objc optional func lineChartDidFailRender(_ lineChar: LineChartView)
    
 
}
