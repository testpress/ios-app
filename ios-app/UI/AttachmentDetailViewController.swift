//
//  AttachmentDetailViewController.swift
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

import PDFReader
import UIKit

class AttachmentDetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var contentDescription: UILabel!
    @IBOutlet weak var downloadAttachmentButton: UIButton!
    @IBOutlet weak var viewAttachmentButton: UIButton!
    
    var content: Content!
    var attachmentUrl: URL!
    var loading: Bool = false
    var contentAttemptCreationDelegate: ContentAttemptCreationDelegate?
    let alertController = UIUtils.initProgressDialog(message: Strings.LOADING + "\n\n")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtils.setButtonDropShadow(downloadAttachmentButton)
        displayAttachment()
    }
    
    func displayAttachment() {
        contentTitle.text = content.attachment!.title
        let attachment = content.attachment!
        if attachment.description != nil && attachment.description != "" {
            contentDescription.text = attachment.description
        } else {
            contentDescription.isHidden = true
        }
        attachmentUrl = URL(string: content.attachment!.attachmentUrl!)!
        if attachmentUrl.pathExtension != "pdf" {
            viewAttachmentButton.isHidden = true
        } else {
            UIUtils.setButtonDropShadow(viewAttachmentButton)
            viewAttachmentButton.isHidden = false
        }
    }
    
    @IBAction func viewAttachment(_ sender: UIButton) {
        if attachmentUrl.scheme == "http" {
            attachmentUrl = URL(string: "https://" + attachmentUrl.host! + attachmentUrl.path
                + "?" + attachmentUrl.query!)
        }
        present(alertController, animated: false, completion: {
            self.loadPdf()
        })
    }
    
    func loadPdf() {
        let pdfDocument = PDFDocument(url: attachmentUrl!)
        alertController.dismiss(animated: false, completion: {
            self.displayPdf(pdfDocument)
        })
    }
    
    func displayPdf(_ pdfDocument: PDFDocument?) {
        if pdfDocument != nil {
            let backButton = UIBarButtonItem(title: "Back", style: .done, target: self,
                                             action:  #selector(back))
            
            let pdfController = PDFViewController.createNew(with: pdfDocument!,
                                                            title: content.attachment!.title,
                                                            backButton: backButton)
            
            pdfController.navigationItem.rightBarButtonItem = nil
            let navigationController =
                UINavigationController(rootViewController: pdfController)
            
            present(navigationController, animated: true)
            createContentAttempt()
        }
    }
    
    @IBAction func downloadAttachment(_ sender: UIButton) {
        UIApplication.shared.openURL(attachmentUrl)
        createContentAttempt()
    }
    
    func createContentAttempt() {
        TPApiClient.request(
            type: ContentAttempt.self,
            endpointProvider: TPEndpointProvider(.post, url: content.attemptsUrl),
            completion: {
                contentAttempt, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    return
                }
                
                if self.content.attemptsCount == 0 {
                    self.contentAttemptCreationDelegate?.newAttemptCreated()
                }
        })
    }
    
    override func viewDidLayoutSubviews() {
        // Set scroll view content height to support the scroll
        scrollView.contentSize.height = contentView.frame.size.height
    }
    
    @objc func back() {
        dismiss(animated: true, completion: nil)
    }
    
}
