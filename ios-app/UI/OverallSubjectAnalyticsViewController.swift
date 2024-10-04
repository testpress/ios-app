//
//  OverallSubjectAnalyticsViewController.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import DGCharts
import UIKit
import XLPagerTabStrip
import CourseKit

class OverallSubjectAnalyticsViewController: UIViewController {
    
    @IBOutlet weak var chartView: HorizontalBarChartView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var chartViewHeightConstraint: NSLayoutConstraint!
    
    var subjects = [Subject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !subjects.isEmpty {
            populateChart(chart: chartView, sets: getDataForAllAnswers(), allSubjects: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func getDataForAllAnswers() -> [BarChartDataSet] {
        var entries = [BarChartDataEntry]()
        for i in 1...subjects.count {
            let subject = subjects[i - 1]
            
            let entry = BarChartDataEntry(x: Double(i), yValues:
                [subject.percentage, subject.incorrectPercentage, subject.unansweredPercentage])
            
            entries.append(entry)
        }
        let barDataSet = BarChartDataSet(entries: entries, label: "")
        barDataSet.colors = [Colors.getRGB(Colors.MATERIAL_GREEN),
                             Colors.getRGB(Colors.MATERIAL_RED),
                             Colors.getRGB(Colors.ORANGE)]
        
        return [barDataSet]
    }
    
    func populateChart(chart: HorizontalBarChartView, sets: [BarChartDataSet], allSubjects: Bool) {
        let data = BarChartData(dataSets: sets)
        data.barWidth = 0.4
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont(name: "Rubik-Medium", size: 13)!
        xAxis.labelCount = subjects.count + 2
        xAxis.drawGridLinesEnabled = false
        var labels = [String]()
        labels.append("")
        for subject in subjects {
            labels.append(subject.name)
        }
        labels.append("")
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.xOffset = 10
        xAxis.labelTextColor = Colors.getRGB(Colors.BLACK_TEXT)
        xAxis.valueFormatter = GraphAxisLabelFormatter(values: labels, interval: 1)
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = Double(subjects.count + 1)
        xAxis.granularity = 1
        xAxis.axisLineColor = Colors.getRGB(Colors.GRAY_LIGHT_DARK)
        chartViewHeightConstraint.constant = CGFloat(max(200, (subjects.count + 2) * 50))
        
        let leftAxis = chart.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 100
        leftAxis.spaceTop = 15
        
        let rightAxis = chart.rightAxis;
        rightAxis.axisMinimum = 0
        rightAxis.axisMaximum = 100
        
        if allSubjects {
            data.setValueFont(UIFont(name: "Rubik-Medium", size: 10)!)
            let pFormatter = GraphAxisPercentValueFormatter()
            pFormatter.numberStyle = .percent
            pFormatter.percentSymbol = " %"
            pFormatter.multiplier = 1
            data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            xAxis.drawAxisLineEnabled = false
            rightAxis.drawLabelsEnabled = false
            rightAxis.drawAxisLineEnabled = false
            rightAxis.drawGridLinesEnabled = false
            chart.drawValueAboveBarEnabled = false
            chart.setExtraOffsets(left: 0, top: 0, right: 10, bottom: 0)
        }
        
        chart.data = data
        chartView.chartDescription.enabled = false
        chart.fitBars = true
        chart.legend.enabled = false
        chart.setScaleEnabled(false)
        chart.animate(yAxisDuration: 0.5)
        DispatchQueue.main.async {
            self.chartView.setNeedsDisplay()
            self.viewDidLayoutSubviews()
        }
    }
    
    // Set frames of the views in this method to support both portrait & landscape view
    override func viewDidLayoutSubviews() {
        // Set scroll view content height to support the scroll
        scrollView.contentSize.height = contentStackView.frame.size.height
    }
    
}

extension OverallSubjectAnalyticsViewController: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: Strings.OVERALL_SUBJECTS_ANALYTICS)
    }
}
