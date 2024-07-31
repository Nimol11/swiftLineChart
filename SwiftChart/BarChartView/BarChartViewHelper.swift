//
//  BarChartViewHelper.swift
//  SwiftChart
//
//  Created by Nimol on 30/7/24.
//

import UIKit
extension BarChartView {
    
    public func render(_ dataSource: BarChartDataSource,
                       _ dispatchQueue: DispatchQueue = .init(label: "process_queue"),
                       _ completion: @escaping() -> Void)  {
        let renderGroup = DispatchGroup()
        
        removeAllLayers()
        calculatesSizes(dataSource)
        renderGroup.enter()
        self.drawHeader { layer in
            DispatchQueue.main.async {
                self.layer.insertSublayer(layer, at: 0)
                renderGroup.leave()
            }
        }
        renderGroup.enter()
        self.drawAxis { layer in
            DispatchQueue.main.async {
                self.layer.insertSublayer(layer, at: 0)
                renderGroup.leave()
            }
        }
        renderGroup.enter()
        self.drawHorizontalGrid(dataSource, dispatchQueue) { layer  in
            DispatchQueue.main.async {
                self.layer.insertSublayer(layer, at: 0)
                renderGroup.leave()
            }
        }
        //
        renderGroup.enter()
        self.drawVerticalGrid(dataSource, dispatchQueue) { layer  in
            DispatchQueue.main.async {
                self.layer.insertSublayer(layer, at: 0)
                renderGroup.leave()
            }
        }
        
        if showSideLabels {
            renderGroup.enter()
            self.drawHorizontalValue(dataSource, dispatchQueue) { layer in
                DispatchQueue.main.async {
                    self.layer.insertSublayer(layer, at: 0)
                    renderGroup.leave()
                }
            }
        }

        
        renderGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func removeAllLayers() {
        self.layer.sublayers?.forEach { layer in
            layer.removeFromSuperlayer()
            
        }
    }
    private func calculatesSizes(_ dataSource: BarChartDataSource) {
        graphWidth = frame.size.width - ( showSideLabels ? sideSpace + 10 : 0)
        graphHeight = frame.size.height - (showBottomLabels ? bottomSpace : 0 ) - showValueDetailSpace
        minValue = CGFloat.greatestFiniteMagnitude
        maxValue = 0.0
        for index in 0..<dataSource.numberOfItem(in: self) {
            let yValue = dataSource.barChart(self, yValueAt: index)
            if maxValue < yValue { maxValue = yValue }
            if minValue > yValue { minValue = yValue }
        }
        sanitizeValues()
    }
    private func sanitizeValues() {
        if minValue == maxValue {
            let avg = (minValue + maxValue) / 2
            minValue = avg / 1.01
            maxValue = avg / 0.99
            
            if minValue == 0 && maxValue == 0 {
                minValue = 0
                maxValue = 1
            }
        }
    }
    
    fileprivate func drawHeader(_ dispatchQueue: DispatchQueue = .init(label: "process_header_queue"),
                                _ completion: @escaping(CALayer) -> Void) {
        let tLayer = CALayer()
        let header = CenterTextLayer()
        header.frame = CGRect(x: 0, y: 0, width: 40, height: 15)
        
        header.font = CGFont(UIFont.systemFont(ofSize: 13).fontName as NSString)
        header.fontSize = 13
        header.string = "kwh"
        header.foregroundColor = self.labelsColor.cgColor
        tLayer.addSublayer(header)
        completion(tLayer)
    }
    
    fileprivate func drawAxis(_ dispatchQueue: DispatchQueue = .init(label: "process_axis_queue"),
                              _ completion: @escaping(CALayer) -> Void) {
        let bounds = self.bounds
        dispatchQueue.async { [weak self, bounds] in
            guard let self = self else { return }
            let tLayers = CALayer()
            let drawGroup = DispatchGroup()
            
            // Draw AxisY
            if showVerticalLine {
                drawGroup.enter()
                line(from: CGPoint(x: self.graphWidth + sideSpace, y: self.headerSpace) ,
                     to: CGPoint(x: self.graphWidth + sideSpace, y: self.graphHeight),
                     frame: bounds,
                     color: self.gridColor,
                     width: self.gridWidth,
                     dispatchQueue) {  layer in
                    tLayers.addSublayer(layer)
                    drawGroup.leave()
                }
            }
            // Draw AxisX
            if showHorizontalLine {
                drawGroup.enter()
                line(from: CGPoint(x: showSideLabels ? sideSpace : 0 , y: self.graphHeight),
                     to: CGPoint(x: self.graphWidth + sideSpace, y: self.graphHeight),
                     frame: bounds,
                     color: self.gridColor,
                     width: self.gridWidth,
                     dispatchQueue) { layer in
                    tLayers.addSublayer(layer)
                    drawGroup.leave()
                }
            }
            drawGroup.notify(queue: dispatchQueue) {
                completion(tLayers)
            }
        }
    }
    
    //MARK: - Draw Horizontal lines grid
    fileprivate func drawHorizontalGrid(_ dataSource: BarChartDataSource,
                                        _ dispatchQueue: DispatchQueue = .init(label: "process_horizontal_grid_queue"),
                                        _ completion: @escaping(CALayer) ->Void) {
        
        
        var numberOfHorizontalValue: [Int] = []
        for index in 0..<dataSource.numberOfItem(in: self) {
            numberOfHorizontalValue.append(Int(dataSource.barChart(self , yValueAt: index)))
        }
        let yValue = numberOfHorizontalValue.calculateHorizontalLine()
        let numberOfGrids = min(yValue.count, yValue.count)
        
        let hSpace = (graphHeight - headerSpace) / CGFloat(numberOfGrids)
        let bounds = bounds
        
        dispatchQueue.async { [weak self, bounds] in
            guard let self = self else { return }
            let tLayer = CALayer()
            let drawGroup = DispatchGroup()
            
            for index in 1..<numberOfGrids + 1  {
                drawGroup.enter()
                if let dashPattern = dataSource.barChart?(self , horizontalDashPatternAt: index) {
                    self.line(from: CGPoint(x: 0 + (showSideLabels ? self.sideSpace : 0), y: self.graphHeight - (hSpace * CGFloat(index))),
                              to: CGPoint(x: self.graphWidth + (showSideLabels ? sideSpace : 0 ), y: self.graphHeight - (hSpace * CGFloat(index))),
                              frame: bounds,
                              color: self.gridColor,
                              width: self.gridWidth,
                              dashPatern: dashPattern) { layer in
                        tLayer.addSublayer(layer)
                        drawGroup.leave()
                        
                    }
                } else {
                    self.line(from: CGPoint(x: 0 + (showSideLabels ? self.sideSpace : 0), y: self.graphHeight - (hSpace * CGFloat(index))),
                              to: CGPoint(x: self.graphWidth + (showSideLabels ? sideSpace : 0 ), y: self.graphHeight - (hSpace * CGFloat(index))),
                              frame: bounds,
                              color: self.gridColor,
                              width: self.gridWidth,
                              dashPatern: []) { layer in
                        tLayer.addSublayer(layer)
                        drawGroup.leave()
                    }
                }
            }
            drawGroup.notify(queue: dispatchQueue) {
                completion(tLayer)
            }
        }
    }
    fileprivate func drawVerticalGrid(_ dataSource: BarChartDataSource,
                                      _ dispatchQueue: DispatchQueue = .init(label: "process_vertical_grid_queue"),
                                      _ completion: @escaping(CALayer) -> Void) {
        
        let numOfVertical = dataSource.numberOfVerticalLines(in: self)
        let numberOfGrids = min(numOfVertical, numOfVertical)
        let vSpace = graphWidth / CGFloat(numberOfGrids)
        let bounds = bounds
        
        dispatchQueue.async { [weak self, bounds] in
            guard let self = self else { return }
            let tLayer = CALayer()
            let drawGroup = DispatchGroup()
            
            for index in 0..<numberOfGrids {
                drawGroup.enter()
                let startFrom = vSpace * CGFloat(index) + (showSideLabels ? sideSpace : 0)
                if let dashPattern = dataSource.barChart?(self , verticalDashPatternAt: index) {
                    self.line(from: CGPoint(x: startFrom, y: headerSpace),
                              to: CGPoint(x: startFrom, y: self.graphHeight ),
                              frame: bounds,
                              color: self.gridColor,
                              width: self.gridWidth,
                              dashPatern: dashPattern) { layer in
                        tLayer.addSublayer(layer)
                        drawGroup.leave()
                    }
                } else {
                    self.line(from: CGPoint(x: startFrom, y: headerSpace),
                              to: CGPoint(x: startFrom, y: self.graphHeight ),
                              frame: bounds,
                              color: self.gridColor,
                              width: self.gridWidth,
                              dashPatern: []) { layer in
                        tLayer.addSublayer(layer)
                        drawGroup.leave()
                    }
                }
            }
            drawGroup.notify(queue: dispatchQueue) {
                completion(tLayer)
            }
        }
    }
    
    fileprivate func drawHorizontalValue(_ dataSource: BarChartDataSource,
                                         _ dispatchQueue: DispatchQueue = .init(label: "process_horizontal_value_queue"),
                                         _ completion: @escaping(CALayer) -> Void) {
        dispatchQueue.async { [weak self ] in
            
            guard let self = self else { return }
            
            var tLayers = CALayer()
            var numberOfHorizontalValue: [Int] = []
            for index in 0..<dataSource.numberOfItem(in: self) {
                numberOfHorizontalValue.append(Int(dataSource.barChart(self , yValueAt: index)))
            }
            var yValue = numberOfHorizontalValue.calculateHorizontalLine()
           
            
            let numberOfGrids = min(yValue.count, yValue.count)
            let hSpace = (graphHeight - headerSpace) / CGFloat(numberOfGrids)
            yValue.insert(0, at: 0)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                for index in 0..<yValue.count  {
                    let label = CenterTextLayer()
                    label.frame = .init(x: 0, y: 0, width: self.sideSpace, height: 15)
                    var xPos = self.sideSpace / 2
                    label.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    label.position = CGPoint(x: xPos, y:  self.graphHeight - (hSpace * CGFloat(index))  )
                    label.string = "\(yValue[index])"
                    label.font = CGFont(UIFont.systemFont(ofSize: 8).fontName as NSString)
                    label.fontSize = 10
                    label.backgroundColor = UIColor.red.cgColor
                    label.foregroundColor = self.labelsColor.cgColor
                    tLayers.addSublayer(label)                    
                }
                completion(tLayers)
            }
        }
    }
}
