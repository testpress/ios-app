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

import Lottie
import PDFKit
import UIKit
import Alamofire
import RealmSwift
import MarqueeLabel


class AttachmentDetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var contentDescription: UILabel!
    @IBOutlet weak var downloadAttachmentButton: UIButton!
    @IBOutlet weak var viewAttachmentButton: UIButton!
    @IBOutlet weak var bookmarkOptionsLayout: UIView!
    @IBOutlet weak var moveBookmarkLayout: UIStackView!
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var removeBookmarkLayout: UIStackView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var bookmarkAnimationContainer: UIView!
    
    var content: Content!
    var bookmark: Bookmark!
    var position: Int!
    var loading: Bool = false
    var bookmarkHelper: BookmarkHelper!
    var contentAttemptCreationDelegate: ContentAttemptCreationDelegate?
    var animationView: LottieAnimationView!
    var moveAnimationView: LottieAnimationView!
    var removeAnimationView: LottieAnimationView!
    let alertController = UIUtils.initProgressDialog(message: Strings.LOADING + "\n\n")
    var timer: Timer?
    var watermarkLabel: MarqueeLabel?
    let cacheDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBookmarkHelper()
        showTitleAndDescription()
        addShadowToButtons()

        if (content.attachment?.isRenderable == true) {
            showViewButton()
        } else {
            showDownloadButton()
        }
    }
    
    func initializeBookmarkHelper() {
        bookmarkHelper = BookmarkHelper(viewController: self)
        bookmarkHelper.delegate = self
        bookmarkAnimationContainer.isHidden = true
        if Constants.BOOKMARKS_ENABLED {
            if bookmark == nil {
                animationView = initAnimationView()
                bookmarkAnimationContainer.addSubview(animationView)
                animationView.center.y = animationView.center.y - 5
                animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                bookmarkOptionsLayout.isHidden = true
                if content.bookmarkId.value != nil {
                    bookmarkButton.setTitle(Strings.REMOVE_BOOKMARK, for: .normal)
                    bookmarkButton.imageView?.image = #imageLiteral(resourceName: "remove_bookmark")
                }
            } else {
                moveAnimationView = initAnimationView()
                removeAnimationView = initAnimationView()
                moveAnimationView.isHidden = true
                removeAnimationView.isHidden = true
                moveBookmarkLayout.addSubview(moveAnimationView)
                removeBookmarkLayout.addSubview(removeAnimationView)
                moveAnimationView.center.y = moveAnimationView.center.y + 5
                removeAnimationView.center.y = removeAnimationView.center.y + 5
                bookmarkButton.isHidden = true
            }
        } else {
            bookmarkOptionsLayout.isHidden = true
            bookmarkButton.isHidden = true
        }
    }
    
    func showTitleAndDescription() {
        contentTitle.text = content.attachment!.title
        let attachment = content.attachment!
        if attachment.attachmentDescription != nil && attachment.attachmentDescription != "" {
            contentDescription.text = attachment.attachmentDescription
        } else {
            contentDescription.isHidden = true
        }
    }
    
    func addShadowToButtons() {
        UIUtils.setButtonDropShadow(viewAttachmentButton)
        UIUtils.setButtonDropShadow(downloadAttachmentButton)
    }
    
    func showViewButton() {
        viewAttachmentButton.isHidden = false
    }
    
    
    func showDownloadButton() {
        downloadAttachmentButton.isHidden = false
    }
    
    @IBAction func viewAttachment(_ sender: UIButton) {
        present(alertController, animated: false, completion: nil)
        
        var attachmentUrl = URL(string: content.attachment!.attachmentUrl)!
        if attachmentUrl.scheme == "http" {
            attachmentUrl = URL(string: "https://" + attachmentUrl.host! + attachmentUrl.path
                                + "?" + attachmentUrl.query!)!
        }
        
        // Check if PDF exists in cache directory
        let pdfFilePath = cacheDirectoryURL.appendingPathComponent(attachmentUrl.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: pdfFilePath.path) {
            alertController.dismiss(animated: true) {
                self.loadPdf(pdfFilePath)
            }
        } else {
            downloadPDF(from: attachmentUrl, to: pdfFilePath) {
                self.alertController.dismiss(animated: true) {
                    self.loadPdf(pdfFilePath)
                }
            }
        }
    }
    
    func downloadPDF(from url: URL, to destinationURL: URL, completion: @escaping () -> Void) {
        URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let location = location, error == nil else {
                print("Failed to download PDF: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    // Dismiss loading indicator if download fails
                    self.dismiss(animated: true) {
                        // Display an error message to the user
                        let alert = UIAlertController(title: "Error", message: "Failed to download PDF", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                return
            }
            
            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("Failed to move downloaded file to cache directory: \(error)")
            }
        }.resume()
    }
    
    
    func loadPdf(_ url: URL) {
        let pdfDocument = PDFDocument(url: url)
        if let pdfDocument = pdfDocument {
            let storyboard =
            UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
            let pdfViewController = storyboard.instantiateViewController(withIdentifier:
                                                                            Constants.PDF_VIEW_CONTROLLER) as! PDFViewController
            pdfViewController.pdfDocument = pdfDocument
            pdfViewController.contentTitle = content.attachment!.title
            let navigationController = UINavigationController(rootViewController: pdfViewController)
            navigationController.title = content.attachment!.title
            present(navigationController, animated: true)
            createContentAttempt()
        } else {
            print("Failed to load PDF from URL: \(url)")
            let alert = UIAlertController(title: "Error", message: "Failed to load PDF", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func back() {
        dismiss(animated: true, completion: nil)
    }
    
    private func startTimerToMoveWatermarkPosition() {
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(moveWatermarkPosition), userInfo: nil, repeats: true)
    }
    
    private func initializeWatermark(view: UIView) -> MarqueeLabel {
        let watermarkLabel = MarqueeLabel.init(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 20), duration: 8.0, fadeLength: 0.0)
        watermarkLabel.text = KeychainTokenItem.getAccount().padding(toLength: Int((view.frame.width)/2), withPad: " ", startingAt: 0)
        watermarkLabel.numberOfLines = 1
        return watermarkLabel
    }
    
    @objc func moveWatermarkPosition() {
        watermarkLabel?.frame.origin.y = CGFloat(Int.random(in: 0..<Int(self.view.frame.height)))
    }

    deinit {
        self.timer?.invalidate()
    }
    
    @IBAction func downloadAttachment(_ sender: UIButton) {
        var attachmentUrl = URL(string: content.attachment!.attachmentUrl)!
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
    
    @IBAction func moveBookmark() {
        bookmarkHelper.onClickMoveButton(bookmark: bookmark)
    }
    
    @IBAction func onRemoveBookmark() {
        bookmarkHelper.onClickRemoveButton(bookmark: bookmark)
    }
    
    @IBAction func bookmark(_ sender: UIButton) {
        bookmarkHelper.onClickBookmarkButton(bookmarkId: content?.bookmarkId.value)
    }
    
    func udpateBookmarkButtonState(bookmarkId: Int?) {
        content.bookmarkId = RealmOptional<Int>(bookmarkId)
        if bookmarkId != nil {
            bookmarkButton.setTitle(Strings.REMOVE_BOOKMARK, for: .normal)
            bookmarkButton.imageView?.image = #imageLiteral(resourceName: "remove_bookmark")
        } else {
            bookmarkButton.setTitle(Strings.BOOKMARK_THIS, for: .normal)
            bookmarkButton.imageView?.image = #imageLiteral(resourceName: "ic_bookmark")
        }
        bookmarkAnimationContainer.isHidden = true
        bookmarkButton.isHidden = false
    }
    
    func initAnimationView() -> LottieAnimationView {
        let animationView = LottieAnimationView(name: "material_wave_loading")
        animationView.contentMode = .scaleAspectFill
        animationView.frame.size.width = 50
        animationView.frame.size.height = 25
        let fillKeypath = AnimationKeypath(keypath: "**.Fill 1.Color")
        let valueProvider = ColorValueProvider(LottieColor(r: 1, g: 0.2, b: 0.3, a: 1))
        animationView.setValueProvider(valueProvider, keypath: fillKeypath)
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }
    
    override func viewDidLayoutSubviews() {
        // Set scroll view content height to support the scroll
        let height = contentStackView.frame.size.height
        contentViewHeightConstraint.constant = height
        scrollView.contentSize.height = height
        contentView.layoutIfNeeded()
    }
    
//    @objc func back() {
//        dismiss(animated: true, completion: nil)
//    }
    
}

extension AttachmentDetailViewController: BookmarkDelegate {
    func getBookMarkParams() -> Parameters? {
        var parameters: Parameters = Parameters()
        parameters["object_id"] = content.id
        parameters["content_type"] = ["model": "chaptercontent", "app_label": "courses"]
        return parameters
    }
    
    func updateBookmark(bookmarkId: Int?) {
        self.udpateBookmarkButtonState(bookmarkId: bookmarkId)
    }
    
    func onClickMoveButton() {
        self.moveButton.isHidden = true
        self.moveAnimationView.isHidden = false
    }
    
    func displayRemoveButton() {
        self.removeAnimationView.isHidden = true
        self.removeButton.isHidden = false
    }
    
    func onClickBookmarkButton() {
        self.bookmarkButton.isHidden = true
        self.bookmarkAnimationContainer.isHidden = false
    }
    
    func removeBookmark() {
        self.removeButton.isHidden = true
        self.removeAnimationView.isHidden = false
    }
    
    func displayBookmarkButton() {
        self.bookmarkAnimationContainer.isHidden = true
        self.bookmarkButton.isHidden = false
    }
    
    func displayMoveButton() {
        self.moveAnimationView.isHidden = true
        self.moveButton.isHidden = false
    }
    
}
