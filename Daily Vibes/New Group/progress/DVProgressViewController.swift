//
//  DVProgressViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2018-01-19.
//  Copyright © 2018 Alex Kluew. All rights reserved.
//

import UIKit
import Charts
import SwiftTheme

class DVProgressViewController: ThemableViewController {
    
    @IBOutlet private weak var performanceTableView: UITableView!
    @IBOutlet private weak var tagsTableView: UITableView!
    @IBOutlet private weak var barChartView: BarChartView!
    
    private var store = CoreDataManager.store
//    private var tags = [Tag]()
    
    private var dvTagsVM = [DVTagViewModel]() {
        didSet {
            self.tagsTableView.reloadData()
        }
    }
    
    private var streaks = [Streak]() {
        didSet {
            if let firstStreak = streaks.first {
                numDaysInARow = Int(firstStreak.currentDaysInARow)
                recordDaysInARow = Int(firstStreak.recordDaysInARow)
            }
        }
    }
    
    private var numDaysInARow: Int = 0
    private var recordDaysInARow: Int = 0
    private var totalNumTodoItemTasks: Int = 0
    
    private var fromDate: Date?
    private var toDate: Date?
    private var completedTodoItems = [DVTodoItemTaskViewModel]() {
        didSet {
            var dates = [Date]()
            var datesCounter = [Double]()
            
            completedTodoItems.forEach { todo in
                guard todo.isCompleted == true else { fatalError("faileeeddddddddddddd DVProgressViewController completedTodoItems") }
                
                if !dates.contains { date in
                    return Calendar.current.isDate(date, equalTo: todo.completedAt!, toGranularity: .day)
                    } {
                    dates.append(todo.completedAt!)
                }
            }
            
            for date in dates {
                let filteredByDateValue = completedTodoItems.filter({ todo in
                    return Calendar.current.isDate(date, equalTo: todo.completedAt!, toGranularity: .day)
                })
                let counts = filteredByDateValue.count
                datesCounter.append(Double(counts))
            }
            
            fromDate = dates.first
            toDate = Date()
            graphData = Dictionary(uniqueKeysWithValues: zip(dates, datesCounter))
        }
    }
    
    private var graphData: [Date: Double] = [Date: Double]() {
        didSet {
            if !graphData.isEmpty { setupBarchart(withData: graphData) }
            else { barChartView.data = nil }
        }
    }
    
    private func setupBarchart(withData data: [Date: Double]) {
        if data.isEmpty {
            barChartView.data = nil
            return
        }
        
        var dataEntries: [BarChartDataEntry] = []
        
        if let fromEntry = fromDate {
            let startDate = fromEntry.subtract(days: 1)
            dataEntries.append(BarChartDataEntry(x: Double(startDate.timeIntervalSince1970), y: Double(0)))
        }
        
        for (date, count) in data {
            dataEntries.append(BarChartDataEntry(x: Double(date.timeIntervalSince1970), y: count))
        }
        
        if let toEntry = toDate {
            let endDate = toEntry.add(days: 1)
            dataEntries.append(BarChartDataEntry(x: Double(endDate.timeIntervalSince1970), y: Double(0)))
        }
        
        // -2 is not a magic number it accounts for the 2 extra entries
        // 1 before start
        // 1 after start
        // otherwise the entries hug the chart of iOS Swift =)
        numEntries = dataEntries.count - 2
        
        let barChartDataSet = BarChartDataSet(values: dataEntries, label: "BarChartDataSet")
        
        let colorString = "Global.barTextColor"
        let barChartDataSetColorString = ThemeManager.value(for: colorString) as? String
        let barChartLabelColor = UIColor.from(hex: barChartDataSetColorString!)!
        
        barChartDataSet.colors = [barChartLabelColor]
        barChartView.theme_backgroundColor = "Global.barTintColor"
        barChartView.theme_tintColor = "Global.barTextColor"
        let barChartData = BarChartData(dataSet: barChartDataSet)
        barChartData.barWidth = 86400
        barChartData.setDrawValues(false)
        
        let colorStringID = "Global.placeholderColor"
        let gridColorString = ThemeManager.value(for: colorStringID) as? String
        let gridColorStringUIColor = UIColor.from(hex: gridColorString!)!
        
        let xAxis = barChartView.xAxis
        xAxis.valueFormatter = DateValueFormatter()
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = barChartLabelColor
        xAxis.drawGridLinesEnabled = false
        xAxis.axisLineColor = barChartLabelColor
        xAxis.granularity = 86400
        
        let yAxis = barChartView.leftAxis
        yAxis.labelTextColor = barChartLabelColor
        yAxis.drawGridLinesEnabled = true
        yAxis.gridColor = gridColorStringUIColor
        yAxis.axisLineColor = barChartLabelColor
//        yAxis.valueFormatter = IAxisValueFormatter()
//        yAxis.valueFormatter.minimumFractionDigits = 0
//
//        xAxis.centerAxisLabelsEnabled = true
        
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.highlighter = nil
        
        barChartView.rightAxis.enabled = false
        barChartView.chartDescription?.enabled = false
        barChartView.legend.enabled = false
        barChartView.drawValueAboveBarEnabled = false
//        barChartView.values
//        barChartView.drawBordersEnabled = false
//        barChartView.draw
        barChartView.fitBars = true
        barChartView.data = barChartData
    }
    
//    private var numCompletedTask: Int?
//    private var numEntries: Int?
    
