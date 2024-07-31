//
//  BarChartDelegate.swift
//  SwiftChart
//
//  Created by Nimol on 30/7/24.
//

import Foundation

@objc public protocol BarChartDelegate: AnyObject {
    @objc optional func barChartDidStartRender(_ barChart: BarChartView)
    @objc optional func barChartDidFinishRender(_ barChart: BarChartView)
    @objc optional func barChartDidFailRender(_ barChart: BarChartView)
}
