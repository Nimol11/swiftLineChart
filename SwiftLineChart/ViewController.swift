//
//  ViewController.swift
//  SwiftLineChart
//
//  Created by Nimol on 24/7/24.
//

import UIKit

struct ChartData: LineChartData {
    var xValue: String
    var yValue: Double
}

class ViewController: UIViewController {

   
    private var verticalNumber = [ 25, 50, 75, 100, 125, 150, 175, 200,225, 250, 275, 300]
       private let horizontalNumber = ["00:00", "6:00", "12:00", "18:00", "24:00"]
       
      
       
       lazy var chartView: LineChartView = {
           let lineChart = LineChartView()
           lineChart.gridWidth = 0.3
           lineChart.lineWidth = 2
           lineChart.sideSpace = 25
           lineChart.bottomSpace = 25
           lineChart.showVerticalGrid = true
           lineChart.showHorizontalGrid = true
           lineChart.showBottomLabels = true
           lineChart.showSideLabels = true
           lineChart.gridColor = .gray
           lineChart.labelsColor = .graph
           lineChart.chartType = .curved
           lineChart.graphFillGradientColor = [.graph, .black]
           lineChart.showPointYValueColor = .graph
           lineChart.showPointYValue = true
           lineChart.dataSource = self
           lineChart.delegate = self
           lineChart.lineWidth = 1
           lineChart.barLineValueColor = .red
           lineChart.translatesAutoresizingMaskIntoConstraints = false
           return lineChart
       }()
       
       var data: [ChartData] = [
               ChartData(xValue: "1", yValue: 20),
               ChartData(xValue: "2", yValue: 200),
               ChartData(xValue: "3", yValue: 7),
               ChartData(xValue: "4", yValue: 3),
               ChartData(xValue: "5", yValue: 1),
               ChartData(xValue: "6", yValue: 5),
               ChartData(xValue: "7", yValue: 40),
               ChartData(xValue: "8", yValue: 60),
               ChartData(xValue: "9", yValue: 85),
               ChartData(xValue: "10", yValue: 30),
               ChartData(xValue: "11", yValue: 20),
               ChartData(xValue: "12", yValue: 100),
               ChartData(xValue: "13", yValue: 200),
        
           ]

       override func viewDidLoad() {
           super.viewDidLoad()
           view.addSubview(chartView)
          
       }
       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           DispatchQueue.main.async {
               self.chartView.reloadData()
           }
       }
       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           NSLayoutConstraint.activate([
               chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
               chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
               chartView.heightAnchor.constraint(equalToConstant: 600 ),
               chartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
           ])
       }

}


extension ViewController: LineChartDataSource {
       
       func numberOfItems(in lineChart: LineChartView) -> Int {
           return data.count
       }

       func lineChart(_ lineChart: LineChartView, yValueAt index: Int) -> CGFloat {
           return data[index].yValue
       }

       func lineChart(_ lineChart: LineChartView, xValueAt index: Int) -> String {
           return String(describing: horizontalNumber[index])
       }
       func numberOfVerticalLines(in lineChart: LineChartView) -> Int { horizontalNumber.count
       }
       
       func numberOfHorizontalLines(in lineChart: LineChartView) -> Int { verticalNumber.count  }
       
 
       
       func numberOfSideLabels(in lineChart: LineChartView) -> [Int] { verticalNumber }
       
       
      
   }

extension ViewController: LineChartDelegate {
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
