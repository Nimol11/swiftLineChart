//
//  BarChartView.swift
//  SwiftChart
//
//  Created by Nimol on 30/7/24.
//

import UIKit

public class BarChartView: UIView {
    
    // class accessing
    public weak var delegate: BarChartDelegate?
    public weak var dataSource: BarChartDataSource?
    
    public var gridWidth: CGFloat = 0.3 // line grid width
    public var lineWidth: CGFloat = 3 // width line chart
    public var sideSpace: CGFloat = 44 //  space for show side value
    public var bottomSpace: CGFloat = 44 //  space for show name bottom
    public var showVerticalGrid: Bool = true  // True: show vertical grid line, False: Hide line
    public var showHorizontalGrid: Bool = true // True: show horizontal grid line, False: Hide line
    public var showBottomLabels: Bool = true
    public var showSideLabels: Bool = true
    public var gridColor: UIColor = .gray
    public var labelsColor: UIColor = .black
    public var showVerticalLine: Bool = true
    public var showHorizontalLine: Bool = true
    
    // bar chart view frame
    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 0.0
    var graphWidth: CGFloat = 0.0
    var graphHeight: CGFloat = 0.0
    
    var showValueDetailSpace: CGFloat  {
        get {
            return 35
        }
    }
    var headerSpace: CGFloat {
        get {
            return 25
        }
    }
  
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func reloadData(on dispatchQueue: DispatchQueue = .global(qos: .userInitiated)) {
        guard let dataSource = dataSource else { return }
        DispatchQueue.main.async {
            self.render(dataSource, dispatchQueue) {
                print("Render")
            }
        }
    }
}
