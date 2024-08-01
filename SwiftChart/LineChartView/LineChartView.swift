//
//  LineChart.swift
//  SwiftAnimation
//
//  Created by Nimol on 22/7/24.
//

import UIKit
import AVFoundation

// MARK: Chart type
public enum LineChartType: Int {
    case linear = 0
    case curved = 1
    public init() { self = .linear }
}

// MARK: - UIView
public class LineChartView: UIView {
    
    public var gridWidth: CGFloat = 0.3
    public var lineWidth: CGFloat = 3
    public var sideSpace: CGFloat = 25
    public var bottomSpace: CGFloat = 25
    public var showVerticalGrid: Bool = true
    public var showHorizontalGrid: Bool = true
    public var showBottomLabels: Bool = true
    public var showSideLabels: Bool = true
    public var gridColor: UIColor = .gray
    public var labelsColor: UIColor = .black
    public var showVerticalLine: Bool = true
    public var showHorizontalLine: Bool = true
    public var showPointYValue: Bool = true
    public var graphFillGradientColor: [UIColor] = [UIColor.white, UIColor.black]
    public var lineGraphColor: UIColor = .white
    public var isHiddenLineBarValueOnRelease: Bool = true
    
    var headerSpace: CGFloat {
         get {
             return 25 
         }
    }
    
    public var barLineValueColor: UIColor = .green
    public var chartType: LineChartType = .linear
    
    var headerText: CenterTextLayer?
    
    public weak var dataSource: LineChartDataSource?
    public weak var delegate: LineChartDelegate?
    
    public var headerTextColor: UIColor = UIColor.red  {
        didSet {
            self.headerText?.foregroundColor = headerTextColor.cgColor
        }
    }
    public var headerTextFont: UIFont = UIFont.systemFont(ofSize: 10) {
        didSet {
            self.headerText?.font = CGFont(headerTextFont.fontName as NSString)
        }
    }
    public var headerTextFontSize: CGFloat = 13 {
        didSet {
            self.headerText?.fontSize = headerTextFontSize
        }
    }
    
    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 0.0
    var graphWidth: CGFloat = 0.0
    var graphHeight: CGFloat = 0.0
    
    var pointsData: [CGPoint] = []
    var points: [CGFloat: CGFloat] = [:]

    var linePointFillColor: UIColor = .graph
    var linePointBorderColor: UIColor = .red
    
    var vSpace: CGFloat = 0.0
  
    var barVerticalPoint: CALayer?
    var pointRotationLayer: CALayer?
    var yValueTextLayer: CATextLayer?
    var currentState: Int = 0

    private var pressedLocation:CGFloat = 0
    
     override init(frame: CGRect) {
        super.init(frame: frame)
         self.setupTapGesture()
         self.notificationCenter()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupTapGesture()
        self.notificationCenter()
    }

    public func reloadData(on dispatchQueue: DispatchQueue = .global(qos: .userInitiated)) {
        
        guard let dataSource = dataSource else { return }

        if let lineChartDidStartRender = delegate?.lineChartDidStartRender {
            lineChartDidStartRender(self)
        }
        render(dataSource, dispatchQueue) { [weak self] in
            guard let self = self else { return }
            if let lineChartDidFinishRender = delegate?.lineChartDidFinishRender {
                lineChartDidFinishRender(self)
                
                if let pointRotationLayer = self.pointRotationLayer,
                   let yValueTextLayer = self.yValueTextLayer,
                   let lineLayerPoint = self.barVerticalPoint {
                    if self.isHiddenLineBarValueOnRelease == false{
                        let x = self.currentState == 0 ? 0 : (self.vSpace) * CGFloat(self.currentState)
                        let y = (self.pointsData[self.currentState == 0 ? 0 : self.currentState].y)
                        
                        pointRotationLayer.transform = CATransform3DMakeTranslation(x , y - 5 ,0)
                        let yValue = dataSource.lineChart(self ,
                                                          yValueAt: self.currentState == 0 ? 0 : self.currentState)
                        yValueTextLayer.transform = CATransform3DMakeTranslation(x , 0, 0)
                        yValueTextLayer.string = String(describing: yValue)
                        lineLayerPoint.transform =  CATransform3DMakeTranslation(x , 0, 0)
                    }
                }
            }
        }
    }
    
