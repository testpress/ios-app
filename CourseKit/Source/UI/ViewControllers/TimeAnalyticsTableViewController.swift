//
//  TimeAnalyticsTableViewController.swift
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

import LUExpandableTableView
import UIKit
import WebKit

class TimeAnalyticsTableViewController: UIViewController {
    
    @IBOutlet var tableView: LUExpandableTableView!
    @IBOutlet weak var contentView: UIView!
    
    var attempt: Attempt!
    var attemptItems = [AttemptItem]()
    var showingProgress: Bool = false
    var emptyView: EmptyView!
    let loadingDialogController = UIUtils.initProgressDialog(message:
        Strings.LOADING_QUESTIONS + "\n\n")
    
    var webViewHeight: [CGFloat]!
    var selectedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        self.setStatusBarColor()
        emptyView = EmptyView.getInstance(parentView: contentView)
        emptyView.parentView = view
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.reloadData()
        tableView.expandableTableViewDataSource = self
        tableView.expandableTableViewDelegate = self
        tableView.sectionFooterHeight = 2.0;
        UIUtils.setTableViewSeperatorInset(tableView, size: 0)
        tableView.register(
            UINib(nibName: Constants.TIME_ANALYTICS_HEADER_VIEW_CELL, bundle: Bundle.main),
            forHeaderFooterViewReuseIdentifier: Constants.TIME_ANALYTICS_HEADER_VIEW_CELL
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        present(loadingDialogController, animated: false, completion: nil)
        loadQuestions(url: attempt.reviewUrl!)
    }
    
    func loadQuestions(url: String) {
        TPApiClient.getQuestions(
            endpointProvider: TPEndpointProvider(.getQuestions, url: url),
            completion: {
                testpressResponse, error in
                if let error = error {
                    debugPrint(error.message ?? "No error message found")
                    debugPrint(error.kind)
                    self.loadingDialogController.dismiss(animated: true, completion: {
                        var retryHandler: (() -> Void)?
                        if error.kind == .network {
                            retryHandler = {
                                self.emptyView.hide()
                                self.present(self.loadingDialogController, animated: false)
                                self.loadQuestions(url: url)
                            }
                        }
                        let (image, title, description) = error.getDisplayInfo()
                        self.emptyView.show(image: image, title: title, description: description,
                                            retryHandler: retryHandler)
                    })
                    return
                }
                self.attemptItems.append(contentsOf: testpressResponse!.results)
                if !(testpressResponse!.next.isEmpty) {
                    self.loadQuestions(url: testpressResponse!.next)
                } else {
                    if self.attemptItems.isEmpty {
                        // Handled empty questions
                        self.loadingDialogController.dismiss(animated: true, completion: {
                            UIUtils.showSimpleAlert(
                                title: Strings.NO_QUESTIONS,
                                message: Strings.NO_QUESTIONS_DESCRIPTION,
                                viewController: self,
                                completion: { action in
                                    self.back()
                            })
                        })
                        return
                    }
                    self.webViewHeight = [CGFloat](repeating: 0, count: self.attemptItems.count)
                    self.loadingDialogController.dismiss(animated: false, completion: nil)
                    self.tableView.reloadData()
                }
        })
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension TimeAnalyticsTableViewController: LUExpandableTableViewDataSource {
    
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        return attemptItems.count
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView,
                             numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView,
                             cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if attemptItems.count <= indexPath.section {
            // Needed to prevent index out of bound execption when dismiss view controller while
            // table view is scrolling
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.TIME_ANALYTICS_QUESTION_CELL, for: indexPath)
            as! TimeAnalyticsQuestionCell

        let attemptItem = attemptItems[indexPath.section]
        cell.initCell(attemptItem: attemptItem, parentViewController: self)
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection
        section: Int) -> LUExpandableTableViewSectionHeader {
        
        if attemptItems.count <= section {
            // Needed to prevent index out of bound execption when dismiss view controller while
            // table view is scrolling
            return LUExpandableTableViewSectionHeader()
        }
        let cell = expandableTableView.dequeueReusableHeaderFooterView(
            withIdentifier: Constants.TIME_ANALYTICS_HEADER_VIEW_CELL)
            as! TimeAnalyticsHeaderViewCell
        
        let attemptItem = attemptItems[section]
        if attemptItem.index == nil {
            attemptItem.index = section + 1
        }
        cell.initCell(attemptItem: attemptItem, parentViewController: self)
        return cell
    }
    
}

extension TimeAnalyticsTableViewController: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView,
                             heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return webViewHeight[indexPath.section]
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView,
                             heightForHeaderInSection section: Int) -> CGFloat {
        
        return UITableView.automaticDimension
    }
}

extension TimeAnalyticsTableViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        
        if (message.name == "callbackHandler") {
            let body = message.body
            if let dict = body as? Dictionary<String, AnyObject> {
                let index = dict["index"] as! Int
                webViewHeight[index] = dict["height"] as! CGFloat + 20
                tableView.expandSections(at: [index])
                tableView.beginUpdates()
                let indexPath = IndexPath(item: 0, section: index)
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
    }
}

extension TimeAnalyticsTableViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(getJavascript(webView)) { (result, error) in
            if error != nil {
                debugPrint(error ?? "no error")
            }
        }
    }
    
    func getJavascript(_ webView: WKWebView) -> String {
        var js: String = ""
        if webViewHeight[webView.tag] == 0.0 {
            js += "var message = {'height': document.body.offsetHeight, 'index': \(webView.tag)};"
            js += "webkit.messageHandlers.callbackHandler.postMessage(message);"
        }
        do {
            return js
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        return ""
    }
    
}
