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
//    @IBOutlet private weak var todaysTasksCompleted: UILabel!
//    @IBOutlet private weak var pieChart: PieChartView!
    @IBOutlet private weak var lineChart: LineChartView!
    
//    private var tags = [Tag]() {
//        didSet {
//            updatePVCTableView()
//        }
//    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var currentStreakNumberLabel: UILabel!
    @IBOutlet private weak var recordStreakNumberLabel: UILabel!
    @IBOutlet private weak var totalTasksCompletedLabel: UILabel!
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
//    private var fetchedResultsController: NSFetchedResultsController<TodoItem>!
    private var moc: NSManagedObjectContext?
    
    fileprivate lazy var streaksFetchedResultsController: NSFetchedResultsController<Streak> = {
        let fetchRequest: NSFetchRequest<Streak> = Streak.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "updatedAt", ascending: false)]
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let context = container?.viewContext else {
            fatalError("should not fail on viewWillAppear")
        }
        
        let streaksRequest: NSFetchRequest = Streak.fetchRequest()
        streaksRequest.sortDescriptors = [NSSortDescriptor.init(key: "updatedAt", ascending: false)]
        
        if let streaks = try? context.fetch(streaksRequest), let totalCount = streaks.count as Int? {
            if totalCount > 0 {
                // show
                let streak = streaks.first
                recordStreakNumberLabel.text = "\(streak?.recordDaysInARow ?? -1)"
                currentStreakNumberLabel.text = "\(streak?.currentDaysInARow ?? -1)"
                totalTasksCompletedLabel.text = "\(streak?.tasksCompletedTotal ?? -1)"
//                recordStreak.text = "record streak is \(streak?.recordDaysInARow ?? -1) days"
//                currentStreak.text = "current streak is \(streak?.currentDaysInARow ?? -1) days"
//                todaysTasksCompleted.text = "You completed \(streak?.tasksCompletedToday ?? -1) tasks today"
//                totalTasksCompleted.text = "You've completed \(streak?.tasksCompletedTotal ?? -1) total."
            } else {
                // do nothing .. maybe even hide the views...
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        loadForLineChart(dataPoints: months, values: unitsSold)
        setupPVCTableView()
//        loadForDataPieChart()
//        pieChartUpdate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadForLineChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        var colors: [UIColor] = []
        
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Your to-do activity over last week")
//        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
//        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChart.data = lineChartData
    }
    
//    private func loadForDataPieChart() {
//        if let context = container?.viewContext {
//            let fetch: NSFetchRequest = TodoItem.fetchRequest()
//            if let totalCount = try? context.count(for: fetch) {
//                print("task count total = \(totalCount)")
//                fetch.predicate = NSPredicate(format: "isArchived != true AND completed != true")
//                if let inboxCount = try? context.count(for: fetch) {
//                    print("task count inbox = \(inboxCount)")
//                    fetch.predicate = NSPredicate(format: "isArchived != true AND completed = true")
//                    if let doneCount = try? context.count(for: fetch) {
//                        print("task count done = \(doneCount)")
//                        fetch.predicate = NSPredicate(format: "isArchived = true")
//                        if let archiveCount = try? context.count(for: fetch) {
//                            print("task count archived = \(archiveCount)")
//                            pieChartUpdate(inbox: inboxCount, done: doneCount, archived: archiveCount)
//                        }
//                    }
//                }
//            }
//        }
//
//
////        let fetch: NSFetchRequest = TodoItem.fetchRequest()
////
////        let keyPathExpression = NSExpression(forKeyPath: "completed")
////        let expression = NSExpression(forFunction: "count:", arguments:[keyPathExpression])
////        let countDesc = NSExpressionDescription()
////
////        countDesc.expression = expression
////        countDesc.name = "count"
////        countDesc.expressionResultType = .integer64AttributeType
////
////        fetch.returnsObjectsAsFaults = false
////        fetch.propertiesToGroupBy = ["completed"]
////        fetch.propertiesToFetch = ["completed", countDesc]
////        fetch.resultType = .dictionaryResultType
////
////        print(fetch)
//    }
    
//    private func pieChartUpdate(inbox:Int, done:Int, archived:Int) {
//        // pie chart code
//        let entry1 = PieChartDataEntry(value: Double(inbox), label: "Inbox")
//        let entry2 = PieChartDataEntry(value: Double(done), label: "Done")
//        let entry3 = PieChartDataEntry(value: Double(archived), label: "Archived")
//        let dataSet = PieChartDataSet(values: [entry1, entry2, entry3], label: "To-dos")
//
//        dataSet.colors = ChartColorTemplates.colorful()
////        dataSet.label
////        dataSet.valueColors = [UIColor.black]
////        pieChart.backgroundColor = UIColor.black
////        pieChart.holeColor = UIColor.clear
////        pieChart.chartDescription?.textColor = UIColor.white
////        pieChart.legend.textColor = UIColor.white
//
//        let data = PieChartData(dataSet: dataSet)
////        pieChart.data = data
////        pieChart.chartDescription?.text = "To-dos by Type"
////        pieChart.notifyDataSetChanged()
//    }
    

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
        
        print("returning cell")
        
        // Configure Cell
        cell.textLabel?.text = tag.label
        let totalCount = tag.todos?.count
        let remainderCount = tag.todos?.filtered(using: NSPredicate(format:"completed != true")).count ?? -1
        let completedCount = tag.todos?.filtered(using: NSPredicate(format:"completed = true")).count ?? -1
        
        print("totalcount: \(totalCount) | remainderCount: \(remainderCount) | completedCount: \(completedCount)")
        
        if remainderCount > completedCount {
            cell.detailTextLabel?.text = "\(completedCount)/\(remainderCount)"
        }
        if totalCount == completedCount {
            cell.detailTextLabel?.text = "\(totalCount ?? -1) completed"
        }
        
        return cell
    }
    
}

extension ProgressViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        updatePVCTableView()
    }
}
