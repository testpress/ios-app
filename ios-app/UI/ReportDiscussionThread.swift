
import Former
import TTGSnackbar
import ToastSwiftFramework

class ReportDiscussionThreadViewController: FormViewController {
    var discussionSlug: String!
    var options = [CustomCheckRowFormer<FormCheckCell>]()
    let reasonTextView = TextViewRowFormer<FormTextViewCell>().configure{
        $0.placeholder = "Please enter the reason"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
        displayNavigationBar()
        let reasonsSection = initializeReasons()
        let submitButtonSection = initializeSubmitButton()
        former.append(sectionFormer: reasonsSection, submitButtonSection)
    }
    
    func displayNavigationBar() {
        let width = self.view.frame.width
        let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: width, height: 45))
        self.view.addSubview(navigationBar);
        let navigationItem = UINavigationItem(title: "Report discussion")
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(done))
        doneBtn.title = "Cancel"
        navigationItem.rightBarButtonItem = doneBtn
        navigationBar.setItems([navigationItem], animated: false)
        tableView.contentInset.top = navigationBar.bounds.height + 10
    }
    
    func initializeReasons() -> SectionFormer {
        let filters = [
            self.createFilter(name: "Graphic violence", key: "Graphic violence"),
            self.createFilter(name: "Hateful or abusive content", key: "Hateful or abusive content"),
            self.createFilter(name: "Off-Topic", key: "Off-Topic"),
            self.createFilter(name: "Inappropriate", key: "Inappropriate"),
            self.createFilter(name: "Spam", key: "Spam"),
            self.createFilter(name: "Something else", key: "reason")
        ]
        self.options.append(contentsOf: filters)
        let sections = SectionFormer(rowFormers: self.options)
        self.options.forEach { row in
            row.onCheckChanged {value in
                if (row.key == "reason" && value) {
                    self.insertSection(relate: sections)(true)
                    self.reasonTextView.text = nil
                    self.former.reload(rowFormer: self.reasonTextView)
                } else {
                    self.insertSection(relate: sections)(false)
                    self.reasonTextView.text = row.key
                }
                self.onFilterSelected(value: value, from: row, filters: self.options)
            }
        }
        return sections
    }
    
    func createFilter(name: String, key: String) -> CustomCheckRowFormer<FormCheckCell> {
        let row =  CustomCheckRowFormer<FormCheckCell>{
            $0.titleLabel.text = name
        }
        
        row.key = key
        return row
    }
    
    func onFilterSelected(value: Bool, from: CustomCheckRowFormer<FormCheckCell>, filters: [CustomCheckRowFormer<FormCheckCell>]) {
        
        if (value) {
            filters.forEach { row in
                row.checked = false
                row.showOrHideCheckIcon()
            }
            from.checked = true
            from.showOrHideCheckIcon()
        }
    }
    
    func initializeSubmitButton() -> SectionFormer {
        let submitButton = LabelRowFormer<CenterLabelCell>()
            .configure {
                $0.text = "Submit"
            }
        submitButton.onSelected {[weak self] _ in
            if (self?.reasonTextView.text == nil) {
                TTGSnackbar(message: "You have not selected any reason", duration: .middle).show()
            } else {
                TTGSnackbar(message: (self?.reasonTextView.text!)!, duration: .middle).show()
            }
        }

        return SectionFormer(rowFormer: submitButton)
        
    }
    
    private lazy var subSectionFormer: SectionFormer = {
        return SectionFormer(rowFormers: [reasonTextView])
    }()
        
    private func insertSection(relate: SectionFormer) -> (Bool) -> Void {
        return { [weak self] insert in
            guard let `self` = self else { return }
            if insert {
            self.former.insertUpdate(sectionFormers: [self.subSectionFormer], below: relate, rowAnimation: UITableView.RowAnimation.fade)
            } else {
                self.former.removeUpdate(sectionFormers: [self.subSectionFormer], rowAnimation: UITableView.RowAnimation.fade)
            }
        }
    }
    
    func reportDiscussion(reason: String) {
        TPApiClient.apiCall(endpointProvider: TPEndpointProvider(.logoutDevices), completion: {
            _,error in

            if let error = error {

                return
            }
        })
    }
    
    @objc func done() {
        self.dismiss(animated: true, completion: nil)
    }
}



final class CenterLabelCell: FormCell, LabelFormableRow {
    func formTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }
    
    weak var titleLabel: UILabel!
    
    override func setup() {
        super.setup()
        self.backgroundColor = Colors.getRGB(Colors.PRIMARY)
        
        let titleLabel = UILabel()
        titleLabel.textColor = Colors.getRGB(Colors.PRIMARY_TEXT)
        titleLabel.font = .boldSystemFont(ofSize: 15)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        let constraints = [
          NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[titleLabel]-0-|",
                options: [],
                metrics: nil,
                views: ["titleLabel": titleLabel]
            ),
            NSLayoutConstraint.constraints(
              withVisualFormat: "H:|-0-[titleLabel]-0-|",
                options: [],
                metrics: nil,
                views: ["titleLabel": titleLabel]
            )
            ].flatMap { $0 }
        contentView.addConstraints(constraints)
    }
}
