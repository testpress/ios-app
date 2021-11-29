import Former

class ForumFilterViewController: FormViewController {
    var advancedFilters = [CustomCheckRowFormer<FormCheckCell>]()
    var sort = [CustomCheckRowFormer<FormCheckCell>]()
    var delegate: DiscussionFilterDelegate?
    var filters = [String: Any]()
    var categories = [Category]()
    let categoryPager = CategoryPager()
    let categoryPicker = InlinePickerRowFormer<FormInlinePickerCell, String>() {$0.titleLabel.text = "Choose Category"}

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
        displayNavigationBar()
        loadDiscussionCategories()
        let categorySection = initializeCategoryFilter()
        let filtersSection = initializeFilterSection()
        let dateFilterSection = initializeDateFilterSection()
        let sortSection = initializeSortSection()
        former.append(sectionFormer: categorySection, filtersSection,
                      dateFilterSection, sortSection)
    }
    
    
    func displayNavigationBar() {
        let width = self.view.frame.width
        let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: width, height: 45))
        self.view.addSubview(navigationBar);
        let navigationItem = UINavigationItem(title: "Filter Options")
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(done))
        navigationItem.rightBarButtonItem = doneBtn
        navigationBar.setItems([navigationItem], animated: false)
        tableView.contentInset.top = navigationBar.bounds.height + 10
    }
    
    func loadDiscussionCategories() {
        categoryPager.next(completion: { items, error in
            self.categories.append(contentsOf: Array(items!.values))
            if self.categoryPager.hasMore {
                self.loadDiscussionCategories()
            } else {
                self.categoryPicker.pickerItems.append(contentsOf: self.categories.map{InlinePickerItem(title: $0.name, value: String($0.id))})
                self.former.reload()
            }
        })
    }
    
    func initializeCategoryFilter() -> SectionFormer {
        categoryPicker.configure { row in
            row.pickerItems = [InlinePickerItem(
                title: "",
                displayTitle: NSAttributedString(string: "Not set"),
                value: "")]
                + self.categories.map { InlinePickerItem(title: $0.name) }
        }.onValueChanged { item in
            self.filters.updateValue(item.value!, forKey: "category")
        }
        return SectionFormer(rowFormer: categoryPicker)
            .set(headerViewFormer: self.createSectionHeader(title: "FILTER BY CATEGORY"))
    }
    
    func createSectionHeader(title: String) -> ViewFormer {
        return LabelViewFormer<FormLabelHeaderView>()
            .configure {
                $0.text = title
                $0.viewHeight = 50
            }
    }
    
    func initializeFilterSection() -> SectionFormer {
        let filters = [
            self.createFilter(name: "Posted by me", key: "posted_by_me"),
            self.createFilter(name: "Commented by me", key: "commented_by_me"),
            self.createFilter(name: "Upvoted by me", key: "upvoted_by_me")
        ]
        self.advancedFilters.append(contentsOf: filters)
        advancedFilters.forEach { row in
            row.onCheckChanged {value in
                if (value) {
                    self.filters.updateValue("true", forKey: row.key!)
                } else {
                    self.filters.removeValue(forKey: row.key!)
                }
                self.onFilterSelected(value: value, from: row, filters: self.advancedFilters)
            }
        }
        return SectionFormer(rowFormers: self.advancedFilters)
            .set(headerViewFormer: self.createSectionHeader(title:"FILTER BY"))
    }
    
    func initializeDateFilterSection() -> SectionFormer {
        let startDateRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Discussions From"
        }.inlineCellSetup {
            $0.datePicker.datePickerMode = .date
        }.displayTextFromDate{
            return String.mediumDateShortTime(date: $0)
        }.onDateChanged{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.filters.updateValue(formatter.string(from: $0), forKey: "posted_after")
        }
        
        let endDateRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Discussions Till"
        }.inlineCellSetup {
            $0.datePicker.datePickerMode = .date
        }.displayTextFromDate(String.mediumDateShortTime)
        .onDateChanged{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.filters.updateValue(formatter.string(from: $0), forKey: "posted_before")
        }
        return SectionFormer(rowFormer: startDateRow, endDateRow)
            .set(headerViewFormer: self.createSectionHeader(title: "FILTER BY DATE"))
    }
    
    func initializeSortSection() -> SectionFormer {
        let filters = [
            self.createFilter(name: "Recently added", key: "-created"),
            self.createFilter(name: "Old to New", key: "created"),
            self.createFilter(name: "Most Viewed", key: "-views_count"),
            self.createFilter(name: "Most Upvoted", key: "-upvoted")
        ]
        self.sort.append(contentsOf:filters)
        sort.forEach { row in
            row.onCheckChanged {value in
                self.filters.updateValue(row.key!, forKey: "sort")
                self.onFilterSelected(value: value, from: row, filters: self.sort)
            }
        }
        
        return SectionFormer(rowFormers: self.sort)
            .set(headerViewFormer: self.createSectionHeader(title:"Sort by"))
    }
    
    @objc func done() {
        self.delegate?.applyFilters(value: self.filters)
        self.dismiss(animated: true, completion: nil)
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
    
    func createFilter(name: String, key: String) -> CustomCheckRowFormer<FormCheckCell> {
        let row =  CustomCheckRowFormer<FormCheckCell>{
            $0.titleLabel.text = name
        }
        
        row.key = key
        return row
    }
}



class CustomCheckRowFormer<T: UITableViewCell>
: CheckRowFormer<T> where T: CheckFormableRow {
    var key: String?
    
    func showOrHideCheckIcon() {
        if let customCheckView = customCheckView {
            cell.accessoryView = customCheckView
            customCheckView.isHidden = checked ? false : true
        } else {
            cell.accessoryType = checked ? .checkmark : .none
        }
    }
}

protocol DiscussionFilterDelegate {
    func applyFilters(value: [String: Any])
}
