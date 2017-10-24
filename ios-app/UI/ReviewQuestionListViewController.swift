//
//  ReviewQuestionListViewController.swift
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

class ReviewQuestionListViewController: BaseQuestionsListViewController {
    
    override func getIndexBorderColor(attemptItem: AttemptItem) -> String {
        var color: String = Colors.GRAY_LIGHT_DARK
        if !(attemptItem.selectedAnswers.isEmpty) {
            color = Colors.MATERIAL_GREEN;
            // If question is attempted & any of the selected option is incorrect then set red color
            for attemptAnswer in (attemptItem.question?.answers)! {
                if attemptItem.selectedAnswers.contains(attemptAnswer.id!) &&
                    !(attemptAnswer.isCorrect!) {
                        color = Colors.MATERIAL_RED
                }
            }
        }
        return color
    }
    
}
