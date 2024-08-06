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
    
    public weak var dataSource: LineChartDataSource?
    public weak var delegate: LineChartDelegate?
    /// grid line width
    public var gridlineWidth: CGFloat = 0.3
    /// graph line indicator
    public var lineWidth: CGFloat = 1
    /// space for left side graph
    public var sideSpace: CGFloat = 25
    /// height space for show  value on AxisX  in bottom of graph
    public var bottomSpace: CGFloat = 25
    
    public var graphFillGradientColor: [UIColor] = [UIColor.white, UIColor.black]
    /// graph line indicator color
    public var lineGraphColor: UIColor = .white
    public var gridLineColor: UIColor = .gray
    public var labelsTextColor: UIColor = .black
    /// vertical line indicator transform on graph for point chart
    public var barVerticalLineIndicatorColor: UIColor = .green
    /// border circle point that show on line graph
    public var linePointBorderColor: UIColor = .white
    /// show line for AxisY
    public var showVerticalLine: Bool = true
    /// show line for AxisX
    public var showHorizontalLine: Bool = true
    /// show circle point on graph  line indicator
    public var showPointYValue: Bool = true
    public var showVerticalGridLine: Bool = true
    public var showHorizontalGridLine: Bool = true
    /// show label for display value in AxisX on bottom graph
    public var showBottomLabels: Bool = true
    /// show label for display value in AxisY on left side
    public var showSideLabels: Bool = true
    public var isHiddenLineBarValueOnRelease: Bool = true
    /// display chart line type
    public var chartType: LineChartType = .linear
    /// fill color circle point that show on line graph
    public var linePointFillColor: UIColor = .graph
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
   
    var vSpace: CGFloat = 0.0
    var pointsData: [CGPoint] = []
    var points: [CGFloat: CGFloat] = [:]
    
    var headerText: CenterTextLayer?
    var barVerticalIndicator: CALayer?
    var pointRotationLayer: CALayer?
    var yValueTextLayer: CATextLayer?
    var headerSpace: CGFloat {
         get {
             return 25
         }
    }
    var graphWidth: CGFloat  {
        get {
            if Thread.isMainThread {
                return frame.size.width - (showSideLabels ? sideSpace : 0)
            } else {
                return DispatchQueue.main.sync {
                    frame.size.width - (showSideLabels ? sideSpace  : 0)
                }
            }
        }
    }
    var graphHeight: CGFloat {
        get {
            if Thread.isMainThread {
                return frame.size.height - (showBottomLabels  ? bottomSpace :  0)
            } else {
                return DispatchQueue.main.sync {
                    frame.size.height - (showBottomLabels  ? bottomSpace :  0)
                }
            }
        }
    }
    
    private var currentState: Int = 0
    private var pressedLocation:CGFloat = 0
    private var orientation: Int = 0
    private var previousXPos = 0.0
    
     override init(frame: CGRect) {
        super.init(frame: frame)
         self.setupTapGesture()
         self.didOrientation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupTapGesture()
        self.didOrientation()
    }
       /// reload data when already set dataSource
       /// It will be call render function to draw chart
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
                   let lineLayerPoint = self.barVerticalIndicator {
                    if self.isHiddenLineBarValueOnRelease == false {
                        let x = self.currentState == 0 ? 0 : (self.vSpace) * CGFloat(self.currentState)
                        let y = (self.pointsData[self.currentState == 0 ? 0 : self.currentState].y)
                        let yValue = dataSource.lineChart(self, yValueAt: self.currentState == 0 ? 0 : self.currentState)
                        yValueTextLayer.string = String(describing: yValue)
                        
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        pointRotationLayer.transform = CATransform3DMakeTranslation(x , y - 5 ,0)
                        yValueTextLayer.transform = CATransform3DMakeTranslation(x , 0, 0)
                        lineLayerPoint.transform =  CATransform3DMakeTranslation(x , 0, 0)
                        CATransaction.commit()
                    }
                }
            }
        }
    }
    
    private func didOrientation() {
        NotificationCenter.default.addObserver(self , selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil )
        NotificationCenter.default.addObserver(self , selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    // notification when device orientation
    @objc private func orientationDidChange() {
        let orientation = UIDevice.current.orientation
        if (orientation.isLandscape || orientation.isPortrait) && applicationIsActive {
            if orientation.rawValue != self.orientation {
                DispatchQueue.main.async {
                    self.reloadData()
                }
                self.orientation = orientation.rawValue
            }
        }
    }
    @objc private func didBecomeActive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reloadData()
            self.orientation = UIDevice.current.orientation.rawValue
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
            for (index, pos) in pointsData.enumerated()  {
                if pressed >= pos.x   {
                    let yValue = dataSource.lineChart(self , yValueAt: index < dataSource.numberOfItems(in: self) ? index : dataSource.numberOfItems(in: self) )
                    let xValue = dataSource.lineChart(self , xValueAt: index)
                   
                    self.currentState = index
                    self.headerText?.string = "Voltage at: \(xValue)"
                    previousXPos = pos.x
                    self.yValueTextLayer?.string = String(describing: yValue)
                }
            }
        case .changed:
            let pressed = location.x
          
            for (index, pos) in pointsData.enumerated()   {
                if  pressed  >= pos.x {
                    if index < dataSource.numberOfItems(in: self) {
                        let yValue = dataSource.lineChart(self , yValueAt: index )
                        let xValue = dataSource.lineChart(self , xValueAt: index )
                       
                        self.yValueTextLayer?.string = String(describing: yValue)
                        previousXPos = pos.x
                        self.currentState = index
                        self.headerText?.string = "Voltage at: \(xValue)"
                    }
                }
            }
        case .ended:
            if isHiddenLineBarValueOnRelease {
                barVerticalIndicator?.isHidden = true
                pointRotationLayer?.isHidden = true
                yValueTextLayer?.isHidden = true
                headerText?.string = ""
            }
            barVerticalIndicator?.delegate = nil
            pointRotationLayer?.delegate = nil
            yValueTextLayer?.delegate = nil
        default: break
        }
        // haptic feedback when point move to new location
        for point in pointsData {
            if point.x  == previousXPos {
                if pressedLocation != previousXPos {
                    self.pressedLocation = previousXPos
                    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
                    selectionFeedbackGenerator.selectionChanged()
                    self.transformPointYValue(x: point.x - (showSideLabels ? sideSpace : 0), y: point.y)
                }
                break
            }
        }
    }
    
    private func transformPointYValue(x: CGFloat, y: CGFloat) {
        if let lineLayerPoint = self.barVerticalIndicator,
           let pointRotationLayer = self.pointRotationLayer,
           let yValueTextLayer = self.yValueTextLayer {
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            lineLayerPoint.transform = CATransform3DMakeTranslation(x, 0, 0)
            pointRotationLayer.transform = CATransform3DMakeTranslation(x, y - 5, 0)
            yValueTextLayer.transform = CATransform3DMakeTranslation(x - 10, 0, 0)
            CATransaction.commit()
            
            if isHiddenLineBarValueOnRelease {
                lineLayerPoint.isHidden = false
                pointRotationLayer.isHidden = false
                yValueTextLayer.isHidden = false
            }
         
        
        }
    }
   
   
}

