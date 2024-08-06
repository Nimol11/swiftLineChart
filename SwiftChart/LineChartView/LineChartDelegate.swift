//
//  LineChartDelegate.swift
//  SwiftAnimation
//
//  Created by Nimol on 22/7/24.
//

import Foundation

// MARK: Chart Delegate
@objc public protocol LineChartDelegate: AnyObject {
   @objc optional func lineChartDidStartRender(_ lineChart: LineChartView)
   @objc optional func lineChartDidFinishRender(_ lineChart: LineChartView)
   @objc optional func lineChartDidFailRender(_ lineChar: LineChartView)
    
 
}
