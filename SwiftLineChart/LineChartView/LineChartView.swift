//
//  LineChart.swift
//  SwiftAnimation
//
//  Created by Nimol on 22/7/24.
//
import UIKit

// MARK: Chart type
public enum LineChartType: Int {
    case linear = 0
    case curved = 1
    public init() { self = .linear }
}

// MARK: - UIView
public class LineChartView: UIView {
    
    @IBInspectable public var gridWidth: CGFloat = 0.3 // line grid width
    @IBInspectable public var lineWidth: CGFloat = 3 // width line chart
    @IBInspectable public var sideSpace: CGFloat = 44 //  space for show side value
    @IBInspectable public var bottomSpace: CGFloat = 44 //  space for show name bottom
    @IBInspectable public var showVerticalGrid: Bool = true  // True: show vertical grid line, False: Hide line
    @IBInspectable public var showHorizontalGrid: Bool = true // True: show horizontal grid line, False: Hide line
    @IBInspectable public var showBottomLabels: Bool = true
    @IBInspectable public var showSideLabels: Bool = true
    @IBInspectable public var gridColor: UIColor = .gray
    @IBInspectable public var labelsColor: UIColor = .black
    @IBInspectable public var showVerticalLine: Bool = true
    @IBInspectable public var showHorizontalLine: Bool = true
    @IBInspectable public var showPointYValue: Bool = true
    @IBInspectable public var showPointYValueColor: UIColor = .red
    @IBInspectable public var graphFillGradientColor: [UIColor] = [UIColor.white, UIColor.black]
    @IBInspectable public var lineGraphColor: UIColor = .white
    
    public var barLineValueColor: UIColor = .green
    public var chartType: LineChartType = .linear
    public weak var dataSource: LineChartDataSource?
    public weak var delegate: LineChartDelegate?
    
    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 0.0
    var graphWidth: CGFloat = 0.0
    var graphHeight: CGFloat = 0.0
    let padding: CGFloat = 44
    
   private let textLayer = UILabel()
   private let lineView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupTapGesture()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupTapGesture()
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
            }
        }
    }
    private func setupTapGesture() {
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.minimumPressDuration = 0
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UILongPressGestureRecognizer) {
        closestDataPoint(gesture: gesture)
    }
    
    private func closestDataPoint(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self)
       
        guard let dataSource = dataSource else { return }
        
        if gesture.state == .began {
            
            self.textLayer.frame = CGRect(x: 0, y: 10, width: 50 , height: 30)
            self.textLayer.textAlignment = .center
            self.lineView.frame = CGRect(x: 0, y: 50, width: 2, height: self.frame.height - (showBottomLabels ? bottomSpace : 0) - 50)
            self.lineView.backgroundColor = self.barLineValueColor
            self.addSubview(textLayer)
            self.addSubview(lineView)
            
        } else if gesture.state == .changed {            
            let pressed = location.x
            let vSpace = graphWidth / CGFloat(dataSource.numberOfItems(in: self))
            for index in 0..<dataSource.numberOfItems(in: self) {
                let xPos =   (showSideLabels ? sideSpace : 0) + vSpace * CGFloat(index)
                if pressed <= xPos + 25 {
                    let yValue = dataSource.lineChart(self , yValueAt: index)
                    
                    UIView.animate(withDuration: 0.2) {
                        self.textLayer.text = String(describing: yValue)
                        self.textLayer.transform = CGAffineTransform(translationX: xPos - (25) , y: 0)
                        self.lineView.transform = CGAffineTransform(translationX: xPos - 1  , y: 0)
                    }
                    self.delegate?.lineShowYValue?(yValue, xPos)
                    break
                }
            }
        } else if gesture.state == .ended {
           
            self.textLayer.transform = .identity
            self.textLayer.text = ""
            self.textLayer.removeFromSuperview()
            self.lineView.transform = .identity
            self.lineView.removeFromSuperview()
            
        }
        
    }
}
