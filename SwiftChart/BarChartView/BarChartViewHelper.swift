//
//  BarChartViewHelper.swift
//  SwiftChart
//
//  Created by Nimol on 30/7/24.
//

import UIKit
extension BarChartView {
    
    /*
       This function is render view to draw Bar Chart
       It Group of task function to draw chart
     */
    public func render(_ dataSource: BarChartDataSource,
                       _ dispatchQueue: DispatchQueue = .init(label: "process_queue"),
                       _ completion: @escaping() -> Void)  {
        let renderGroup = DispatchGroup()
        
        // Before we start process to draw chart we need to remove all old layers in view
        removeAllLayers()
        // this step we calculate width and height for graph
        calculatesSizes(dataSource)
        
        // delegate action if process of draw chart did fail process
        guard dataSource.numberOfItem(in: self ) > 0 else {
            if let barChartDidFailRender = delegate?.barChartDidFailRender {
                barChartDidFailRender(self)
            }
            return
        }
        
        // Start draw Header for graph
        renderGroup.enter()
        self.drawHeader { layer in
            DispatchQueue.main.async {
                self.headerText = layer
                if let layer = self.headerText {
                    self.layer.insertSublayer(layer, at: 0)
                    renderGroup.leave()
                }
            }
        }
        // Draw Axis of graph
        renderGroup.enter()
        self.drawAxis { layer in
            DispatchQueue.main.async {
                self.layer.insertSublayer(layer, at: 0)
                renderGroup.leave()
            }
        }
        // Draw Horizontal grid graph
        if showHorizontalGrid {
            renderGroup.enter()
            self.drawHorizontalGrid(dataSource, dispatchQueue) { layer  in
                DispatchQueue.main.async {
                    self.layer.insertSublayer(layer, at: 0)
                    renderGroup.leave()
                }
            }
        }
        // Draw Vertical grid graph
        if showVerticalGrid {
            renderGroup.enter()
            self.drawVerticalGrid(dataSource, dispatchQueue) { layer  in
                DispatchQueue.main.async {
                    self.layer.insertSublayer(layer, at: 0)
                    renderGroup.leave()
                }
            }
        }
        // show value of axisY of graph
        if showSideLabels {
            renderGroup.enter()
            self.drawHorizontalValue(dataSource, dispatchQueue) { layer in
                DispatchQueue.main.async {
                    self.layer.insertSublayer(layer, at: 0)
                    renderGroup.leave()
                }
            }
        }
       // draw bottom view
        if showBottomLabels {
            renderGroup.enter()
            self.drawVerticalValue(dataSource, dispatchQueue) { layer in
                DispatchQueue.main.async {
                    self.layer.insertSublayer(layer, at: 0)
                    renderGroup.leave()
                }
            }
        }
        // Draw bar Chart
        renderGroup.enter()
        self.drawBarChart(dataSource: dataSource, 
                          canvas: CGRect(x: showSideLabels ? sideSpace : 0, y: bounds.origin.y + headerSpace, width: graphWidth, height: graphHeight),
                          queue: dispatchQueue) { layer  in
            DispatchQueue.main.async { [self] in
                self.layer.insertSublayer(layer, at: 2)
                renderGroup.leave()
            }
        }
        // Draw Bottom show detail of graph value
        renderGroup.enter()
        self.drawBottomDetail { layer in
            DispatchQueue.main.async {
                self.showDetailLayer = layer
                if let layer = self.showDetailLayer {
                    self.layer.insertSublayer(layer, at: 0)
                    layer.isHidden = true
                    renderGroup.leave()
                }
            }
        }
      
      // Draw Bar vertical line
        renderGroup.enter()
        self.drawBarVerticalPoint { layer in
            self.barVerticalPoint = layer
            DispatchQueue.main.async {
                if let layer = self.barVerticalPoint {
                    self.layer.insertSublayer(layer, at: 3)
                    self.barVerticalPoint?.isHidden = true
                    renderGroup.leave()
                }
            }
        }
        // sent notification that process is complete
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
        graphWidth = frame.size.width - ( showSideLabels ? sideSpace + 10 : 0) - padding
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
    
    //MARK: - Draw header
    fileprivate func drawHeader(_ dispatchQueue: DispatchQueue = .init(label: "process_header_queue"),
                                _ completion: @escaping(CenterTextLayer) -> Void) {
        
        let header = CenterTextLayer()
        header.frame = CGRect(x: 0, y: 0, width: 40, height: 15)
        header.font = CGFont(UIFont.systemFont(ofSize: 13).fontName as NSString)
        header.fontSize = 13
        header.string = self.setHeaderText
        header.foregroundColor = self.labelsColor.cgColor
        
        completion(header)
    }
    
    //MARK: - Draw Axis
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
                line(from: CGPoint(x: self.graphWidth + (showSideLabels ? sideSpace : 0) + padding/2 , y: self.headerSpace) ,
                     to: CGPoint(x: self.graphWidth + (showSideLabels ? sideSpace : 0) + padding/2, y: self.graphHeight),
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
                line(from: CGPoint(x: (showSideLabels ? sideSpace : 0) + padding/2, y: self.graphHeight),
                     to: CGPoint(x: self.graphWidth + (showSideLabels ? sideSpace : 0) + padding/2 , y: self.graphHeight),
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
                    self.line(from: CGPoint(x: 0 + (showSideLabels ? self.sideSpace : 0) + padding/2, y: self.graphHeight - (hSpace * CGFloat(index))),
                              to: CGPoint(x: self.graphWidth + (showSideLabels ? sideSpace : 0 ) + padding/2, y: self.graphHeight - (hSpace * CGFloat(index))),
                              frame: bounds,
                              color: self.gridColor,
                              width: self.gridWidth,
                              dashPatern: dashPattern) { layer in
                        tLayer.addSublayer(layer)
                        drawGroup.leave()
                    }
                } else {
                    self.line(from: CGPoint(x: 0 + (showSideLabels ? self.sideSpace : 0) + padding/2, y: self.graphHeight - (hSpace * CGFloat(index))),
                              to: CGPoint(x: self.graphWidth + (showSideLabels ? sideSpace : 0 ) + padding/2, y: self.graphHeight - (hSpace * CGFloat(index))),
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
    
    //MARK: - Draw vertical Grid
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
                let startFrom = vSpace * CGFloat(index) + (showSideLabels ? sideSpace : 0) + padding/2
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
    
    //MARK: - Draw label display Horizontal value
    fileprivate func drawHorizontalValue(_ dataSource: BarChartDataSource,
                                         _ dispatchQueue: DispatchQueue = .init(label: "process_horizontal_value_queue"),
                                         _ completion: @escaping(CALayer) -> Void) {
        dispatchQueue.async { [weak self ] in
            guard let self = self else { return }
            let tLayers = CALayer()
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
                    let xPos = self.sideSpace / 2
                    label.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    label.position = CGPoint(x: xPos, y:  self.graphHeight - (hSpace * CGFloat(index))  )
                    label.string = "\(yValue[index])"
                    label.font = CGFont(UIFont.systemFont(ofSize: 8).fontName as NSString)
                    label.fontSize = 10
                    label.foregroundColor = self.labelsColor.cgColor
                    tLayers.addSublayer(label)
                }
                completion(tLayers)
            }
        }
    }
    
    //MARK: - Draw Label display Vertical value
    fileprivate func drawVerticalValue(_ dataSource: BarChartDataSource,
                                       _ dispatchQueue: DispatchQueue = .init(label: "process_vertical_value_queue"),
                                       _ completion: @escaping(CALayer) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            let tLayer = CALayer()
            var values: [String] = []
            
            for index in 0..<dataSource.numberOfVerticalLines(in: self) {
                 let barChart = dataSource.numberOfVertical(in: self , verticalViewAt: index)
                 values.append(barChart)
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let vSpace = (self.graphWidth) / CGFloat(values.count)
                for index in 0..<values.count {
                    let label = CenterTextLayer()
                    var xPos = vSpace * CGFloat(index) + (showSideLabels ? sideSpace : 0 ) + padding/2
                    var yPos = self.graphHeight
                    if xPos.isNaN { xPos = 0 }
                    if yPos.isNaN { yPos = 0 }
                    label.string = values[index]
                    label.anchorPoint = CGPoint(x: 1, y: 1)
                    let font = UIFont.systemFont(ofSize: 8.0)
                    let fontName = font.fontName as NSString
                    label.font = CGFont(fontName)
                    label.fontSize = 10
                    label.foregroundColor = self.labelsColor.cgColor
                    label.frame = .init(origin: CGPoint(x: xPos  , y: yPos ),
                                        size: CGSize(width: vSpace, height: self.bottomSpace))
                    tLayer.addSublayer(label)
                }
                completion(tLayer)
            }
        }
    }
    
    //MARK: - Draw Bar Chart
    fileprivate func drawBarChart(dataSource: BarChartDataSource,
                                  canvas rect: CGRect = .zero,
                                  queue dispatchQueue: DispatchQueue = .init(label: "process_bar_chart_queue"),
                                  _ completion: @escaping(CALayer) ->Void) {
        dispatchQueue.async { [weak self ] in
            guard let self = self else { return }
            var numberOfHorizontalValue: [Int] = []
            for index in 0..<dataSource.numberOfItem(in: self) {
                numberOfHorizontalValue.append(Int(dataSource.barChart(self , yValueAt: index)))
            }
            let yValue = numberOfHorizontalValue.calculateHorizontalLine()
            guard let maxValue = yValue.last else { return }
            let step = maxValue / yValue.count
            let numberOfGrids = min(yValue.count, yValue.count)
            let hSpace = (graphHeight - headerSpace) / CGFloat(numberOfGrids)
            let tLayer = CALayer()
            let numberOfItem = dataSource.numberOfItem(in: self)
            let barWidth = self.graphWidth / CGFloat(numberOfItem)
            self.vSpace = barWidth
            axisXPoint = []
            for index in 0..<numberOfItem {
                let xPos = rect.origin.x + (barWidth * CGFloat(index) ) + padding/2
                let yPos =  (dataSource.barChart(self , yValueAt: index) * hSpace / CGFloat(step))
                let shapeLayer = CAShapeLayer()
                let rect = CGRect(x: xPos + 1 , y: self.graphHeight, width: barWidth - 2, height: -yPos)
                shapeLayer.backgroundColor = self.barChartColor.cgColor
                shapeLayer.strokeColor = UIColor.red.cgColor
                shapeLayer.frame = rect
                axisXPoint.append(xPos)
                tLayer.addSublayer(shapeLayer)
            }
            completion(tLayer)
        }
    }
    fileprivate func drawBottomDetail(_ dispatchQueue: DispatchQueue = .init(label: "process_bottom_detail_queue"),
                                      _ completion: @escaping(CALayer) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let self = self  else { return }
            let tLayer = CALayer()
            bottomShowDetail = CAShapeLayer()
            bottomShowDetail?.backgroundColor = self.bottomShowDetailColor.cgColor
            bottomShowDetail?.frame = CGRect(x:  padding/2, y: self.graphHeight + (showBottomLabels ? bottomSpace: 0) + (10), width: self.frame.width  - padding, height: self.showValueDetailSpace - 10 ) // 10: Triangle Height
            bottomShowDetail?.cornerRadius = 8
            tLayer.addSublayer(self.bottomShowDetail ?? CAShapeLayer())
            
            labelDate = CenterTextLayer()
            labelDate?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            labelDate?.frame = .init(x: showSideLabels ? sideSpace + 10 : 10, y: self.graphHeight + (showBottomLabels ? bottomSpace: 0) + 12 , width: 100 , height: 30)
            labelDate?.string = "Thu"
            labelDate?.font = CGFont(UIFont.systemFont(ofSize: 8).fontName as NSString)
            labelDate?.fontSize = self.showDetailFontSize
            labelDate?.alignmentMode = .left
            labelDate?.foregroundColor = self.showDetailForegroundColor.cgColor
            tLayer.addSublayer(labelDate ?? CenterTextLayer())
            
            labelValue = CenterTextLayer()
            labelValue?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            labelValue?.frame = .init(x: self.graphWidth - 150, y: self.graphHeight + (showBottomLabels ? bottomSpace: 0) + 12 , width: 150 , height: 30)
            labelValue?.alignmentMode = .right
            labelValue?.string = "1.32kWh"
            labelValue?.font = CGFont(UIFont.systemFont(ofSize: 8).fontName as NSString)
            labelValue?.fontSize = self.showDetailFontSize
           
            labelValue?.foregroundColor = self.showDetailForegroundColor.cgColor
            tLayer.addSublayer(labelValue ?? CenterTextLayer())
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: (showSideLabels ? sideSpace : 0) + padding/2, y: self.graphHeight + (showBottomLabels ? bottomSpace : 0) + 10 ))
            path.addLine(to: CGPoint(x: (showSideLabels ? sideSpace : 0 ) + 6 + padding/2, y: self.graphHeight + (showBottomLabels ? bottomSpace : 0)))
            path.addLine(to: CGPoint(x: (showSideLabels ? sideSpace : 0) + 12 + padding/2 , y: self.graphHeight + (showBottomLabels ? bottomSpace : 0) + 10))
             triangle = CAShapeLayer()
            triangle?.path = path.cgPath
            triangle?.fillColor = self.bottomShowDetailColor.cgColor
            tLayer.addSublayer(triangle ?? CAShapeLayer())
            completion(tLayer)
        }
        
    }
    fileprivate func drawBarVerticalPoint(_ dispatchQueue: DispatchQueue = .init(label: "process_bar_vertical_queue"),
                                          _ completion: @escaping(CALayer) -> Void) {
        
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            let startFrom = (showSideLabels ? sideSpace : 0) + padding/2
            let tLayer = CALayer()
            self.line(from: CGPoint(x: startFrom, y: headerSpace),
                      to: CGPoint(x: startFrom, y: self.graphHeight + (showBottomLabels ? bottomSpace : 0)),
                      frame: CGRect(x: 0, y: 0, width: self.barVerticalPointWidth, height: self.graphHeight + (showBottomLabels ? bottomSpace : 0)),
                      color: self.barVerticalPointColor,
                      width: self.barVerticalPointWidth,
                      dashPatern: [7,5]) { layer in
                tLayer.addSublayer(layer)
            }
            completion(tLayer)
        }
    }
}
