//
//  BarChartViewController.swift
//  SwiftChart
//
//  Created by Nimol on 31/7/24.
//

import UIKit

class BarChartViewController: UIViewController {
    
    @IBOutlet weak var barChartView: BarChartView!
    
    var data: [ChartModel] = [

        ChartModel(xValue: 0, yValue: 30),
        ChartModel(xValue: 0, yValue: 20),
        ChartModel(xValue: 4, yValue: 70),
        ChartModel(xValue: 5, yValue: 10),
        ChartModel(xValue: 6, yValue: 50),
        ChartModel(xValue: 7, yValue: 30),
        ChartModel(xValue: 8, yValue: 5),
    ]
    
    var verticalValue: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configBarChartView()

    }
    private func configBarChartView() {
        barChartView.dataSource = self
        barChartView.delegate = self
        
        barChartView.showVerticalGridLine = false
        barChartView.showHorizontalGridLine = true
        barChartView.showVerticalLine = true
        barChartView.showBottomLabels = true
        barChartView.showHorizontalLine = true
        barChartView.showSideLabels = true
        barChartView.isHiddenShowDetailAndBarLineValueOnRelease = false 
        barChartView.labelsTextColor = .graph
        barChartView.bottomShowDetailColor = .graph
        barChartView.barVerticalIndicatorColor = UIColor.green
        barChartView.barChartColor = .graph
        barChartView.showDetailForegroundColor = .green
        barChartView.sideSpace = 30
        barChartView.gridLineWidth = 1
        barChartView.bottomSpace = 25
        barChartView.barVerticalIndicatorWidth = 1
        barChartView.showDetailFontSize = 16
        
        barChartView.showDetailFont = UIFont.systemFont(ofSize: 10)
        barChartView.showDetailForegroundColor = UIColor.purple
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.barChartView.reloadData()
        }
    }
}

//MARK: - BarChartDataSource
extension BarChartViewController: BarChartDataSource {
    func numberOfItem(in barChart: BarChartView) -> Int {
        return data.count
    }
    func barChart(_ barChart: BarChartView, xValueAt index: Int) -> String {
        return  String(data[index].xValue)
    }
    func barChart(_ barChart: BarChartView, yValueAt index: Int) -> CGFloat {
        return data[index].yValue
    }
    func numberOfVerticalLines(in barChart: BarChartView) -> Int {
        return verticalValue.count
    }
    
    func numberOfVertical(in barChart: BarChartView, verticalViewAt index: Int) -> String {
       return verticalValue[index]
    }
}

//MARK: - BarChartDelegate
extension BarChartViewController: BarChartDelegate {
    public func barChartDidStartRender(_ barChart: BarChartView) {
//        print("barChartDidStartRender")
    }
    public func barChartDidFinishRender(_ barChart: BarChartView) {
//        print("barChartDidFinishRender")
    }
    public func barChartDidFailRender(_ barChart: BarChartView) {
//        print("barChartDidFailRender")
    }
}
