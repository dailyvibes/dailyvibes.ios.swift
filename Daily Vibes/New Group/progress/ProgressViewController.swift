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

class ProgressViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet private weak var recordStreak: UILabel!
    @IBOutlet private weak var currentStreak: UILabel!
    @IBOutlet private weak var totalTasksCompleted: UILabel!
    @IBOutlet private weak var lineChart: LineChartView!
    @IBOutlet private weak var streakStackTextView: UIStackView!
    
    fileprivate weak var axisFormatDelegate: IAxisValueFormatter?
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var currentStreakNumberLabel: UILabel!
    @IBOutlet private weak var recordStreakNumberLabel: UILabel!
    @IBOutlet private weak var totalTasksCompletedLabel: UILabel!
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    //    private var fetchedResultsController: NSFetchedResultsController<TodoItem>!
    //    private var moc: NSManagedObjectContext?
    
    fileprivate lazy var streaksFetchedResultsController: NSFetchedResultsController<Streak> = {
        let fetchRequest: NSFetchRequest<Streak> = Streak.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "updatedAt", ascending: true)]
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
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //
    //        guard let context = container?.viewContext else {
    //            fatalError("should not fail on viewWillAppear")
    //        }
    //
    //        let streaksRequest: NSFetchRequest = Streak.fetchRequest()
    //        streaksRequest.sortDescriptors = [NSSortDescriptor.init(key: "updatedAt", ascending: false)]
    //
    //        if let streaks = try? context.fetch(streaksRequest), let totalCount = streaks.count as Int? {
    //            if totalCount > 0 {
    //                // show
    //                let streak = streaks.first
    //                recordStreakNumberLabel.text = "\(streak?.recordDaysInARow ?? -1)"
    //                currentStreakNumberLabel.text = "\(streak?.currentDaysInARow ?? -1)"
    //                totalTasksCompletedLabel.text = "\(streak?.tasksCompletedTotal ?? -1)"
    //            } else {
    //                // do nothing .. maybe even hide the views...
    //            }
    //        }
    //    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //
    //    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.axisFormatDelegate = self
        
        let progressNavigationTitle = NSLocalizedString("Progress", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Progress**", comment: "")
        self.navigationItem.title = progressNavigationTitle
        
        setupLineChart()
        setupPVCTableView()
        
        setupStreaksLabels()
    }
    
    private func setupLineChart() {
        do {
            try streaksFetchedResultsController.performFetch()
            print("performed streaks fetch")
            print("results: \(streaksFetchedResultsController.fetchedObjects?.count ?? -1)")
            updateLineChartData()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    private func lineChartSetup() {
        lineChart.backgroundColor = .white
        setLineChartData()
    }
    
    private func setLineChartData(dataPoints: [Double] = [0, 1, 2, 3, 4, 5], values: [Double] = [1, 5, 4, 6, 7, 8]) {
        lineChart.noDataText = "No progress data yet"
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            //            print("x: \(dataPoints[i]), y: \(values[i])")
            dataEntries.append(ChartDataEntry(x: dataPoints[i], y: values[i]))
        }
        
        //        let chartDataSet = ChartDataSet(values: dataEntries, label: "Completed")
        let lineChartDataSet = LineChartDataSet.init(values: dataEntries, label: "Tasks Completed per Day")
        
        let chartData = LineChartData()
        
        chartData.addDataSet(lineChartDataSet)
        chartData.setDrawValues(true)
        
        lineChartDataSet.setColor(.black)
        lineChartDataSet.drawCirclesEnabled = true
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.setCircleColor(.black)
        lineChartDataSet.circleRadius = CGFloat.init(2)
        //        lineChartDataSet.circleHoleColor = .black
        //        lineChartDataSet.drawCircleHoleEnabled = true
        //        lineChartDataSet.circleHoleColor = .blue
        //        lineChartDataSet.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        //        lineChartDataSet.fillAlpha = 0.26
        lineChartDataSet.drawFilledEnabled = true
        
        //        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
        //                              ChartColorTemplates.colorFromString("#ffff0000").cgColor]
        let grdntClrs = [#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor,#colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1).cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: grdntClrs as CFArray, locations: nil)!
        
        lineChartDataSet.fillAlpha = 1
        //        lineChartDataSet.lineWidth = 2.0
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
            print("has streaks, \(streaks.count)")
            hasStreak = streaks.count > 0
            
            if let dayBeforeFirst = streaks.first?.updatedAt?.startTime() {
                print("dayBeforeFirst value: \(Date.init(timeIntervalSince1970: dayBeforeFirst.timeIntervalSince1970))")
                x.append(dayBeforeFirst.timeIntervalSince1970)
                y.append(Double(0))
            }
            
            for streak in streaks {
                print("streak updatedAt date: \((streak.updatedAt?.endTime().timeIntervalSince1970)!)")
                print("currentDaysInARow: \(streak.currentDaysInARow); recordDaysInARow: \(streak.recordDaysInARow); tasksCompletedTotal: \(streak.tasksCompletedTotal)")
                //                streak.updatedAt?.
                x.append((streak.updatedAt?.endTime().timeIntervalSince1970)!)
                y.append(Double(streak.tasksCompletedToday))
            }
        }
        
        lineChart.isHidden = !hasStreak
        
        setLineChartData(dataPoints: x, values: y)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadForLineChart(dataPoints: [Double], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            //            let _dataEntry = ChartDataEntry.init
            print("x: \(Double(i)), y: \(values[i]), date: \(dataPoints[i])")
            let dataEntry = ChartDataEntry(x: dataPoints[i], y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Your to-do activity over last week")
        lineChartDataSet.axisDependency = .left
        
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        let xAxis = lineChart.xAxis
        //        xAxis.forceLabelsEnabled = true
        xAxis.valueFormatter = axisFormatDelegate
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        //        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = true
        xAxis.centerAxisLabelsEnabled = true
        //        xAxis.granularity = 86400
        
        let leftAxis = lineChart.leftAxis
        leftAxis.labelPosition = .insideChart
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .light)
        leftAxis.drawGridLinesEnabled = true
        //        leftAxis.granularityEnabled = true
        leftAxis.axisMinimum = 0
        //        leftAxis.axisMaximum = 50
        leftAxis.yOffset = -9
        leftAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        
        lineChart.rightAxis.enabled = false
        //        lineChart.legend.form = .line
        lineChart.drawGridBackgroundEnabled = false
        lineChart.backgroundColor = .white
        lineChart.legend.enabled = false
        
        lineChart.data = lineChartData
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    private func setupPVCTableView() {
        do {
            try tagsFetchedResultsController.performFetch()
            tableView.tableFooterView = UIView()
            print("performed fetch")
            print("results: \(tagsFetchedResultsController.fetchedObjects?.count ?? -1)")
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
            print("has tags, \(tags.count)")
            hasTags = tags.count > 0
        }
        
        tableView.isHidden = !hasTags
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMainTableVCFilteredByTag" {
            guard let mainTVC = segue.destination as? TodoItemsTableViewController else {
                fatalError("should be a navigation controller")
            }
//            guard let todoItemsVC = mainTVC.viewControllers.first as? TodoItemsTableViewController else {
//                fatalError("should be TodoItemViewController for the AddTodoItem segue")
//            }
            
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
        print("returning for \(tags.count) rows")
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PVCTagsCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell? else {
            fatalError("Unexpected Index Path")
        }
        //        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuoteTableViewCell.reuseIdentifier, for: indexPath) as? QuoteTableViewCell else {
        //            fatalError("Unexpected Index Path")
        //        }
        
        // Fetch Tag
        let tag = tagsFetchedResultsController.object(at: indexPath)
        //        let tag = tags[indexPath.row]
        
//        print("returning cell")
        
        // Configure Cell
        //        cell.backgroundView?.layer
        //        cell.layer.backgroundColor = #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1).cgcolor()
        //        cell.layer.backgroundColor = UIColor.blue.cgColor
        
        //        cell.layer.cornerRadius = 10
        ////        let shadowPath2 = UIBezierPath(rect: cell.bounds)
        //        cell.layer.masksToBounds = false
        //        cell.layer.shadowColor = UIColor.black.cgColor
        //        cell.layer.shadowOffset = CGSize(width: CGFloat(1.0), height: CGFloat(3.0))
        //        cell.layer.shadowOpacity = 0.5
        ////        cell.layer.shadowPath = shadowPath2.cgPath
        
        //        cell.contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
        //        cell.contentView.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
        //        cell.layer.borderColor = UIColor.green.cgColor
        //        cell.layer.borderWidth = 5
//        cell.contentView.layer.borderColor = UIColor.blue.cgColor
//        cell.contentView.layer.borderWidth = 2
//        cell.contentView.layer.cornerRadius = 2
//        cell.contentView.layer.masksToBounds = true
        
//        cell.bounds = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width - 50, height: cell.bounds.height)
//        
//        cell.contentView.layer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
//        cell.contentView.layer.cornerRadius = 5
//        cell.contentView.clipsToBounds = true
        
        cell.textLabel?.text = tag.label
        let totalCount = tag.todos?.count ?? -1
        let remainderCount = tag.todos?.filtered(using: NSPredicate(format:"completed != true")).count ?? -1
        let completedCount = tag.todos?.filtered(using: NSPredicate(format:"completed = true")).count ?? -1
        
        print("totalcount: \(totalCount) | remainderCount: \(remainderCount) | completedCount: \(completedCount)")
        
        if remainderCount == 0 {
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
            cell.detailTextLabel?.text = "\(totalCount) completed"
        } else {
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
            cell.detailTextLabel?.text = "\(completedCount)/\(totalCount)"
        }
        
        //        if remainderCount > completedCount {
        //            cell.detailTextLabel?.text = "\(completedCount)/\(remainderCount)"
        //        }
        //        if totalCount == completedCount {
        //            cell.detailTextLabel?.text = "\(totalCount ?? -1) completed"
        //        }
        
        return cell
    }
    
}

extension ProgressViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("calling controllerWillChangeContent in ProgressViewController")
        //        updatePVCTableView()
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
        updateLineChartData()
        tableView.reloadData()
        //        lineChart.setNeedsDisplay()
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
