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
    private var tags = [Tag]()
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
        
        let yAxis = barChartView.leftAxis
        yAxis.labelTextColor = barChartLabelColor
        yAxis.drawGridLinesEnabled = true
        yAxis.gridColor = gridColorStringUIColor
        yAxis.axisLineColor = barChartLabelColor
//        yAxis.valueFormatter = IAxisValueFormatter()
//        yAxis.valueFormatter.minimumFractionDigits = 0
//        xAxis.granularity = 86400
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
        "Current streak",
        "Longest streak",
        "Total completed tasks",
        "Total tasks",
        "Days recorded"
    ]
    
    private var performanceDataLabels: [String]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let titleString = NSLocalizedString("Progress", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND PROGRESS **", comment: "")
        setupNavigationTitleText(title: titleString)
        
        store.fetchTags()
        store.fetchStreaks()
        
        tags = store.fetchedTags
        streaks = store.fetchedStreaks
        
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
            guard let mainTVC = segue.destination as? TodoItemsTableViewController else {
                fatalError("should be a navigation controller")
            }
            
            if let selectedIndexPath = tagsTableView.indexPathForSelectedRow {
                if let tag = tags[selectedIndexPath.row] as Tag? {
                    mainTVC.setupTodoItemsTVC(using: tag)
                }
            }
        }
    }
}

extension DVProgressViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tagsTableView {
            return tags.count
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
                
//                private var numCompletedTask: Int = 0
//                private var numEntries: Int = 0
                
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
            cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTagsCell") as? ThemableBaseTableViewCell
            let tag = tags[indexPath.row] as Tag
            cell.textLabel?.text = tag.label
            cell.imageView?.image = #imageLiteral(resourceName: "tagsFilledinCircle")
            
            let totalCount = tag.todos?.count ?? -1
            let remainderCount = tag.todos?.filtered(using: NSPredicate(format:"completed != true")).count ?? -1
            let completedCount = tag.todos?.filtered(using: NSPredicate(format:"completed = true")).count ?? -1
            
            if remainderCount == 0 {
                cell.detailTextLabel?.text = "100%"
            } else {
                let calc = Double(completedCount/totalCount) * 100.0
                if calc > 0 {
                    cell.detailTextLabel?.text = "\(calc)%"
                } else {
                    cell.detailTextLabel?.text = "\(remainderCount)"
                }
            }
            
            cell.accessoryType = .disclosureIndicator
        }
        cell.textLabel?.theme_textColor = "Global.textColor"
        cell.textLabel?.theme_backgroundColor = "Global.barTintColor"
        cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
        cell.detailTextLabel?.theme_backgroundColor = "Global.barTintColor"
        return cell
    }
    
    
}
