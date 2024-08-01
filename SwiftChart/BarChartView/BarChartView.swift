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
    public var sideSpace: CGFloat = 25 //  space for show side value
    public var bottomSpace: CGFloat = 25 //  space for show name bottom
    public var showVerticalGrid: Bool = true  // True: show vertical grid line, False: Hide line
    public var showHorizontalGrid: Bool = true // True: show horizontal grid line, False: Hide line
    public var showBottomLabels: Bool = true
    public var showSideLabels: Bool = true
    public var gridColor: UIColor = .gray
    public var labelsColor: UIColor = .black
    public var showVerticalLine: Bool = true
    public var showHorizontalLine: Bool = true
    public var barChartColor: UIColor = UIColor.purple
    
    // bar chart view frame
    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 0.0
    var graphWidth: CGFloat = 0.0
    var graphHeight: CGFloat = 0.0
    
    // Layer draw show detail
    var labelDate: CenterTextLayer?
    var labelValue: CenterTextLayer?
    var bottomShowDetail: CAShapeLayer?
    var showDetailLayer: CALayer?
    var barVerticalPoint: CALayer?
    var headerText: CenterTextLayer?
    
    var barVerticalPointColor: UIColor = UIColor.red
    var barVerticalPointWidth: CGFloat = 1.0
    
    var bottomShowDetailColor: UIColor = UIColor.green
    var triangle: CAShapeLayer?
    var axisXPoint: [CGFloat] = []
    var vSpace: CGFloat = 0
    private var pressedLocation: CGFloat = 0
    private var currentStart: Int = 0
    private var orientation: Int = 0
    private var isHiddenLine: Bool = false
    
    var padding: CGFloat  {
        get {
            return 16
        }
    }
    var showValueDetailSpace: CGFloat  {
        get {
            return 50
        }
    }
    var headerSpace: CGFloat {
        get {
            return 25
        }
    }
    
    var isHiddenShowDetailAndBarLineValueOnRelease: Bool = true  {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                labelDate?.isHidden = isHiddenShowDetailAndBarLineValueOnRelease
                labelValue?.isHidden = isHiddenShowDetailAndBarLineValueOnRelease
                bottomShowDetail?.isHidden = isHiddenShowDetailAndBarLineValueOnRelease
                showDetailLayer?.isHidden = isHiddenShowDetailAndBarLineValueOnRelease
                barVerticalPoint?.isHidden = isHiddenShowDetailAndBarLineValueOnRelease
                triangle?.isHidden = isHiddenShowDetailAndBarLineValueOnRelease
            }
        }
    }
    var showDetailFont: UIFont = UIFont.systemFont(ofSize: 10){
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                labelDate?.font = CGFont(showDetailFont.fontName as NSString)
                labelValue?.font = CGFont(showDetailFont.fontName as NSString)
            }
        }
    }
    var showDetailFontSize: CGFloat = 13 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self  else { return }
                labelDate?.fontSize = showDetailFontSize
                labelValue?.fontSize = showDetailFontSize
            }
        }
    }
    var showDetailForegroundColor: UIColor = UIColor.green {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                labelDate?.foregroundColor = showDetailForegroundColor.cgColor
                labelValue?.foregroundColor = showDetailForegroundColor.cgColor
            }
        }
    }
    var setHeaderText: String = "kWh" {
        didSet {
            DispatchQueue.main.async { [self] in 
                self.headerText?.string = setHeaderText
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
        
        if isHiddenShowDetailAndBarLineValueOnRelease {
            isHiddenShowDetailAndBarLineValueOnRelease = true
        } else {
            isHiddenShowDetailAndBarLineValueOnRelease = false
            if let labelDate = labelDate,
               let labelValue = labelValue,
               let triangle = triangle,
               let barVerticalPoint = barVerticalPoint {
                
                let xValue = dataSource.barChart(self , xValueAt:  currentStart )
                let yValue = dataSource.barChart(self , yValueAt: currentStart )
                let xPos = axisXPoint[currentStart] - (showSideLabels ? sideSpace : 0) - padding/2 + vSpace/2
                labelDate.string = "\(xValue)"
                labelValue.string = "\(yValue) kWh"
                barVerticalPoint.transform = CATransform3DMakeTranslation(xPos, 0, 0)
                triangle.transform = CATransform3DMakeTranslation(xPos - 6, 0, 0)
            }
        }
        self.isHiddenLine = isHiddenShowDetailAndBarLineValueOnRelease
    }
    private func deviceOrientation() {
        NotificationCenter.default.addObserver(self, selector: #selector(didOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    @objc private func didOrientation() {
        let orientation = UIDevice.current.orientation
        if orientation.isLandscape || orientation.isPortrait {
            if orientation.rawValue != self.orientation {
                DispatchQueue.main.async {
                    self.reloadData()
                }
                self.orientation = orientation.rawValue
            }
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
                let x = xPos - (showSideLabels ? sideSpace : 0) - padding/2
                if pressed > xPos {
                    let xValue = dataSource?.barChart(self , xValueAt: index )
                    let yValue = dataSource?.barChart(self , yValueAt: index)
                    self.barVerticalPoint?.delegate = self
                    self.barVerticalPoint?.transform = CATransform3DMakeTranslation(x + vSpace/2, 0, 0)
                    self.triangle?.delegate = self
                    self.triangle?.transform = CATransform3DMakeTranslation(x + vSpace/2 - 6, 0, 0)
                    self.labelDate?.string = "\(xValue ?? 0)"
                    self.labelValue?.string = "\(yValue ?? 0) kWh"
                    
                    if isHiddenShowDetailAndBarLineValueOnRelease {
                        self.isHiddenShowDetailAndBarLineValueOnRelease = false
                    }
                    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
                    selectionFeedbackGenerator.selectionChanged()
                    self.currentStart = index
                }
            }
        case .changed:
            let pressed = location.x
            var previousXPos = 0.0
            for (index, xPos) in axisXPoint.enumerated() {
                let x = xPos - (showSideLabels ? sideSpace : 0) - padding/2
                if pressed > xPos {
                    let xValue = dataSource?.barChart(self , xValueAt: index )
                    let yValue = dataSource?.barChart(self , yValueAt: index)
                    self.barVerticalPoint?.delegate = self
                    self.barVerticalPoint?.transform = CATransform3DMakeTranslation(x + vSpace/2, 0, 0)
                    self.triangle?.delegate = self
                    self.triangle?.transform = CATransform3DMakeTranslation(x + vSpace/2 - 6, 0, 0)
                    self.labelDate?.string = "\(xValue ?? 0)"
                    self.labelValue?.string = "\(yValue ?? 0) kWh"
                    previousXPos = xPos
                    self.currentStart = index
                }
            }
            
            for point in axisXPoint {
                if point == previousXPos {
                    if pressedLocation != previousXPos {
                        self.pressedLocation = previousXPos
                        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
                        selectionFeedbackGenerator.selectionChanged()
                    }
                    break
                }
            }
           
        case .ended:
            if isHiddenLine {
                self.isHiddenShowDetailAndBarLineValueOnRelease = true
                
            }
            self.triangle?.delegate = nil
            self.barVerticalPoint?.delegate = nil
        case .possible: break
        case .cancelled: break
        case .failed: break
        @unknown default:
            break
        }
    }
}
