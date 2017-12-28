//
//  PostCreationViewController.swift
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

import Alamofire
import TTGSnackbar
import UIKit

class PostCreationViewController: BaseTextFieldViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var contentViewHeightConstraint: KeyboardLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var postTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postTitle: RichTextEditor!
    @IBOutlet weak var postContentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postContent: RichTextEditor!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var pickTopicLayout: UIStackView!
    @IBOutlet weak var publishButton: UIButton!
    
    var categories = [Category]()
    var postCreated: Bool = false
    var parentTableViewController: TPBasePagedTableViewController<Post>!
    var activityIndicator: UIActivityIndicatorView!
    var emptyView: EmptyView!
    let loadingDialogController = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        postTitle.delegate = self
        postTitle.defaultHeight = 35
        postContent.delegate = self
        postContent.defaultHeight = 100
        categoryPickerView.selectRow(1, inComponent: 0, animated: false)
        emptyView = EmptyView.getInstance(parentView: contentView)
        activityIndicator = UIUtils.initActivityIndicator(parentView: scrollView)
        activityIndicator.frame = view.frame
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        UIUtils.setButtonDropShadow(publishButton)
        fetchCategory()
    }
    
    func fetchCategory() {
        activityIndicator.startAnimating()
        let endpoint = TPEndpointProvider(.getForumCategories)
        TPApiClient.getListItems(endpointProvider: endpoint, completion: { response, error in
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                var retryHandler: (() -> Void)?
                if error.kind == .network {
                    retryHandler = {
                        self.emptyView.hide()
                        self.fetchCategory()
                    }
                }
                if (self.activityIndicator?.isAnimating)! {
                    self.activityIndicator?.stopAnimating()
                }
                let (image, title, description) = error.getDisplayInfo()
                self.emptyView.show(image: image, title: title, description: description,
                                    retryHandler: retryHandler)
                return
            }
            
            self.categories = response!.results
            self.activityIndicator.stopAnimating()
            self.categoryPickerView.reloadAllComponents()
            if !self.categories.isEmpty {
                let selectedComponent = (self.categoryPickerView.numberOfComponents / 2) + 1
                self.categoryPickerView.selectRow(
                    selectedComponent,
                    inComponent: 0,
                    animated: false
                )
            } else {
                self.categoryPickerView.isHidden = true
            }
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }, type: Category.self)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.font = UIFont (name: "Rubik", size: 14)
        if categories.count > row {
            label.text =  categories[row].name
        } else {
            label.text = ""
        }
        label.textAlignment = .center
        return label
    }
    
    @IBAction func publishPost(_ sender: Any) {
        view.endEditing(true)
        let title: String! = postTitle.text
        let content: String! = postContent.text
        let selectedCategoryPostion = categoryPickerView.selectedRow(inComponent: 0)
        var category: String = "null"
        if selectedCategoryPostion != -1 {
            category = categories[selectedCategoryPostion].slug
        }
        if title == nil || title.elementsEqual("") || content == nil || content.elementsEqual("") {
            return
        }
        present(loadingDialogController, animated: true)
        let endpoint = TPEndpointProvider(.createForumPost)
        let parameters: Parameters = ["title": title, "content_html": content, "category": category]
        TPApiClient.request(type: Post.self, endpointProvider: endpoint, parameters: parameters,
            completion: { post, error in
                
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    self.loadingDialogController.dismiss(animated: false)
                    let (_, title, _) = error.getDisplayInfo()
                    TTGSnackbar(message: title, duration: .middle).show()
                    return
                }
                
                self.postTitle.text = ""
                self.postContent.text = ""
                self.loadingDialogController.dismiss(animated: false)
                self.postCreated = true
                self.emptyView.show(
                    image: Images.SuccessTick.image,
                    title: Strings.YOU_MADE_IT,
                    description: Strings.POST_CREATED_DESCRIPTION,
                    retryButtonText: Strings.OK,
                    retryHandler: self.back
                )
        })
    }
    
    override func viewDidLayoutSubviews() {
        // Set scroll view content height to support the scroll
        let height =
            contentStackView.frame.size.height + contentViewHeightConstraint.keyboardVisibleHeight
        
        contentViewHeightConstraint.constant = height
        scrollView.contentSize.height = height
        contentView.layoutIfNeeded()
    }
    
    @IBAction func back() {
        if postCreated {
            parentTableViewController.items.removeAll()
        }
        parentTableViewController.dismiss(animated: false, completion: nil)
    }
    
}

extension PostCreationViewController: RichTextEditorDelegate {
    
    func heightDidChange(_ editor: RichTextEditor, heightDidChange height: CGFloat) {
        if editor == postTitle {
            postTitleHeightConstraint.constant = height + 25.5
        } else {
            postContentHeightConstraint.constant = height + 25.5
        }
        viewDidLayoutSubviews()
    }
}
