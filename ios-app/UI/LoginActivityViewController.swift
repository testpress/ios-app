//
//  LoginActivityViewController.swift
//  ios-app
//
//  Created by Karthik on 16/04/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import UIKit
import TTGSnackbar

class LoginActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutDevicesButton: UIButton!
    @IBOutlet weak var infoView: UIStackView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView! // Progress bar
    var emptyView: EmptyView!
    var items = [LoginActivity]()
    var pager: LoginActivityPager
    var loadingItems: Bool = false
    var firstCallBack: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        self.pager = LoginActivityPager()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        activityIndicator = UIUtils.initActivityIndicator(parentView: self.tableView)
        activityIndicator?.center = CGPoint(x: tableView.center.x, y: tableView.center.y)

        // Set table view footer as progress spinner
        let pagingSpinner = UIActivityIndicatorView(style: .gray)
        pagingSpinner.startAnimating()
        pagingSpinner.color = Colors.getRGB(Colors.PRIMARY)
        pagingSpinner.hidesWhenStopped = true
        tableView.tableFooterView = pagingSpinner
        
        // Set table view backgroud
        emptyView = EmptyView.getInstance()
        tableView.backgroundView = emptyView
        emptyView.frame = view.frame
        
        UIUtils.setTableViewSeperatorInset(tableView, size: 10)
        
        let instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
        infoView.isHidden = true
        infoLabel.isHidden = true

        if (instituteSettings.enableParallelLoginRestriction) {
            infoView.isHidden = false
            infoLabel.isHidden = false
            infoLabel.text = Strings.PARALLEL_LOGIN_RESTRICTION_INFO + "\(instituteSettings.maxParallelLogins) \n"
            infoView.addBackground(color: Colors.getRGB(Colors.BLACK_TEXT))
        }
        
    }
    
    func getNavBarHeight() -> CGFloat {
        return UINavigationController().navigationBar.frame.size.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()

        if (items.isEmpty) {
            activityIndicator?.startAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (items.isEmpty || firstCallBack) {
            firstCallBack = false
            tableView.tableFooterView?.isHidden = true
            pager.reset()
            loadItems()
        }
    }
    
    func loadItems() {
        if loadingItems {
            return
        }

        loadingItems = true
        pager.next(completion: {
            items, error in
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                self.handleError(error)
                return
            }
            
            self.items = Array(items!.values)

            if self.items.count == 0 {
                self.setEmptyText()
            }

            self.tableView.reloadData()

            if (self.activityIndicator?.isAnimating)! {
                self.activityIndicator?.stopAnimating()
            }

            self.tableView.tableFooterView?.isHidden = true
            self.loadingItems = false
        })
    }
    
    
    func setEmptyText() {
        emptyView.setValues(image: Images.LoginActivityIcon.image, title: "No data available")
    }
    
    func handleError(_ error: TPError) {
        var retryHandler: (() -> Void)?

        if error.kind == .network {
            retryHandler = {
                self.activityIndicator?.startAnimating()
                self.loadItems()
            }
        }

        let (image, title, description) = error.getDisplayInfo()

        if (activityIndicator?.isAnimating)! {
            activityIndicator?.stopAnimating()
        }
        loadingItems = false

        if items.count == 0 {
            emptyView.setValues(image: image, title: title, description: description, retryHandler: retryHandler)
        } else {
            TTGSnackbar(message: description, duration: .middle).show()
        }

        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count > 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }

        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewCell(cellForRowAt: indexPath)

        // Load more items on scroll to bottom
        if indexPath.row >= (items.count - 4) && !loadingItems {

            if pager.hasMore {
                tableView.tableFooterView?.isHidden = false
                loadItems()
            } else {
                tableView.tableFooterView?.isHidden = true
            }
        }
        return cell
    }
    
    func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoginActivityTableCell", for: indexPath) as! LoginActivityCell
        cell.ipAddress?.text = items[indexPath.row].ipAddress
        cell.deviceName?.text = items[indexPath.row].userAgent
        cell.lastUsedTime?.text = "Last Used : \(FormatDate.getElapsedTime(dateString: items[indexPath.row].lastUsed))"

        if items[indexPath.row].currentDevice {
            cell.lastUsedTime?.text = "Currently using"
        }

        return cell
    }

    @IBAction func logoutDevicesButtonClick(_ sender: UIButton) {
        activityIndicator?.startAnimating()
        TPApiClient.apiCall(endpointProvider: TPEndpointProvider(.logoutDevices), completion: {
            _,error in

            if let error = error {
                self.activityIndicator?.stopAnimating()
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                let (_, _, description) = error.getDisplayInfo()
                TTGSnackbar(message: description, duration: .middle).show()
                return
            }

            self.items.removeAll()
            self.pager.reset()
            self.loadItems()
        })
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
