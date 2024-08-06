# Draw Line Chart

## Requirement 

<br> iOS 12+ 
<br> swift 5.9 

## :bulb: Usage 

:key: To initialize a line chart programmatically
<br> <b> Line Chart </b>
```swift 
let lineChart = LineChartView(frame: CGRect(x: 0, y: 0, width: 200, height: 300))
```
<br> <b> Bar Chart </b>
```swift 
let barChart = BarChartView(frame: CGRect(x: 0, y:0 , width: 200, height: 300))
```
:key: To initialize a line chart using storyboard 
 <br> <b>Line Chart </b> <br>
<img src = "https://github.com/Nimol11/swiftLineChart/blob/main/image/Screenshot%202024-07-25%20at%208.49.32%20in%20the%20morning.png?raw=true" width = 400px />
<br> Bar Chart <br>
<img src = "https://github.com/Nimol11/video/blob/main/folder/Screenshot%202024-08-06%20at%208.36.01%20in%20the%20morning.png?raw=true" width = 400px />

:key: Need to reload chart data  after set data 

```swift 
lineChart.reloadData()
``` 
``` swift 
barChart.reloadData()
```

:eyes: property 
<br> Line Chart </b>
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
<br> Bar Chart  </b>
```swift 
barChartView.dataSource = self
barChartView.delegate = self

barChartView.showVerticalGridLine = true
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
<br> Line Chart  </b>
```swift 
    func numberOfItems(in lineChart: LineChartView) -> Int
    func numberOfVerticalLines(in lineChart: LineChartView) -> Int
    func lineChart(_ lineChart: LineChartView, xValueAt index: Int) -> Double
    func lineChart(_ lineChart: LineChartView, yValueAt index: Int) -> CGFloat
    @objc optional func lineChart(_ lineChart: LineChartView, viewXValueAt index: Int) -> String
    @objc optional  func lineChart(_ lineChart: LineChartView, verticalDashPatternAt index: Int) -> [NSNumber]
    @objc optional func lineChart(_ lineChart: LineChartView, horizontalDashPatternAt index: Int) -> [NSNumber]


```

<br> Bar chart  </b>
```swift 
    func numberOfItem(in barChart: BarChartView) -> Int
    func barChart(_ barChart: BarChartView, xValueAt index: Int) -> String
    func barChart(_ barChart: BarChartView, yValueAt index: Int) -> CGFloat
    func numberOfVerticalLines(in barChart: BarChartView) -> Int
    func numberOfVertical(in barChart: BarChartView, verticalViewAt index: Int) -> String
    
    @objc optional func barChart(_ barChart: BarChartView, verticalDashPatternAt index: Int) -> [NSNumber]
    @objc optional func barChart(_ barChart: BarChartView, horizontalDashPatternAt index: Int) -> [NSNumber]
``` 
### :bulb: Delegate 

<br> Line Chart </b>
```swift 

   @objc optional func lineChartDidStartRender(_ lineChart: LineChartView)
   @objc optional func lineChartDidFinishRender(_ lineChart: LineChartView)
   @objc optional func lineChartDidFailRender(_ lineChar: LineChartView)

```
<br> Bar Chart </b>
```swift 
    @objc optional func barChartDidStartRender(_ barChart: BarChartView)
    @objc optional func barChartDidFinishRender(_ barChart: BarChartView)
    @objc optional func barChartDidFailRender(_ barChart: BarChartView)
```
## Result 

<img src = "https://github.com/Nimol11/swiftLineChart/blob/main/image/Screenshot%202024-07-25%20at%208.49.53%20in%20the%20morning.png?raw=true" width= 400px />
<br> 
<img src = "https://github.com/Nimol11/video/blob/main/folder/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20Max%20-%202024-08-06%20at%2013.19.16.png?raw=true" width=400px />

