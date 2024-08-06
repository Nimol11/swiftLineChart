//
//  BarChartView.swift
//  SwiftChart
//
//  Created by Nimol on 30/7/24.
//

import UIKit

public class BarChartView: UIView {
    
    public weak var delegate: BarChartDelegate?
    public weak var dataSource: BarChartDataSource?
    
    /// grid line width
    public var gridLineWidth: CGFloat = 1
    
    /// space for left side graph
    public var sideSpace: CGFloat = 25
    
    /// height space for show  value on AxisX in bottom of graph
    public var bottomSpace: CGFloat = 25

    /// vertical line indicator transform on graph for point bar chart
    public var barVerticalIndicatorWidth: CGFloat = 1.0
    public var gridLineColor: UIColor = .gray
    public var labelsTextColor: UIColor = .black
    public var barChartColor: UIColor = UIColor.purple
    public var barVerticalIndicatorColor: UIColor = UIColor.red
    
    /// background color for show graph value detail
    public var bottomShowDetailColor: UIColor = UIColor.green
    
    public var showVerticalGridLine: Bool = true
    public var showHorizontalGridLine: Bool = true
    
    /// show label for display value in AxisX on bottom graph
    public var showBottomLabels: Bool = true
    /// show label for display value in AxisY on left side
    public var showSideLabels: Bool = true
    /// show line for AxisY
    public var showVerticalLine: Bool = true
    /// show line for AxisX
    public var showHorizontalLine: Bool = true
    public var isHiddenShowDetailAndBarLineValueOnRelease: Bool = true
    /// set font for display graph value detail when user hold on graph
    public var showDetailFont: UIFont = UIFont.systemFont(ofSize: 10){
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                labelDate?.font = CGFont(showDetailFont.fontName as NSString)
                labelValue?.font = CGFont(showDetailFont.fontName as NSString)
            }
        }
    }
    /// set font  size for display graph value detail when user hold on graph
    public var showDetailFontSize: CGFloat = 13 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self  else { return }
                labelDate?.fontSize = showDetailFontSize
                labelValue?.fontSize = showDetailFontSize
            }
        }
    }
    /// set text color for display graph value detail when user hold on graph
    public var showDetailForegroundColor: UIColor = UIColor.green {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                labelDate?.foregroundColor = showDetailForegroundColor.cgColor
                labelValue?.foregroundColor = showDetailForegroundColor.cgColor
            }
        }
    }
    public var setTextHeaderAxisY: String = "kWh" {
        didSet {
            DispatchQueue.main.async { [self] in
                self.headerText?.string = setTextHeaderAxisY
            }
        }
    }
    // bar chart  frame
    var graphWidth: CGFloat  {
        get {
               if Thread.isMainThread {
                   return frame.size.width - (showSideLabels ? sideSpace  : 0) - padding
               } else {
                   return DispatchQueue.main.sync {
                        frame.size.width - (showSideLabels ? sideSpace  : 0) - padding
                   }
               }
           }
    }
    var graphHeight: CGFloat {
        get {
            if Thread.isMainThread {
                return frame.size.height - (showBottomLabels  ? bottomSpace :  0) - showValueDetailSpace
            } else {
                return DispatchQueue.main.sync {
                     frame.size.height - (showBottomLabels  ? bottomSpace :  0) - showValueDetailSpace
                }
            }
        }
    }
    
    var vSpace: CGFloat = 0
    var labelDate: CenterTextLayer?
    var labelValue: CenterTextLayer?
    var bottomShowDetail: CAShapeLayer?
    var showDetailLayer: CALayer?
    var barVerticalPoint: CALayer?
    var headerText: CenterTextLayer?
    var triangle: CAShapeLayer?
    var axisXPoint: [CGFloat] = []
      
    var padding: CGFloat  {
        get { 16 }
    }
    var showValueDetailSpace: CGFloat  {
        get { 50 }
    }
    var headerSpace: CGFloat {
        get { 25 }
    }
    private var previousXPos = 0.0
    private var pressedLocation: CGFloat = 0
    private var currentStart: Int = 0
    private var orientation: Int = 0
    private var isHiddenDetail: Bool = true {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                labelDate?.isHidden = isHiddenDetail
                labelValue?.isHidden = isHiddenDetail
                bottomShowDetail?.isHidden = isHiddenDetail
                showDetailLayer?.isHidden = isHiddenDetail
                barVerticalPoint?.isHidden = isHiddenDetail
                triangle?.isHidden = isHiddenDetail
            }
        }
    }
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupGesture()
        self.deviceOrientation()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupGesture()
        self.deviceOrientation()
    }
  
     /// reload data when already set dataSource
     /// It will be call render function to draw chart
    public func reloadData(on dispatchQueue: DispatchQueue = .global(qos: .userInitiated)) {
        guard let dataSource = dataSource else { return }
        if let barChartDidStartRender = delegate?.barChartDidStartRender {
            barChartDidStartRender(self)
        }
        
        self.render(dataSource, dispatchQueue) { [weak self] in
            guard let self = self else { return }
            if let barChartDidFinishRender = delegate?.barChartDidFinishRender {
                barChartDidFinishRender(self)
                initializeValue(dataSource: dataSource)
            }
        }
    }
    private func initializeValue(dataSource: BarChartDataSource) {
        
        if !isHiddenShowDetailAndBarLineValueOnRelease {
            self.isHiddenDetail = false
            if let labelDate = labelDate,
               let labelValue = labelValue,
               let triangle = triangle,
               let barVerticalPoint = barVerticalPoint {
                
                let xValue = dataSource.barChart(self , xValueAt:  currentStart )
                let yValue = dataSource.barChart(self , yValueAt: currentStart )
                let xPos = axisXPoint[currentStart] - (showSideLabels ? sideSpace : 0) - padding/2 + vSpace/2
                labelDate.string = "\(xValue)"
                labelValue.string = "\(yValue) kWh"
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                barVerticalPoint.transform = CATransform3DMakeTranslation(xPos, 0, 0)
                triangle.transform = CATransform3DMakeTranslation(xPos - 6, 0, 0)
                CATransaction.commit()
                
            }
        } else {
            self.isHiddenDetail = true
        }
       
    }
    private func deviceOrientation() {
        NotificationCenter.default.addObserver(self, selector: #selector(didOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self , selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    @objc private func didOrientation() {
        let orientation = UIDevice.current.orientation
        if (orientation.isLandscape || orientation.isPortrait)  && applicationIsActive  {
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
    private func setupGesture() {
        let tapGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self , action:#selector(didTapGesture( _ :)) )
        tapGesture.minimumPressDuration = 0
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
    }
    @objc private func didTapGesture(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            let pressed = location.x
            for (index, xPos) in axisXPoint.enumerated() {
                if pressed > xPos {
                    let xValue = dataSource?.barChart(self , xValueAt: index )
                    let yValue = dataSource?.barChart(self , yValueAt: index)
                    self.labelDate?.string = "\(xValue ?? "")"
                    self.labelValue?.string = "\(yValue ?? 0) kWh"
                    previousXPos = xPos
                    if isHiddenShowDetailAndBarLineValueOnRelease {
                        self.isHiddenDetail = false
                    }
                    self.currentStart = index
                }
            }
        case .changed:
            let pressed = location.x
            
            for (index, xPos) in axisXPoint.enumerated() {
                if pressed > xPos {
                    if isHiddenShowDetailAndBarLineValueOnRelease {
                        self.isHiddenDetail = false
                    }
                    let xValue = dataSource?.barChart(self , xValueAt: index )
                    let yValue = dataSource?.barChart(self , yValueAt: index )
                    self.labelDate?.string = xValue
                    self.labelValue?.string = "\(yValue ?? 0) kWh"
                    previousXPos = xPos
                    self.currentStart = index
                }
            }            
           
        case .ended:
            if isHiddenShowDetailAndBarLineValueOnRelease {
                self.isHiddenDetail = true
            } else {
                self.isHiddenDetail = false
            }
            self.triangle?.delegate = nil
            self.barVerticalPoint?.delegate = nil
        case .possible: break
        case .cancelled: break
        case .failed: break
        @unknown default:
            break
        }
        // haptic feedback when point move to new location
        for point in axisXPoint {
            if point == previousXPos {
                if pressedLocation != previousXPos {
                    self.pressedLocation = previousXPos
                    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
                    selectionFeedbackGenerator.selectionChanged()
                    let x = point - (showSideLabels ? sideSpace : 0) - padding/2
                    CATransaction.begin()
                    CATransaction.setDisableActions(true )
                    self.barVerticalPoint?.transform = CATransform3DMakeTranslation(x + vSpace/2, 0, 0)
                    self.triangle?.transform = CATransform3DMakeTranslation(x + vSpace/2 - 6, 0, 0)
                    CATransaction.commit()
                }
                break
            }
        }
    }
  
}
