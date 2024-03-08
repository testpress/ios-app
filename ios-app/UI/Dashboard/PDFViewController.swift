import UIKit
import PDFKit
import MarqueeLabel


class PDFViewController: UIViewController {
    var pdfDocument: PDFDocument?
    @IBOutlet var pdfView: PDFView!
    private var currentPageIndex = 0
    var watermarkLabel: MarqueeLabel?
    var timer: Timer?
    var contentTitle: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPDFView()
        addPanGesture()
        watermarkLabel = initializeWatermark(view: view)
        view.addSubview(watermarkLabel!)
        startTimerToMoveWatermarkPosition()
    }

    private func initializeWatermark(view: UIView) -> MarqueeLabel {
        let watermarkLabel = MarqueeLabel.init(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 20), duration: 8.0, fadeLength: 0.0)
        watermarkLabel.text = KeychainTokenItem.getAccount().padding(toLength: Int((view.frame.width)/2), withPad: " ", startingAt: 0)
        watermarkLabel.numberOfLines = 1
        return watermarkLabel
    }

    private func startTimerToMoveWatermarkPosition() {
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(moveWatermarkPosition), userInfo: nil, repeats: true)
    }

    @objc func moveWatermarkPosition() {
        watermarkLabel?.frame.origin.y = CGFloat(Int.random(in: 0..<Int(self.view.frame.height)))
    }

    func setupPDFView() {
        pdfView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.minScaleFactor = 0.5
        pdfView.maxScaleFactor = 5.0
        pdfView.autoScales = true
        pdfView.document = pdfDocument
                   
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
        navigationItem.title = contentTitle
    }

    @objc func back(_ sender: Any) {
        dismiss(animated: true)
    }

    func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        pdfView.addGestureRecognizer(panGesture)
    }

    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let pdfDocument = pdfDocument else {
            return
        }
        
        guard recognizer.state == .ended else { return }

        let translation = recognizer.translation(in: pdfView)
        let velocity = recognizer.velocity(in: pdfView)

        if translation.x < -50 && velocity.x < -500 && currentPageIndex < pdfDocument.pageCount {
            print(pdfView.scaleFactor)
            // Swipe left
            currentPageIndex += 1
            if let nextPage = pdfDocument.page(at: currentPageIndex) {
                pdfView.go(to: nextPage)
            }
        } else if translation.x > 50 && velocity.x > 500 && currentPageIndex > 0 {
            // Swipe right
            currentPageIndex -= 1
            if let prevPage = pdfDocument.page(at: currentPageIndex) {
                pdfView.go(to: prevPage)
            }
        }
    }

}

