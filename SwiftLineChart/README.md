# Draw Line Chart

## Requirement 

<br> iOS 12+ 
<br> swift 5.9 

## :bulb: Usage 

:key: To initialize a line chart programmatically
```swift 
let lineChart = LineChartView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
```
:key: To initialize a line chart using storyboard 

<img src = "https://github.com/Nimol11/swiftLineChart/blob/main/image/Screenshot%202024-07-25%20at%208.49.32%20in%20the%20morning.png?raw=true" width = 400px />

:key: Need to reload chart data 

```swift 
self.lineChart.reloadData()
``` 

:eyes: property 

```swift
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

```

:eyes: sample data  

``` swift 
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
    
```

### :bulb: DataSource 

```swift 

 @objc public protocol LineChartDataSource: AnyObject {
   func numberOfItems(in lineChart: LineChartView) -> Int
     
   func numberOfSideLabels(in lineChart: LineChartView) -> [Int]
     
   func numberOfVerticalLines(in lineChart: LineChartView) -> Int

   func numberOfHorizontalLines(in lineChart: LineChartView) -> Int
    
   @objc optional func lineChart(_ lineChart: LineChartView, xValueAt index: Int) -> String
    
   func lineChart(_ lineChart: LineChartView, yValueAt index: Int) -> CGFloat
     
   @objc optional  func lineChart(_ lineChart: LineChartView, verticalDashPatternAt index: Int) -> [NSNumber]
     
   @objc optional func lineChart(_ lineChart: LineChartView, horizontalDashPatternAt index: Int) -> [NSNumber]
}

```

### :bulb: Delegate 

```swift 

@objc public protocol LineChartDelegate: AnyObject {

   @objc optional func lineChartDidStartRender(_ lineChart: LineChartView)

   @objc optional func lineChartDidFinishRender(_ lineChart: LineChartView)

   @objc optional func lineChartDidFailRender(_ lineChar: LineChartView)

   @objc optional func lineShowYValue(_ yValue: CGFloat, _ xLocation: CGFloat)
}

```

## Result 

<img src = "https://github.com/Nimol11/swiftLineChart/blob/main/image/Screenshot%202024-07-25%20at%208.49.53%20in%20the%20morning.png?raw=true" width= 400px />

