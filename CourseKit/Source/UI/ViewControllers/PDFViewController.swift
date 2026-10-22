import UIKit
import PDFKit
import MarqueeLabel


class PDFViewController: BaseUIViewController {
    var pdfDocument: PDFDocument?
    @IBOutlet var pdfView: PDFView!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var watermarkLabel: MarqueeLabel?
    var timer: Timer?
    var contentTitle: String!
    var secureContainerView: SecureContainerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
        setupPDFView()
        setupSecurePDFView()
        addWaterMark()
    }
    
    func setupSecurePDFView() {
        guard let pdfView = pdfView, secureContainerView == nil else { return }
        
        let navBar = self.navigationBar ?? view.subviews.first(where: { $0 is UINavigationBar }) as? UINavigationBar
        
        if let navBar = navBar {
            let constraintsToRemove = view.constraints.filter { constraint in
                let involvesNavBar = (constraint.firstItem as? UIView === navBar) || (constraint.secondItem as? UIView === navBar)
                guard involvesNavBar else { return false }
                let attr = (constraint.firstItem as? UIView === navBar) ? constraint.firstAttribute : constraint.secondAttribute
                return attr == .top || attr == .leading || attr == .trailing || attr == .left || attr == .right
            }
            NSLayoutConstraint.deactivate(constraintsToRemove)
            
            navBar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        }
        
        pdfView.removeFromSuperview()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        let container = SecureContainerView(contentView: pdfView)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        if let navBar = navBar {
            view.insertSubview(container, belowSubview: navBar)
            view.bringSubviewToFront(navBar)
        } else {
            view.addSubview(container)
        }
        
        let topAnchor = navBar?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        container.setNeedsLayout()
        container.layoutIfNeeded()
        self.secureContainerView = container
    }
    
    func setupPDFView() {
        pdfView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.minScaleFactor = 0.5
        pdfView.maxScaleFactor = 5.0
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        
        navigationBarItem.title = contentTitle
    }
    
    func addWaterMark() {
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
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    deinit {
        self.timer?.invalidate()
    }
    
}