    private var numCompletedTask: Int = 0
    private var numEntries: Int = 0
    
    private var performanceDataWLabels = [
        NSLocalizedString("Current streak", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Current streak **", comment: ""),
        NSLocalizedString("Longest streak", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Longest streak **", comment: ""),
        NSLocalizedString("Total completed tasks", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Total completed tasks **", comment: ""),
        NSLocalizedString("Total tasks", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Total tasks **", comment: ""),
        NSLocalizedString("Days recorded", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Days recorded **", comment: "")
    ]
    
    private var performanceDataLabels: [String]?
    
    override func setupNavigationTitleText(title text: String?) {
            let todaysDate = Date()
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: todaysDate)
            let month = calendar.component(.month, from: todaysDate)
            let day = calendar.component(.day, from: todaysDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let startOfYear = dateFormatter.date(from: "\(year)-01-01")
            let todayInYear = dateFormatter.date(from: "\(year)-\(month)-\(day)")
            let endOfYear = dateFormatter.date(from: "\(year)-12-31")
            
            let daysInCurrentYear = calendar.dateComponents([.day], from: startOfYear!, to: endOfYear!)
            let daysLeftInCurrentYear = calendar.dateComponents([.day], from: todayInYear!, to: endOfYear!)
            
            let totalDays = daysInCurrentYear.day
            let daysLeft = daysLeftInCurrentYear.day
            
            let yearProgress = Int(100 - ceil(Double(daysLeft!)/Double(totalDays!) * 100))
            let yearProgressLocalizedString = NSLocalizedString("Year progress", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND year completed **", comment: "")
            let yearProgressCompletedString = NSLocalizedString("completed", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND completed **", comment: "")
            let yearProgressString = "\(yearProgressLocalizedString): \(yearProgress)% \(yearProgressCompletedString)"
            let todaysDateString = dateFormatter.string(from: todaysDate)
            
            let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)]
            let _title:NSMutableAttributedString = NSMutableAttributedString(string: todaysDateString, attributes: attrs)
            
            let __attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11, weight: .ultraLight)]
            let __subTitle:NSMutableAttributedString = NSMutableAttributedString(string: "\(yearProgressString)", attributes: __attrs)
            
            _title.append(NSAttributedString(string:"\n"))
            _title.append(__subTitle)
            
            let size = _title.size()
            
            let width = size.width
            guard let height = navigationController?.navigationBar.frame.size.height else {return}
            
            let titleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
            titleLabel.attributedText = _title
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.theme_backgroundColor = "Global.barTintColor"
            titleLabel.theme_textColor = "Global.textColor"
            
            navigationItem.titleView = titleLabel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let titleString = "Progress"
        setupNavigationTitleText(title: titleString)
        
        barChartView.noDataText = NSLocalizedString("No data yet, see what happens when you complete a task", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND No data yet, see what happens when you complete a task", comment: "")
        
//        store.fetchTags()
        store.fetchStreaks()
        
//        tags = store.fetchedTags
        streaks = store.fetchedStreaks
        
        store.fetchTagsViewModel()
        dvTagsVM = store.dvTagsVM
        
        if let completedTasks = store.getCompletedTodoItemTasks(ascending: true) {
            if completedTasks.count > 0 {
                if let totalCount = store.getTodoItemTaskCount() {
                    totalNumTodoItemTasks = totalCount
                }
                numCompletedTask = completedTasks.count
                performanceDataLabels = performanceDataWLabels
            } else {
                performanceDataLabels = nil
            }
            completedTodoItems = completedTasks
            performanceTableView.reloadData()
        }
        setupTheming()
    }
    
    private func setupTheming() {
        performanceTableView.theme_backgroundColor = "Global.backgroundColor"
        performanceTableView.theme_separatorColor = "ListViewController.separatorColor"
        tagsTableView.theme_backgroundColor = "Global.backgroundColor"
        tagsTableView.theme_separatorColor = "ListViewController.separatorColor"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performanceTableView.delegate = self
        tagsTableView.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadTableViews),
            name: NSNotification.Name(rawValue: ThemeUpdateNotification),
            object: nil
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViews), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc private func reloadTableViews() {
        self.performanceTableView.reloadData()
        self.tagsTableView.reloadData()
        self.barChartView.notifyDataSetChanged()
        self.barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInBack)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMainTableVCFilteredByTag" {
//            guard let mainTVC = segue.destination as? TodoItemsTableViewController else {
//                fatalError("should be a navigation controller")
//            }
            
            guard let mainTVC = segue.destination as? TodoItemsTableViewController else { fatalError("should be TodoItemsTableViewController") }
            
            if let selectedIndexPath = tagsTableView.indexPathForSelectedRow {
                let tag = dvTagsVM[selectedIndexPath.row]
                store.filteredTag = tag
                mainTVC.hidesBottomBarWhenPushed = true
            }
        }
    }
}

extension DVProgressViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tagsTableView {
            return dvTagsVM.count
        }
        if tableView == performanceTableView {
            if let count = performanceDataLabels?.count {
                return count
            } else {
                return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ThemableBaseTableViewCell!
        if tableView == performanceTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "DefaultPerformanceCell") as? ThemableBaseTableViewCell
            if let performanceDataWLabels = performanceDataLabels, performanceDataWLabels.count > 0 {
                let label = performanceDataWLabels[indexPath.row]
                cell.textLabel?.text = label
                
                switch indexPath.row {
                case 0:
                    cell.detailTextLabel?.text = "\(numDaysInARow)"
                case 1:
                    cell.detailTextLabel?.text = "\(recordDaysInARow)"
                case 2:
                    cell.detailTextLabel?.text = "\(numCompletedTask)"
                case 3:
                    cell.detailTextLabel?.text = "\(totalNumTodoItemTasks)"
                case 4:
                    cell.detailTextLabel?.text = "\(numEntries)"
                default:
                    cell.detailTextLabel?.text = ""
                }
            }
        }
        if tableView == tagsTableView {
            
//            let tag = tags[indexPath.row] as Tag
            let tag = dvTagsVM[indexPath.row]
//            let totalCount = tag.todos?.count ?? -1
//            let totalCount = tag.tagged.count
            
            cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTagsCell") as? ThemableBaseTableViewCell
            cell.textLabel?.text = tag.label
            cell.imageView?.image = #imageLiteral(resourceName: "tagsFilledinCircle")
            cell.detailTextLabel?.text = ""
            
//            if totalCount > 0 {
//                let remainderTodosVM = tag.tagged.filter { todoItemVM in !todoItemVM.isCompleted }
//                let completedTodosVM = tag.tagged.filter { todoItemVM in todoItemVM.isCompleted }
//
//                let remainderCount = remainderTodosVM.count
//                let completedCount = completedTodosVM.count
////                let remainderCount = tag.todos?.filtered(using: NSPredicate(format:"completed != true")).count ?? -1
////                let completedCount = tag.todos?.filtered(using: NSPredicate(format:"completed = true")).count ?? -1
//
//                if remainderCount == 0 {
//                    cell.detailTextLabel?.text = "100%"
//                } else {
//                    let calc = Double(completedCount/totalCount) * 100.0
//                    if calc > 0 {
//                        cell.detailTextLabel?.text = "\(calc)%"
//                    } else {
//                        cell.detailTextLabel?.text = "\(remainderCount)"
//                    }
//                }
//            } else {
//                cell.detailTextLabel?.text = "None"
//            }
            
            cell.accessoryType = .disclosureIndicator
        }
        
        cell.textLabel?.theme_textColor = "Global.textColor"
        cell.textLabel?.theme_backgroundColor = "Global.barTintColor"
        cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
        cell.detailTextLabel?.theme_backgroundColor = "Global.barTintColor"
        
        return cell
    }
    
    
}
