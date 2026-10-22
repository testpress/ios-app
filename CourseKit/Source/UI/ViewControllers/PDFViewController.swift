import UIKit
import PDFKit
import MarqueeLabel


class PDFViewController: BaseUIViewController {
    var pdfDocument: PDFDocument?
    @IBOutlet var pdfView: PDFView!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var navigationBar: UINavigationBar!  // Connect in storyboard to the navigation bar
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerScreenCaptureObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterScreenCaptureObserver()
    }
    
    func setupSecurePDFView() {
        guard let pdfView = pdfView, secureContainerView == nil else { return }
        
        // Use IBOutlet navBar if connected; if nil, layout safely falls back to view.safeAreaLayoutGuide
        let navBar = self.navigationBar
        
        // CRITICAL: navBar's leading/trailing constraints in storyboard reference pdfView.
        // Before removing pdfView, deactivate any existing top/leading/trailing/left/right constraints from view.constraints
        // that anchor navBar, then pin navBar to safeArea so it stays positioned correctly without duplicate constraint warnings.
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
        
        // Now safe to remove pdfView (deactivates its old constraints including those referencing navBar)
        pdfView.removeFromSuperview()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        // Wrap pdfView in SecureContainerView
        let container = SecureContainerView(contentView: pdfView)
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        // Compute top anchor based on navBar presence
        let topAnchor = navBar?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor
        
        // Single merged path: constrain container below navBar (or safeArea top), filling remaining safeArea
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
    
    func registerScreenCaptureObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureDidChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
        handleScreenCapture(isCaptured: UIScreen.main.isCaptured)
    }
    
    func unregisterScreenCaptureObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }
    
    @objc func screenCaptureDidChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.handleScreenCapture(isCaptured: UIScreen.main.isCaptured)
        }
    }
    
    func handleScreenCapture(isCaptured: Bool) {
        secureContainerView?.handleScreenCapture(isCaptured: isCaptured)
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
        unregisterScreenCaptureObserver()
    }
    
}
