//
//  BarChartViewController.swift
//  SwiftChart
//
//  Created by Nimol on 31/7/24.
//

import UIKit



class BarChartViewController: UIViewController {
    
    @IBOutlet weak var barCharView: BarChartView!
    
    var data: [ChartData] = [
        ChartData(xValue: 0, yValue: 299),
        ChartData(xValue: 0, yValue: 280),
        ChartData(xValue: 0, yValue: 298),
        ChartData(xValue: 4, yValue: 250),
        ChartData(xValue: 5, yValue: 299),
        ChartData(xValue: 6, yValue: 295),
        ChartData(xValue: 7, yValue: 290),
        ChartData(xValue: 8, yValue: 270),
        ChartData(xValue: 9, yValue: 280),
        ChartData(xValue: 10, yValue: 299),
        ChartData(xValue: 11, yValue: 260),
        ChartData(xValue: 12, yValue: 299),
        ChartData(xValue: 13, yValue: 300),
        ChartData(xValue: 1, yValue: 299),
        ChartData(xValue: 2, yValue: 200),
        ChartData(xValue: 3, yValue: 298),
        ChartData(xValue: 4, yValue: 250),
        ChartData(xValue: 5, yValue: 299)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configBarChartView()
        
        let numbers = [4, 2, 3, 1]
        print(numbers.calculateHorizontalLine())
        
    }
    private func configBarChartView() {
        barCharView.dataSource = self
        barCharView.showVerticalLine = true
        barCharView.showBottomLabels = true
        barCharView.showHorizontalLine = true
        barCharView.labelsColor = .graph
        barCharView.showSideLabels = true
    }
    override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.barCharView.reloadData()
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
    
//    func numberOfHorizontal(in barChart: BarChartView, horizontalViewAt index: Int) -> Int {
//        return Int(data[index].yValue)
//    }
//    
//    func numberOfHorizontalLines(in barChart: BarChartView) -> Int {
//        return data.count
//    }
//    
    func numberOfVerticalLines(in barChart: BarChartView) -> Int {
       return data.count
    }
    
    func numberOfVertical(in barChart: BarChartView, verticalViewAt index: Int) -> String {
       return String(describing: data[index].xValue )
    }
    
    
}
