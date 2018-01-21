//
//  ProgressViewController.swift
//  Daily Vibes
//
//  Created by Alex Kluew on 2017-12-10.
//  Copyright © 2017 Alex Kluew. All rights reserved.
//

import UIKit
import Charts
import CoreData

class ProgressViewController: ThemableViewController {
    
    // MARK: - Properties
    @IBOutlet private weak var streaksStackView: UIStackView!
    @IBOutlet private weak var recordStreak: UILabel!
    @IBOutlet private weak var currentStreak: UILabel!
    @IBOutlet private weak var totalTasksCompleted: UILabel!
    @IBOutlet private weak var lineChart: BarChartView!
    @IBOutlet private weak var streakStackTextView: UIStackView!
    
    fileprivate weak var axisFormatDelegate: IAxisValueFormatter?
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var currentStreakNumberLabel: UILabel!
    @IBOutlet private weak var recordStreakNumberLabel: UILabel!
    @IBOutlet private weak var totalTasksCompletedLabel: UILabel!
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.store.persistentContainer
    //    private var fetchedResultsController: NSFetchedResultsController<TodoItem>!
    //    private var moc: NSManagedObjectContext?
    
    
    fileprivate lazy var streaksFetchedResultsController: NSFetchedResultsController<Streak> = {
        let fetchRequest: NSFetchRequest<Streak> = Streak.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "createdAt", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: (container?.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    fileprivate lazy var tagsFetchedResultsController: NSFetchedResultsController<Tag> = {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "createdAt", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: (container?.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    fileprivate func setupStreaksLabels() {
        if let streaks = streaksFetchedResultsController.fetchedObjects {
            if let firstStreak = streaks.last {
                streakStackTextView.isHidden = false
                recordStreakNumberLabel.text = "\(firstStreak.recordDaysInARow)"
                currentStreakNumberLabel.text = "\(firstStreak.currentDaysInARow)"
                totalTasksCompletedLabel.text = "\(firstStreak.tasksCompletedTotal)"
            } else {
                streakStackTextView.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let titleText = "Progress"
        setupNavigationTitleText(title: titleText)
        
        setupTheming()
    }
    
    fileprivate func setupTheming() {
        view.theme_backgroundColor = "Global.backgroundColor"
        
        streaksStackView.theme_backgroundColor = "Global.backgroundColor"
        
        recordStreak.theme_backgroundColor = "Global.backgroundColor"
        recordStreak.theme_textColor = "Global.textColor"
        
        currentStreak.theme_backgroundColor = "Global.backgroundColor"
        currentStreak.theme_textColor = "Global.textColor"
        
        totalTasksCompleted.theme_backgroundColor = "Global.backgroundColor"
        totalTasksCompleted.theme_textColor = "Global.textColor"
        
        currentStreakNumberLabel.theme_backgroundColor = "Global.backgroundColor"
        currentStreakNumberLabel.theme_textColor = "Global.textColor"
        
        recordStreakNumberLabel.theme_backgroundColor = "Global.backgroundColor"
        recordStreakNumberLabel.theme_textColor = "Global.textColor"
        
        totalTasksCompletedLabel.theme_backgroundColor = "Global.backgroundColor"
        totalTasksCompletedLabel.theme_textColor = "Global.textColor"
        
        streakStackTextView.theme_backgroundColor = "Global.backgroundColor"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.axisFormatDelegate = self
        
        setupLineChart()
        setupPVCTableView()
        
        setupStreaksLabels()
    }
    
    private func setupLineChart() {
        do {
            try streaksFetchedResultsController.performFetch()
            updateLineChartData()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    private func lineChartSetup() {
        setLineChartData()
    }
    
    private func setLineChartData(dataPoints: [Double] = [0, 1, 2, 3, 4, 5], values: [Double] = [1, 5, 4, 6, 7, 8]) {
        lineChart.noDataText = "No progress data yet"
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            dataEntries.append(ChartDataEntry(x: dataPoints[i], y: values[i]))
        }
        
        let lineChartDataSet = LineChartDataSet.init(values: dataEntries, label: "")
        
        let chartData = LineChartData()
        
        chartData.addDataSet(lineChartDataSet)
        chartData.setDrawValues(true)
        
        lineChartDataSet.setColor(.black)
        lineChartDataSet.drawCirclesEnabled = true
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.setCircleColor(.black)
        lineChartDataSet.circleRadius = CGFloat.init(2)
        lineChartDataSet.drawFilledEnabled = true

        let grdntClrs = [#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor,#colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1).cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: grdntClrs as CFArray, locations: nil)!
        
        lineChartDataSet.fillAlpha = 1
        lineChartDataSet.fill = Fill(linearGradient: gradient, angle: 90)
        lineChartDataSet.mode = (lineChartDataSet.mode == .cubicBezier) ? .linear : .cubicBezier
        
        lineChart.xAxis.valueFormatter = axisFormatDelegate
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.xAxis.granularityEnabled = true
        lineChart.xAxis.granularity = 86400
        lineChart.legend.enabled = false
        lineChart.rightAxis.enabled = false
        lineChart.chartDescription?.enabled = true
        let lineChartDescriptionLabel = NSLocalizedString("Daily task completion history", tableName: "Localizable", bundle: .main, value: "*** DID NOT FIND lineChartDescriptionLabel ***", comment: "")
        lineChart.chartDescription?.text = lineChartDescriptionLabel
        lineChart.viewPortHandler.setMaximumScaleX(1.0)
        
        lineChart.data = chartData
    }
    
    private func updateLineChartData() {
        var hasStreak = false
        
        var x = [Double]()
        var y = [Double]()
        
        if let streaks = streaksFetchedResultsController.fetchedObjects {
            hasStreak = streaks.count > 0
            
            if let dayBeforeFirst = streaks.first?.updatedAt?.startTime() {
                x.append(dayBeforeFirst.timeIntervalSince1970)
                y.append(Double(0))
            }
            
            for streak in streaks {
                x.append((streak.updatedAt?.endTime().timeIntervalSince1970)!)
                y.append(Double(streak.tasksCompletedToday))
            }
        }
        
        lineChart.isHidden = !hasStreak
        
        setLineChartData(dataPoints: x, values: y)
    }
    
    private func loadForLineChart(dataPoints: [Double], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: dataPoints[i], y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Your to-do activity over last week")
        lineChartDataSet.axisDependency = .left
        
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        let xAxis = lineChart.xAxis
        xAxis.valueFormatter = axisFormatDelegate
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        xAxis.drawGridLinesEnabled = true
        xAxis.centerAxisLabelsEnabled = true
        
        let leftAxis = lineChart.leftAxis
        leftAxis.labelPosition = .insideChart
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .light)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.axisMinimum = 0
        leftAxis.yOffset = -9
        leftAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        
        lineChart.rightAxis.enabled = false
        lineChart.drawGridBackgroundEnabled = false
        lineChart.backgroundColor = .white
        lineChart.legend.enabled = false
        
        lineChart.data = lineChartData
    }

    private func setupPVCTableView() {
        do {
            try tagsFetchedResultsController.performFetch()
            tableView.theme_backgroundColor = "Global.backgroundColor"
            tableView.theme_separatorColor = "ListViewController.separatorColor"
            tableView.tableFooterView = UIView()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        updatePVCTableView()
    }
    
    private func updatePVCTableView() {
        var hasTags = false
        
        if let tags = tagsFetchedResultsController.fetchedObjects {
            hasTags = tags.count > 0
        }
        
        tableView.isHidden = !hasTags
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMainTableVCFilteredByTag" {
            guard let mainTVC = segue.destination as? TodoItemsTableViewController else {
                fatalError("should be a navigation controller")
            }
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if let tag = tagsFetchedResultsController.object(at: selectedIndexPath) as Tag? {
                    mainTVC.setupTodoItemsTVC(using: tag)
                }
            }
        }
    }
}

extension ProgressViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tags = tagsFetchedResultsController.fetchedObjects else { return 0 }
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PVCTagsCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell? else {
            fatalError("Unexpected Index Path")
        }
        
        cell.textLabel?.theme_textColor = "Global.textColor"
        cell.detailTextLabel?.theme_textColor = "Global.barTextColor"
        
        let tag = tagsFetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = tag.label
        let totalCount = tag.todos?.count ?? -1
        let remainderCount = tag.todos?.filtered(using: NSPredicate(format:"completed != true")).count ?? -1
        let completedCount = tag.todos?.filtered(using: NSPredicate(format:"completed = true")).count ?? -1
        
        if remainderCount == 0 {
            cell.detailTextLabel?.text = "\(totalCount) completed"
        } else {
            cell.detailTextLabel?.text = "\(completedCount)/\(totalCount)"
        }
        
        return cell
    }
    
}

extension ProgressViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if !tableView.isHidden {
            tableView.beginUpdates()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if !tableView.isHidden {
            switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if !tableView.isHidden {
            tableView.endUpdates()
        }
        
        setupStreaksLabels()
        updatePVCTableView()
        setupLineChart()
        
        tableView.reloadData()
    }
}

// MARK: axisFormatDelegate
extension ProgressViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        print("value: \(Date.init(timeIntervalSince1970: value))")
        dateFormatter.dateFormat = "d yyyy"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
