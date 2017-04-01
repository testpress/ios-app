//
//  TPBasePagedTableViewController.swift
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

import UIKit
import ObjectMapper
import XLPagerTabStrip

class TPBasePagedTableViewController<T: Mappable>: UITableViewController {
    
    var activityIndicator: UIActivityIndicatorView?
    var items = [T]()
    let pager: TPBasePager<T>
    var loading: Bool = false
    
    init(pager: TPBasePager<T>) {
        self.pager = pager
        super.init(style: .plain)
        activityIndicator = UIUtils.initActivityIndicator(parentView: self.view)
        activityIndicator?.center = CGPoint(x: view.center.x, y: view.center.y - 150)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        pagingSpinner.startAnimating()
        pagingSpinner.color = Colors.getRGB(Colors.PRIMARY)
        pagingSpinner.hidesWhenStopped = true
        tableView.tableFooterView = pagingSpinner
        tableView.tableFooterView?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (items.isEmpty) {
            activityIndicator?.startAnimating()
            loadItems()
        }
    }
    
    func loadItems() {
        loading = true
        pager.next(completion: {
            items, error in
            if let error = error {
                print(error.message ?? "No error")
                print(error.kind)
                self.handleError(error)
                return
            }
            
            self.items = Array(items!.values)
            self.tableView.reloadData()
            if (self.activityIndicator?.isAnimating)! {
                self.activityIndicator?.stopAnimating()
            }
            self.tableView.tableFooterView?.isHidden = true
            self.loading = false
        })
    }
    
    func handleError(_ error: TPError) {
        switch (error.kind) {
        case .network:
            print("Internet Unavailable")
        case .unauthenticated:
            print("Authorization Required")
        case .http:
            print("HTTP error occured")
        default:
            print("Unexpected")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewCell(cellForRowAt: indexPath)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        cell.layoutMargins = UIEdgeInsets.zero;
        
        if indexPath.row >= (items.count - 4) && !loading {
            if self.pager.hasMore {
                loading = true
                tableView.tableFooterView?.isHidden = false
                self.loadItems()
            } else {
                tableView.tableFooterView?.isHidden = true
            }
        }
        
        return cell
    }
    
    func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
