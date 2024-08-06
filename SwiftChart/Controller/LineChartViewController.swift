//
//  ViewController.swift
//  SwiftLineChart
//
//  Created by Nimol on 24/7/24.
//

import UIKit



class LineChartViewController: UIViewController {
    
    private let horizontalNumber = ["00:00", "6:00", "12:00", "18:00", "24:00"]

    // calling chartView Class
    lazy var chartView: LineChartView = {
        let lineChart = LineChartView()
        lineChart.gridlineWidth = 1
        lineChart.sideSpace = 30
        lineChart.bottomSpace = 25
        lineChart.showVerticalGridLine = false
        lineChart.showHorizontalGridLine = true
        lineChart.showBottomLabels = true
        lineChart.showSideLabels = true
        lineChart.gridLineColor = .gray
        lineChart.labelsTextColor = .graph
        lineChart.chartType = .linear
        lineChart.graphFillGradientColor = [.graph, .black]
        lineChart.showPointYValue = true
        lineChart.dataSource = self
        lineChart.delegate = self
        lineChart.lineWidth = 1
        lineChart.lineGraphColor = .systemPink
        lineChart.barVerticalLineIndicatorColor = .red
        lineChart.linePointFillColor = .graph
        lineChart.linePointBorderColor = .white
        
        lineChart.isHiddenLineBarValueOnRelease = false
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        return lineChart
    }()
    
    // sample data
    var data: [ChartModel] = [
        ChartModel(xValue: 0, yValue: 270),
        ChartModel(xValue: 4, yValue: 5),
        ChartModel(xValue: 0, yValue: 298),
        ChartModel(xValue: 4, yValue: 250),
        ChartModel(xValue: 5, yValue: 299),
        ChartModel(xValue: 6, yValue: 295),
        ChartModel(xValue: 7, yValue: 290),
        ChartModel(xValue: 8, yValue: 270),
        ChartModel(xValue: 9, yValue: 280),
        ChartModel(xValue: 10, yValue: 299),
        ChartModel(xValue: 11, yValue: 260),
        ChartModel(xValue: 12, yValue: 299),
        ChartModel(xValue: 13, yValue: 300),
        ChartModel(xValue: 1, yValue: 299),
        ChartModel(xValue: 2, yValue: 200),
        ChartModel(xValue: 3, yValue: 298),
        ChartModel(xValue: 4, yValue: 250),
        ChartModel(xValue: 5, yValue: 299),
        ChartModel(xValue: 6, yValue: 295),
        ChartModel(xValue: 7, yValue: 290),
        ChartModel(xValue: 8, yValue: 270),
        ChartModel(xValue: 9, yValue: 280),
        ChartModel(xValue: 10, yValue: 299),
        ChartModel(xValue: 11, yValue: 260),
        ChartModel(xValue: 12, yValue: 299),
        ChartModel(xValue: 13, yValue: 300),
        ChartModel(xValue: 0, yValue: 270),
        ChartModel(xValue: 4, yValue: 5),
        ChartModel(xValue: 0, yValue: 298),
        ChartModel(xValue: 4, yValue: 250),
        ChartModel(xValue: 5, yValue: 299),
        ChartModel(xValue: 6, yValue: 295),
        ChartModel(xValue: 7, yValue: 290),
        ChartModel(xValue: 8, yValue: 270),
        ChartModel(xValue: 9, yValue: 280),
        ChartModel(xValue: 10, yValue: 299),
        ChartModel(xValue: 11, yValue: 260),
        ChartModel(xValue: 12, yValue: 299),
        ChartModel(xValue: 13, yValue: 300),
        ChartModel(xValue: 1, yValue: 299),
        ChartModel(xValue: 2, yValue: 200),
        ChartModel(xValue: 3, yValue: 298),
        ChartModel(xValue: 4, yValue: 250),
        ChartModel(xValue: 5, yValue: 299),
        ChartModel(xValue: 6, yValue: 295),
        ChartModel(xValue: 7, yValue: 290),
        ChartModel(xValue: 8, yValue: 270),
        ChartModel(xValue: 9, yValue: 280),
        ChartModel(xValue: 10, yValue: 299),
        ChartModel(xValue: 11, yValue: 260),
        ChartModel(xValue: 12, yValue: 299),
        ChartModel(xValue: 13, yValue: 300),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(chartView)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chartView.headerTextColor = .green
        chartView.headerTextFont = UIFont.systemFont(ofSize: 10)
        chartView.headerTextFontSize = 15

        DispatchQueue.main.async {
            self.chartView.reloadData()
        }
       
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            chartView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            chartView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5)
        ])
    }
 
    
}

//MARK: - LineChartDataSource
extension LineChartViewController: LineChartDataSource {
    
    func numberOfItems(in lineChart: LineChartView) -> Int {
        return data.count
    }
    func lineChart(_ lineChart: LineChartView, xValueAt index: Int) -> Double {
        return data[index].xValue
    }

    func lineChart(_ lineChart: LineChartView, yValueAt index: Int) -> CGFloat {
        return data[index].yValue
    }
    
    func lineChart(_ lineChart: LineChartView, viewXValueAt index: Int) -> String {
        return String(describing: horizontalNumber[index])
    }
    func numberOfVerticalLines(in lineChart: LineChartView) -> Int { 
        return horizontalNumber.count
    }
    
}


//MARK: - LineChartDelegate
extension LineChartViewController: LineChartDelegate {
    func lineChartDidStartRender(_ lineChart: LineChartView) {
        print("lineChartDidStartRender")
    }
    func lineChartDidFinishRender(_ lineChart: LineChartView) {
        print("lineChartDidFinishRender")
    }
    func lineChartDidFailRender(_ lineChar: LineChartView) {
        print("lineChartDidFailRender")
    }
    
}

