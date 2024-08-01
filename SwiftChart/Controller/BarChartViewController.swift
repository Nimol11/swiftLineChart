//
//  BarChartViewController.swift
//  SwiftChart
//
//  Created by Nimol on 31/7/24.
//

import UIKit



class BarChartViewController: UIViewController {
    
    @IBOutlet weak var barChartView: BarChartView!
    
    var data: [ChartData] = [
        ChartData(xValue: 0, yValue: 299),
        ChartData(xValue: 0, yValue: 280),
        ChartData(xValue: 0, yValue: 298),
        ChartData(xValue: 4, yValue: 250),
        ChartData(xValue: 5, yValue: 299),
        ChartData(xValue: 6, yValue: 295),
        ChartData(xValue: 7, yValue: 290),
//        
//        ChartData(xValue: 8, yValue: 270),
//        ChartData(xValue: 9, yValue: 280),
//        ChartData(xValue: 10, yValue: 299),
//        ChartData(xValue: 11, yValue: 260),
//        ChartData(xValue: 12, yValue: 299),
//        ChartData(xValue: 13, yValue: 300),
//        ChartData(xValue: 1, yValue: 299),
//        ChartData(xValue: 2, yValue: 200),
//        ChartData(xValue: 3, yValue: 298),
//        ChartData(xValue: 4, yValue: 250),
//        ChartData(xValue: 5, yValue: 1)
    ]
    var verticalValue: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configBarChartView()
     
    }
    private func configBarChartView() {
        barChartView.dataSource = self
        barChartView.delegate = self
        barChartView.showVerticalLine = true
        barChartView.showBottomLabels = true
        barChartView.showHorizontalLine = true
        barChartView.labelsColor = .graph
        barChartView.showSideLabels = true
        barChartView.bottomShowDetailColor = .graph
        barChartView.barVerticalPointColor = UIColor.green
        barChartView.showVerticalGrid = false 
        barChartView.barChartColor = .graph
        barChartView.showVerticalLine = false
        barChartView.isHiddenShowDetailAndBarLineValueOnRelease = false
        barChartView.showDetailFontSize = 16
        barChartView.showDetailForegroundColor = .green
        barChartView.bottomShowDetailColor = .red
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
    func barChart(_ barChart: BarChartView, xValueAt index: Int) -> CGFloat {
        return data[index].xValue
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

extension BarChartViewController: BarChartDelegate {
    public func barChartDidStartRender(_ barChart: BarChartView) {
        print("barChartDidStartRender")
    }
    public func barChartDidFinishRender(_ barChart: BarChartView) {
        print("barChartDidFinishRender")
    }
    public func barChartDidFailRender(_ barChart: BarChartView) {
        print("barChartDidFailRender")
    }
}
