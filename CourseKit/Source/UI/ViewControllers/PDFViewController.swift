import UIKit
import PDFKit
import MarqueeLabel


class PDFViewController: BaseUIViewController {
    var pdfDocument: PDFDocument?
    @IBOutlet var pdfView: PDFView!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
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
        
        // Find navBar from storyboard
        guard let navBar = view.subviews.first(where: { $0 is UINavigationBar }) as? UINavigationBar else {
            // No navBar - constrain to safeArea directly
            setupContainerWithoutNavBar(pdfView: pdfView)
            return
        }
        
        // CRITICAL: navBar's leading/trailing constraints in storyboard reference pdfView.
        // Before removing pdfView, pin navBar to safeArea so it stays positioned correctly.
        navBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        // Now safe to remove pdfView (deactivates its old constraints including those referencing navBar)
        pdfView.removeFromSuperview()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        // Wrap pdfView in SecureContainerView
        let container = SecureContainerView(contentView: pdfView)
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        // Constrain container below navBar, filling remaining safeArea
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        container.setNeedsLayout()
        container.layoutIfNeeded()
        self.secureContainerView = container
    }
    
    private func setupContainerWithoutNavBar(pdfView: PDFView) {
        pdfView.removeFromSuperview()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        let container = SecureContainerView(contentView: pdfView)
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