    private func notificationCenter() {
        NotificationCenter.default.addObserver(self , selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil )
    }
    // notification when user landscape or portrait device
    @objc private func orientationDidChange() {
        
        let orientation = UIDevice.current.orientation
        if orientation.isLandscape {
            DispatchQueue.main.async {
                self.reloadData()
            }
        } else if orientation.isPortrait {
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.minimumPressDuration = 0
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UILongPressGestureRecognizer) {
        linePointAnimation(gesture: gesture)
    }
    
    //MARK: - Show point run on line
    private func linePointAnimation(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self)

        guard let dataSource = dataSource else { return }
      
        switch gesture.state {
        case .began:
            let pressed = location.x
            for index in 0..<dataSource.numberOfItems(in: self)  {
                let xPos = vSpace * CGFloat(index)
                let yPoint = pointsData[index].y
                if pressed > xPos + sideSpace   {
                    let yValue = dataSource.lineChart(self , yValueAt: index < dataSource.numberOfItems(in: self) ? index : dataSource.numberOfItems(in: self) - 1 )
                    let xValue = dataSource.lineChart(self , xValueAt: index)
                    self.headerText?.string = "Voltage at: \(xValue)" // header text
                    startPointYValue(x: xPos, y: yPoint, yValue: yValue)
                    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
                    selectionFeedbackGenerator.selectionChanged()
                    self.currentState = index
                } else if pressed <= sideSpace*2 - sideSpace/2  && pressed >= sideSpace {
                    let yValue = dataSource.lineChart(self , yValueAt: 0 )
                    let yPoint = pointsData[0].y
                    startPointYValue(x: 0, y: yPoint, yValue: yValue)
                    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
                    selectionFeedbackGenerator.selectionChanged()
                    self.currentState = 0
                    let xValue = dataSource.lineChart(self , xValueAt: index)
                    self.headerText?.string = "Voltage at: \(xValue)"
                  
                }
            }
          
        case .changed:
            let pressed = location.x
            var previousXPos = self.pressedLocation
            for index in 0..<dataSource.numberOfItems(in: self)  {
                let xPos = vSpace * CGFloat(index)
                if  pressed > xPos + sideSpace {
                    let yValue = dataSource.lineChart(self , yValueAt: index < dataSource.numberOfItems(in: self) ? index : dataSource.numberOfItems(in: self))
                    let xValue = dataSource.lineChart(self , xValueAt: index)
                    let yPoint = pointsData[index].y
                    self.transformPointYValue(x: xPos, y: yPoint, yValue: yValue)
                    previousXPos = xPos
                    self.currentState = index
                    self.headerText?.string = "Voltage at: \(xValue)"
                }
                else if pressed <= sideSpace*2 - sideSpace/2 && pressed >= sideSpace {
                    let yValue = dataSource.lineChart(self , yValueAt: 0)
                    let yPoint = pointsData[0].y
                     self.transformPointYValue(x: 0, y: yPoint , yValue: yValue)
                    previousXPos = xPos
                    self.currentState = 0
                    let xValue = dataSource.lineChart(self , xValueAt: index)
                    self.headerText?.string = "Voltage at: \(xValue)"
                }
                
            }
            // haptic feedback when point move to new location
            for index in pointsData {
                if index.x - sideSpace == previousXPos {
                    if pressedLocation != previousXPos {
                        self.pressedLocation = previousXPos
                        
                        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
                        selectionFeedbackGenerator.selectionChanged()
                    }
                    break
                }
            }
            
        case .ended:
            if isHiddenLineBarValueOnRelease {
                barVerticalPoint?.isHidden = true
                pointRotationLayer?.isHidden = true
                yValueTextLayer?.isHidden = true
                headerText?.string = ""
            }
            barVerticalPoint?.delegate = nil
            pointRotationLayer?.delegate = nil
            yValueTextLayer?.delegate = nil
        default: break
            
        }
    }
    
    private func transformPointYValue(x: CGFloat, y: CGFloat, yValue: CGFloat) {
        if let lineLayerPoint = self.barVerticalPoint,
           let pointRotationLayer = self.pointRotationLayer,
           let yValueTextLayer = self.yValueTextLayer {
            
            lineLayerPoint.delegate = self
            pointRotationLayer.delegate = self
            yValueTextLayer.delegate = self
            
            lineLayerPoint.transform = CATransform3DMakeTranslation(x, 0, 0)
            pointRotationLayer.transform = CATransform3DMakeTranslation(x, y - 5, 0)
            yValueTextLayer.transform = CATransform3DMakeTranslation(x - 10, 0, 0)
            yValueTextLayer.string = String(describing: yValue)
            
            if isHiddenLineBarValueOnRelease {
                lineLayerPoint.isHidden = false
                pointRotationLayer.isHidden = false
                yValueTextLayer.isHidden = false
            }
        
        }
    }
    private func startPointYValue(x: CGFloat, y: CGFloat, yValue: CGFloat){
        if let lineLayerPoint = self.barVerticalPoint,
           let pointRotationLayer = self.pointRotationLayer,
           let yValueTextLayer = self.yValueTextLayer {
            
            lineLayerPoint.delegate = self
            pointRotationLayer.delegate = self
            yValueTextLayer.delegate = self
            
            lineLayerPoint.transform = CATransform3DMakeTranslation(x, 0, 0)
            pointRotationLayer.transform = CATransform3DMakeTranslation(x , y - 5, 0)
            yValueTextLayer.transform = CATransform3DMakeTranslation(x - 10, 0, 0)
            
            if isHiddenLineBarValueOnRelease {
                lineLayerPoint.isHidden = false
                pointRotationLayer.isHidden = false
                yValueTextLayer.isHidden = false
            }
            
            yValueTextLayer.string = String(describing: yValue)
        }
    }
   
}

