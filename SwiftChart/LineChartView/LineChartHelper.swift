//
//  LineChartHelper.swift
//  SwiftAnimation
//
//  Created by Nimol on 22/7/24.
//

import UIKit
import QuartzCore

extension LineChartView {
    
    func render(_ dataSource: LineChartDataSource,
                _ dispatchQueue: DispatchQueue = .init(label: "process_queue"),
                _ completion: @escaping () -> Void) {
        
        // Create a render group
        let renderGroup = DispatchGroup()
        
        // Remove old layers
        removeLayers()
        
        // Calculate min and max
        calculateSizes(dataSource)
        
       
        
        // Check if we can draw chart
        guard dataSource.numberOfItems(in: self) > 0 else {
            if let lineChartDidFailRender = delegate?.lineChartDidFailRender {
                lineChartDidFailRender(self)
            }
            return
        }
        
        // Draw axis
        renderGroup.enter()
        drawAxis(dispatchQueue) { layer in
            DispatchQueue.main.async { [weak self] in
                self?.layer.insertSublayer(layer, at: 0)
                renderGroup.leave()
            }
        }
        
        // Draw vertical grid
        if showVerticalGrid {
            renderGroup.enter()
            drawVerticalGrid(dataSource, dispatchQueue) { layer in
                DispatchQueue.main.async { [weak self] in
                    self?.layer.insertSublayer(layer, at: 1)
                    renderGroup.leave()
                }
            }
        }
        
        // Draw horizontal grid
        if showHorizontalGrid {
            renderGroup.enter()
            drawHorizontalGrid(dataSource, dispatchQueue) { layer in
                DispatchQueue.main.async { [weak self] in
                    self?.layer.insertSublayer(layer, at: 1)
                    renderGroup.leave()
                }
            }
        }
        
        // Draw side labels
        if showSideLabels {
            renderGroup.enter()
            drawSideLabels(dataSource, dispatchQueue) { [weak self] textLayers in
                for textLayer in textLayers {
                    self?.layer.insertSublayer(textLayer, at: 0)
                }
                renderGroup.leave()
            }
        }
        
        // Draw bottom labels
        if showBottomLabels {
            renderGroup.enter()
            drawBottomLabels(dataSource, dispatchQueue) { [weak self] textLayers in
                for textLayer in textLayers {
                    self?.layer.insertSublayer(textLayer , at: 0)
                }
                renderGroup.leave()
            }
        }
        
        // Draw chart
        renderGroup.enter()
        drawChart(dataSource: dataSource,
                  canvas: CGRect(x: showSideLabels ?  sideSpace : bounds.origin.x, y: bounds.origin.y + headerSpace ,
                                 width: graphWidth, height: graphHeight ),
                  queue: dispatchQueue) { layer in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.layer.insertSublayer(layer, at: 1)

               
                renderGroup.leave()
            }
//
           
        }
        // Draw Vertical Line point view
        renderGroup.enter()
        drawVerticalLinePointView(x: sideSpace, y: 40) { [weak self ] lineLayer in
            DispatchQueue.main.async {
                self?.lineLayerPoint = lineLayer
                if let layer = self?.lineLayerPoint {
                    self?.layer.insertSublayer(layer,at: 2)
                    if self?.isHiddenLineBarValueOnRelease == true {
                        layer.isHidden = true
                    }
                }
                renderGroup.leave()
            }
        }
        renderGroup.enter()
        drawYValuePointRotation(x: sideSpace, y: 15) { [weak self]  layer in
            self?.yValueTextLayer = layer
            if let layer = self?.yValueTextLayer {
                self?.layer.insertSublayer(layer, at: 3)
                renderGroup.leave()
                if self?.isHiddenLineBarValueOnRelease == true {
                    layer.isHidden = true
                }
            }
        }
        renderGroup.enter()
        self.drawPointRotation(x: self.sideSpace - 5 ,y: 0) { [weak self] pointLayer in
            DispatchQueue.main.async {
                self?.pointRotationLayer = pointLayer
                if let pointRotationLayer = self?.pointRotationLayer {
                    self?.layer.insertSublayer(pointRotationLayer, above: self?.lineLayerPoint)
                   
                    renderGroup.leave()
                    if self?.isHiddenLineBarValueOnRelease == true {
                        pointRotationLayer.isHidden = true
                    }
                }
            }
        }
        renderGroup.enter()
        self.drawHeader { layer  in
            DispatchQueue.main.async { [weak self ] in
                guard let self = self else { return }
                self.layer.insertSublayer(layer, at: 0)
                
                renderGroup.leave()
            }
        }
        // Wait for everything to draw
        renderGroup.notify(queue: .main) { completion() }
        
    }
    
    
    //MARK: - calculateSizes
    fileprivate func calculateSizes(_ dataSource: LineChartDataSource) {
        graphWidth = frame.size.width - (showSideLabels ? sideSpace + 10 : 0)
        graphHeight = frame.size.height - (showBottomLabels ? bottomSpace : 0)
        minValue = CGFloat.greatestFiniteMagnitude
        maxValue = 0.0
        for index in 0..<dataSource.numberOfItems(in: self) {
            let yValue = dataSource.lineChart(self, yValueAt: index)
            if maxValue < yValue { maxValue = yValue }
            if minValue > yValue { minValue = yValue }
        }
        sanitizeValues()
    }
    
    fileprivate func sanitizeValues() {
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
    
    fileprivate func removeLayers() {
        self.layer.sublayers?.forEach({ layer in
            layer.removeFromSuperlayer()
        })
    }
  
    //MARK: - Draw Header view
    fileprivate func drawHeader(_ dispatchQueue: DispatchQueue = .init(label: "process_draw_header"),
                                _ completion: @escaping(CALayer) -> Void) {
        let tLayers = CALayer()
        let label = CenterTextLayer()
      
        label.position = CGPoint(x: 0 , y: 0)
        label.frame = CGRect(x: 0, y: 0, width: 40, height: 15)
        label.font = CGFont(UIFont.systemFont(ofSize: 13).fontName as NSString)
        label.fontSize = 13
        label.string = "V"
        label.foregroundColor = self.labelsColor.cgColor
        tLayers.addSublayer(label)
        
        self.headerText = CenterTextLayer()
        headerText?.position = CGPoint(x: 0 , y: 0)
        headerText?.frame = CGRect(x: graphWidth/2 - 100, y: 0, width: 200, height: 25)
        headerText?.font = headerTextFont
        headerText?.fontSize = headerTextFontSize
        headerText?.alignmentMode = .center
        headerText?.foregroundColor = self.headerTextColor.cgColor
        tLayers.addSublayer(headerText ?? CenterTextLayer())
        completion(tLayers)
        
    }
    
    //MARK: - drawVerticalGrid
    fileprivate func drawVerticalGrid(_ dataSource: LineChartDataSource,
                                      _ dispatchQueue: DispatchQueue = .init(label: "process_vertical_grid_queue"),
                                      _ completion: @escaping (CALayer) -> Void) {
        let numOfGrids = min(dataSource.numberOfVerticalLines(in: self),
                             dataSource.numberOfVerticalLines(in: self))
        let vSpace = graphWidth / CGFloat(numOfGrids)
        let bounds = bounds
        
        dispatchQueue.async { [weak self, bounds] in
            guard let self = self else { return }
            let tLayer = CALayer()
            let drawGroup = DispatchGroup()
            
            for index in 0..<numOfGrids {
                drawGroup.enter()
                let startFrom = vSpace * CGFloat(index) + (showSideLabels ? sideSpace : 0)

                if let dashPattern = dataSource.lineChart?(self , verticalDashPatternAt: index) {
                    self.line(from: CGPoint(x: startFrom, y: 0),
                              to: CGPoint(x: startFrom, y: self.graphHeight),
                              frame: bounds,
                              color: self.gridColor,
                              width: self.gridWidth,
                              dashPatern: dashPattern) { layer in
                        tLayer.addSublayer(layer)
                        drawGroup.leave()
                    }
                } else {
                    // Provide a default value if the data source method is not implemented
                    self.line(from: CGPoint(x: startFrom, y: 0),
                              to: CGPoint(x: startFrom, y: self.graphHeight),
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
    
    
    //MARK: - drawHorizontalGrid
    fileprivate func drawHorizontalGrid(_ dataSource: LineChartDataSource,
                                        _ dispatchQueue: DispatchQueue = .init(label: "process_horizontal_grid_queue"),
                                        _ completion: @escaping (CALayer) -> Void) {
        
        let numOfGrids = min(dataSource.numberOfHorizontalLines(in: self), dataSource.numberOfHorizontalLines(in: self))
        let hSpace = (graphHeight - headerSpace) / CGFloat(numOfGrids)
        let bounds = bounds
        
        dispatchQueue.async { [weak self, bounds] in
            guard let self = self else { return }
            let tLayer = CALayer()
            let drawGroup = DispatchGroup()
            
            for index in 1..<numOfGrids + 1 {
                drawGroup.enter()
                if let dashPattern = dataSource.lineChart?(self , horizontalDashPatternAt: index) {
                    self.line(from: CGPoint(x: 0 + (showSideLabels ? self.sideSpace : 0) , y: self.graphHeight - (hSpace * CGFloat(index)) ),
                              to: CGPoint(x: self.graphWidth + (showSideLabels ? self.sideSpace : 0), y: self.graphHeight - (hSpace * CGFloat(index))),
                              frame: bounds,
                              color: self.gridColor,
                              width: self.gridWidth,
                              dashPatern: dashPattern) { layer in
                        
                        tLayer.addSublayer(layer)
                        drawGroup.leave()
                    }
                
                } else {
                    self.line(from: CGPoint(x: 0 + (showSideLabels ? self.sideSpace : 0), y: self.graphHeight - (hSpace * CGFloat(index)) ),
                              to: CGPoint(x: self.graphWidth + (showSideLabels ? self.sideSpace : 0), y: self.graphHeight - (hSpace * CGFloat(index))),
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
    
    //MARK: - drawAxis
    fileprivate func drawAxis(_ dispatchQueue: DispatchQueue = .init(label: "process_axis_queue"),
                              _ completion: @escaping (CALayer) -> Void) {
        
        let bounds = self.bounds
        dispatchQueue.async { [weak self, bounds] in
            guard let self = self else { return }
            let tLayer = CALayer()
            let drawGroup = DispatchGroup()
            if showVerticalLine { // line for vertical
                drawGroup.enter()
                self.line(from: CGPoint(x: self.graphWidth + sideSpace, y: headerSpace),
                          to: CGPoint(x: self.graphWidth + sideSpace, y: self.graphHeight),
                          frame: bounds,
                          color: self.gridColor,
                          width: self.gridWidth,
                          dispatchQueue) { layer in
                    tLayer.addSublayer(layer)
                    drawGroup.leave()
                }
            }
            if showHorizontalLine { // line for horizontal
                drawGroup.enter()
                self.line(from: CGPoint(x: showSideLabels ? sideSpace : 0 , y: self.graphHeight ),
                          to: CGPoint(x: self.graphWidth + sideSpace, y: self.graphHeight  ),
                          frame: bounds,
                          color: self.gridColor,
                          width: self.gridWidth,
                          dispatchQueue) { layer in
                    tLayer.addSublayer(layer)
                    drawGroup.leave()
                }
            }
            drawGroup.notify(queue: dispatchQueue) {
                completion(tLayer)
            }
        }
    }
    

    //MARK: - Draw vertical line view
    
    func drawVerticalLinePointView(x: CGFloat, y: CGFloat, _ dispatchQueue: DispatchQueue = .init(label: "process_vertical_line_point_view"),
                                               _ completion: @escaping(CALayer) -> Void) {
        
        let drawGroup = DispatchGroup()
        let tLayer = CALayer()
         drawGroup.enter()
        self.line(from: CGPoint(x: x, y: y),
                  to: CGPoint(x: x , y: self.graphHeight ),
                   frame: CGRect(x: x, y: y, width: 1, height: self.graphHeight ),
                  color: self.barLineValueColor,
                  width: 1,
                  dashPatern: [7,5]) { layer in
            tLayer.addSublayer(layer)
            drawGroup.leave()
        }
    
        drawGroup.notify(queue: dispatchQueue) {
            completion(tLayer)
        }
    }
    
    fileprivate func drawPointRotation( x: CGFloat, y: CGFloat,_ dispatchQueue: DispatchQueue = .init(label: "process_point_rotation "),
                                       _ completion: @escaping(CALayer) -> Void) {
        let tLayer = CALayer()
        let circleLayer = CAShapeLayer();
        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: 10, height: 10)).cgPath;
        circleLayer.strokeColor = self.linePointBorderColor.cgColor
        circleLayer.fillColor = self.linePointFillColor.cgColor
        tLayer.addSublayer(circleLayer)
        completion(tLayer)
    }
    fileprivate func drawYValuePointRotation(x: CGFloat, y: CGFloat,_ dispatchQueue: DispatchQueue = .init(label: "process_y_value_point_rotation"),
                                             _ completion: @escaping(CATextLayer) -> Void) {
      
        let label = CenterTextLayer()
        label.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        label.position = CGPoint(x: sideSpace , y: y)
        label.frame = CGRect(x: x, y: y, width: 40, height: 25)
        label.font = CGFont(UIFont.systemFont(ofSize: 13).fontName as NSString)
        label.fontSize = 13
        label.foregroundColor = self.labelsColor.cgColor
       
        completion(label)
    }
    
    
    
    //MARK: - drawSideLabels
    fileprivate func drawSideLabels(_ dataSource: LineChartDataSource,
                                    _ dispatchQueue: DispatchQueue = .init(label: "process_side_labels_queue"),
                                    _ completion: @escaping ([CATextLayer]) -> Void) {
        
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            var tLayers = [CenterTextLayer]()
            var values: [Int] = []
            let maxNumberOfLabels = dataSource.numberOfSideLabels(in: self)
            for index in stride(from: self.minValue,
                                to: self.maxValue,
                                by: (self.maxValue - self.minValue) / CGFloat(maxNumberOfLabels.count)) {
                values.append(Int(index))
            }
            values.append(Int(self.maxValue))
            values = dataSource.numberOfSideLabels(in: self)
            values = values.sorted()
            values.insert(0, at: 0)
            let numOfGrids = min(dataSource.numberOfHorizontalLines(in: self ), dataSource.numberOfHorizontalLines(in: self))
            let hSpace = (graphHeight - headerSpace) / CGFloat(numOfGrids)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                var drawIndex = 0
                for index in 0..<values.count {
                    let label = CenterTextLayer()
                    label.frame = .init(x: 0, y: 0, width: self.sideSpace, height: 15)
                    var xPos = self.sideSpace / 2
                    var yPos = self.graphHeight - (CGFloat(drawIndex) * hSpace)
                    if xPos.isNaN { xPos = 0 }
                    if yPos.isNaN {
                        
                        if dataSource.lineChart(self, yValueAt: drawIndex) != 0 {
                            yPos = -10
                        } else {
                            yPos = self.graphHeight - 10
                        }
                    }
                    label.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    label.position = CGPoint(x: xPos , y: self.graphHeight - (hSpace * CGFloat(index) + 2) )
                    label.string = "\(values[index])"
                    label.font = CGFont(UIFont.systemFont(ofSize: 8).fontName as NSString)
                    label.fontSize = 10
                    
                    label.foregroundColor = self.labelsColor.cgColor
                    tLayers.append(label)
                    drawIndex += 1
                }
                
                completion(tLayers)
            }
        }
    }
    
    //MARK: - drawBottomLabels
    fileprivate func drawBottomLabels(_ dataSource: LineChartDataSource,
                                      _ dispatchQueue: DispatchQueue = .init(label: "process_bottom_labels_queue"),
                                      _ completion: @escaping ([CATextLayer]) -> Void) {
        
        
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            var tLayers = [CenterTextLayer]()
            var values: [String] = []
            
            //MARK: - Change
            for index in 0 ..< dataSource.numberOfVerticalLines(in: self){
                if let lineChart = dataSource.lineChart?(self , viewXValueAt: index) {
                    values.append(lineChart)
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let vSpace = self.graphWidth / CGFloat(values.count)
                for index in 0..<values.count {
                    let label = CenterTextLayer()
                    var xPos = vSpace * CGFloat(index)
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
                    label.frame = .init(origin: CGPoint(x: xPos + sideSpace, y: yPos ),
                                        size: CGSize(width: vSpace, height: self.bottomSpace))
                    tLayers.append(label)
                }
                completion(tLayers)
            }
        }
    }
    
    //MARK: - Draw chart
    fileprivate func drawChart(dataSource: LineChartDataSource,
                               canvas rect: CGRect = .zero,
                               queue dispatchQueue: DispatchQueue = .init(label: "process_chart_queue"),
                               _ completion: @escaping (CALayer) -> Void) {
        
        
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Create a temporary buffer layer
            let tLayer = CALayer()
            let lineBezierPath = UIBezierPath()
            var pointsData: [CGPoint] = []
            
            let gradientBezierPath = UIBezierPath()
            lineBezierPath.fill()
            lineBezierPath.stroke()
            let config = BezierConfiguration()
            
            self.pointsData = []
            // Draw path
            self.vSpace = 0.0
            self.vSpace =  rect.width / (CGFloat(dataSource.numberOfItems(in: self))-1)
            
            guard let maxSizeNumber = dataSource.numberOfSideLabels(in: self).last else {return}
            let step: Double = Double(maxSizeNumber / dataSource.numberOfHorizontalLines(in: self))
            var startPoint: CGFloat = 0
            let numOfGrids = min(dataSource.numberOfHorizontalLines(in: self), dataSource.numberOfHorizontalLines(in: self))
            let hSpace = (graphHeight - headerSpace) / CGFloat(numOfGrids)
            
            for index in 0..<dataSource.numberOfItems(in: self)  {
                let xPos = rect.origin.x + vSpace * CGFloat(index)
                
                startPoint =  rect.maxY - (dataSource.lineChart(self , yValueAt: index) *  hSpace / step  + headerSpace)
                
                pointsData.append(CGPoint(x: xPos , y: startPoint ))
                
            } // end
            pointsData.append(CGPoint(x: rect.origin.x + vSpace * CGFloat(dataSource.numberOfItems(in: self)),
                                      y: (pointsData.last?.y ?? rect.size.height)))
            self.pointsData = pointsData
           
            gradientBezierPath.move(to: CGPoint(x: rect.origin.x, y: self.graphHeight))
            let controlPoints = config.configureControlPoints(data: pointsData)
            for index in 0 ..< pointsData.count - 1 {
                let point = pointsData[index]
                if showPointYValue {
                    // draw point value on line chart
                    if index < pointsData.count - 1 {
                        let circleLayer = CAShapeLayer();
                        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: point.x - 4 , y:  point.y - 4  , width: 8, height: 8)).cgPath;
                        circleLayer.strokeColor = self.linePointBorderColor.cgColor
                        circleLayer.fillColor = self.linePointFillColor.cgColor
                        tLayer.insertSublayer(circleLayer, at: 2)
                        tLayer.addSublayer(circleLayer)
                    }
                }
                
                switch index {
                case 0 where self.chartType == .curved:
                    lineBezierPath.move(to: point)
                    gradientBezierPath.addCurve(to: point, controlPoint1: point, controlPoint2: point)
                case 0 where self.chartType == .linear:
                    lineBezierPath.move(to: point)
                    gradientBezierPath.addLine(to: point)
                default:
                    let segment = controlPoints[index - 1]
                    switch self.chartType {
                        
                    case .linear:
                        lineBezierPath.addLine(to: point)
                        gradientBezierPath.addLine(to: point)
                    case .curved:
                        if point.y + 10 >= rect.maxY {
                            lineBezierPath.addLine(to: point)
                            gradientBezierPath.addLine(to: point)
                            
                        }else {
                            lineBezierPath.addCurve(to: point,
                                                    controlPoint1: segment.firstControlPoint,
                                                    controlPoint2: segment.secondControlPoint)
                            gradientBezierPath.addCurve(to: point,
                                                        controlPoint1: segment.firstControlPoint,
                                                        controlPoint2: segment.secondControlPoint)
                        }
                    }
                }
            }
            
            let finalPoint = CGPoint(x: rect.origin.x + vSpace * (CGFloat(pointsData.count)),
                                     y: self.graphHeight)
            gradientBezierPath.addCurve(to: finalPoint, controlPoint1: finalPoint, controlPoint2: finalPoint)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = lineBezierPath.cgPath
            shapeLayer.lineWidth = self.lineWidth
            shapeLayer.strokeColor = self.tintColor.cgColor
            shapeLayer.fillColor = .none
            shapeLayer.lineCap = .round
            tLayer.addSublayer(shapeLayer)
            
            // Fill gradient
            let fillGradient = CAGradientLayer()
            fillGradient.frame = CGRect(x: 0, y: 0, width: graphWidth + sideSpace, height: self.bounds.height)
          
            fillGradient.colors = [self.graphFillGradientColor[0].cgColor, self.graphFillGradientColor[1].cgColor]
            fillGradient.locations = [0.6,1 ]
            
            let mask = CAShapeLayer()
            mask.path = gradientBezierPath.cgPath
            mask.lineCap = .round
            tLayer.insertSublayer(fillGradient, at: 0)
            fillGradient.mask = mask
            
            // Line gradient
            let lineGradientLayer = CAGradientLayer()
            
            lineGradientLayer.colors =  [self.lineGraphColor.cgColor, self.lineGraphColor.cgColor]
            
            lineGradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            lineGradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            lineGradientLayer.frame = self.bounds
            lineGradientLayer.mask = shapeLayer
            tLayer.insertSublayer(lineGradientLayer, at: 1)

            completion(tLayer)
        }
    }
    
    
}
