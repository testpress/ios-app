//
//  IndividualSubjectAnalyticsGraphCell.swift
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

import Charts
import UIKit

class IndividualSubjectAnalyticsGraphCell: UITableViewCell {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var correctCount: UILabel!
    @IBOutlet weak var incorrectCount: UILabel!
    @IBOutlet weak var skippedCount: UILabel!
    @IBOutlet weak var correctPercentage: UILabel!
    @IBOutlet weak var incorrectPercentage: UILabel!
    @IBOutlet weak var skippedPercentage: UILabel!
    @IBOutlet weak var chartView: PieChartView!
    
    func initCell(subject: Subject) {
        subjectLabel.text = subject.name
        correctCount.text = String(subject.correct)
        incorrectCount.text = String(subject.incorrect)
        skippedCount.text = String(subject.unanswered)
        correctPercentage.text = String(format:"%.0f", subject.percentage) + " %"
        incorrectPercentage.text = String(format:"%.0f", subject.incorrectPercentage) + " %"
        skippedPercentage.text = String(format:"%.0f", subject.unansweredPercentage) + " %"
        
        let data = getBarData(subject)
        chartView.data = data
        chartView.usePercentValuesEnabled = true
        chartView.highlightPerTapEnabled = false
        chartView.holeRadiusPercent = 0.48
        chartView.transparentCircleRadiusPercent = 0.51
        chartView.transparentCircleColor = UIColor.white
        chartView.chartDescription?.enabled = false
        chartView.setExtraOffsets(left: 0, top: 0, right: 0, bottom: 0);
        chartView.legend.enabled = false
    }
    
    func getBarData(_ subject: Subject) -> PieChartData {
        var entries = [PieChartDataEntry()]
            entries.append(PieChartDataEntry(value: subject.percentage, data: 0 as AnyObject))
            entries.append(PieChartDataEntry(value: subject.incorrectPercentage,
                                             data: 1 as AnyObject))
            entries.append(PieChartDataEntry(value: subject.unansweredPercentage,
                                             data: 2 as AnyObject))
        
        let dataSet = PieChartDataSet(values: entries, label: subject.name)
        dataSet.colors = [Colors.getRGB(Colors.MATERIAL_GREEN),
                          Colors.getRGB(Colors.MATERIAL_RED),
                          Colors.getRGB(Colors.ORANGE)]
        
        let data = PieChartData(dataSet: dataSet)
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setDrawValues(false)
        return data
    }
    
}
