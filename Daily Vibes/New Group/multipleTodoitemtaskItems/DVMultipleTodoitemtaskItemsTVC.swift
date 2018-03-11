////
////  DVMultipleTodoitemtaskItemsTVC.swift
////  Daily Vibes
////
////  Created by Alex Kluew on 2018-02-16.
////  Copyright © 2018 Alex Kluew. All rights reserved.
////
//
//import UIKit
//import GrowingTextView
//
//class DVMultipleTodoitemtaskItemsTVC: ThemableTableViewController {
//    
//    private let store = CoreDataManager.store
//    private var data = DVMultipleTodoitemtaskItemsVM()
//    
//    private var inputToolbar: UIView!
//    private var textView: GrowingTextView!
//    private var textViewBottomConstraint: NSLayoutConstraint!
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        tableView.theme_backgroundColor = "Global.backgroundColor"
//        tableView.theme_separatorColor = "ListViewController.separatorColor"
//        
//        tableView.tableFooterView = UIView()
//        
//        if data.curProject == nil {
//            data.curProject = store.filteredProjectList
//            data.prevProject = store.filteredProjectList
//        } else {
//            data.curProject = store.filteredProjectList
//        }
//        
//        self.tableView.reloadData()
//        
//        setupNavigationTitleText(title: "Add Multiple To-do Items", subtitle: nil)
//        
//        let cancelButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelButton))
//        let saveButton = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(handleSaveButton))
//        
//        self.navigationItem.leftBarButtonItem = cancelButton
//        self.navigationItem.rightBarButtonItem = saveButton
//    }
//    
//    @objc func handleCancelButton() {
//        if data.prevProject != nil {
//            store.filteredProjectList = data.prevProject
//        }
//        closeView()
//    }
//    
//    @objc func handleSaveButton() {
//        let project = data.curProject
//        let projectText = project?.title ?? ""
//        let rawMultipleTaskItemTodoText = data.rawMultipleTaskText ?? ""
//        
//        print("project to add to: \(projectText)")
//        print("data to parse: \(rawMultipleTaskItemTodoText)")
//        
//        closeView()
//    }
//    
//    fileprivate func closeView() {
//        let isPresentingInADDMode = presentingViewController is DailyVibesTabBarViewController
//        
//        if isPresentingInADDMode {
//            dismiss(animated: true, completion: nil)
//        } else if let owningNavigationController = navigationController {
//            owningNavigationController.popViewController(animated: true)
//        } else {
//            fatalError("The TodoItemViewController is not inside a navigation controller.")
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.clearsSelectionOnViewWillAppear = true
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        // *** Create Toolbar
//        inputToolbar = UIView()
//        inputToolbar.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
//        inputToolbar.translatesAutoresizingMaskIntoConstraints = false
////        view.addSubview(inputToolbar)
////        self.navigationController?.view.addSubview(inputToolbar)
//        
//        // *** Create GrowingTextView ***
//        textView = GrowingTextView()
//        textView.delegate = self
//        textView.layer.cornerRadius = 4.0
//        textView.maxLength = 200
//        textView.maxHeight = 70
//        textView.trimWhiteSpaceWhenEndEditing = true
//        textView.placeHolder = "Say something..."
//        textView.placeHolderColor = UIColor(white: 0.8, alpha: 1.0)
//        textView.font = UIFont.systemFont(ofSize: 15)
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        inputToolbar.addSubview(textView)
//        
//        // *** Autolayout ***
//        NSLayoutConstraint.activate([
//            inputToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            inputToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            inputToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            textView.topAnchor.constraint(equalTo: inputToolbar.topAnchor, constant: 8)
//            ])
//        
//        if #available(iOS 11, *) {
//            textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.bottomAnchor, constant: -8)
//            NSLayoutConstraint.activate([
//                textView.leadingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.leadingAnchor, constant: 8),
//                textView.trailingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.trailingAnchor, constant: -8),
//                textViewBottomConstraint
//                ])
//        } else {
//            textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: inputToolbar.bottomAnchor, constant: -8)
//            NSLayoutConstraint.activate([
//                textView.leadingAnchor.constraint(equalTo: inputToolbar.leadingAnchor, constant: 8),
//                textView.trailingAnchor.constraint(equalTo: inputToolbar.trailingAnchor, constant: -8),
//                textViewBottomConstraint
//                ])
//        }
//        
//        // *** Listen to keyboard show / hide ***
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
//        
//        // *** Hide keyboard when tapping outside ***
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
//        view.addGestureRecognizer(tapGesture)
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
//        if let endFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            var keyboardHeight = view.bounds.height - endFrame.origin.y
//            if #available(iOS 11, *) {
//                if keyboardHeight > 0 {
//                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
//                }
//            }
//            textViewBottomConstraint.constant = -keyboardHeight - 8
//            view.layoutIfNeeded()
//        }
//    }
//    
//    @objc private func tapGestureHandler() {
//        view.endEditing(true)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//    
//    // MARK: - Table view data source
//    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 18))
//        view.theme_backgroundColor = "Global.backgroundColor"
//        let label = UILabel.init(frame: CGRect.init(x: 10, y: 5, width: self.tableView.frame.size.width, height: 18))
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.theme_textColor = "Global.barTextColor"
//        label.text = self.tableView(tableView, titleForHeaderInSection: section)
//        view.addSubview(label)
//        return view
//    }
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 4
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 1
//    }
//    
//    /*
//     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//     
//     // Configure the cell...
//     
//     return cell
//     }
//     */
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        //        let cell: = tableView.dequeueReusableCell(withIdentifier: "defaultBasicCell", for: indexPath)
//        
//        var cell = UITableViewCell()
//        let section = indexPath.section
//        
//        if section == 0 {
//            // project
//            cell = tableView.dequeueReusableCell(withIdentifier: "defaultBasicCell", for: indexPath)
//            
//            cell.theme_backgroundColor = "Global.barTintColor"
//            cell.textLabel?.theme_textColor = "Global.textColor"
//            cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
//            
//            let projectLabelText = NSLocalizedString("Project", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Project **", comment: "")
//            
//            cell.textLabel?.text = projectLabelText
//            cell.detailTextLabel?.text = data.curProject?.title
//            
//            cell.accessoryType = .disclosureIndicator
//        }
//        
//        if section == 1 {
//            // due date
//            cell = tableView.dequeueReusableCell(withIdentifier: "defaultBasicCell", for: indexPath)
//            
//            cell.theme_backgroundColor = "Global.barTintColor"
//            cell.textLabel?.theme_textColor = "Global.textColor"
//            cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
//            
//            cell.textLabel?.text = NSLocalizedString("Due", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Due **", comment: "")
//            
//            if data.duedateAt == nil {
//                cell.detailTextLabel?.text = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** Did not find None **", comment: "")
//            } else {
//                
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateStyle = .short
//                dateFormatter.timeStyle = .short
//                
//                if let dt = data.duedateAt {
//                    cell.detailTextLabel?.text = dateFormatter.string(from:dt)
//                }
//            }
//            
//            cell.accessoryType = .disclosureIndicator
//        }
//        
//        if section == 2 {
//            // remind
//            
//            cell = tableView.dequeueReusableCell(withIdentifier: "defaultBasicCell", for: indexPath)
//            
//            cell.theme_backgroundColor = "Global.barTintColor"
//            cell.textLabel?.theme_textColor = "Global.textColor"
//            cell.detailTextLabel?.theme_textColor = "Global.placeholderColor"
//            
//            cell.textLabel?.text = NSLocalizedString("Remind me", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Remind me **", comment: "")
//            
////            let remindersSwitch = UISwitch.init(frame: CGRect.init())
////            cell.addSubview(remindersSwitch)
////            cell.accessoryView = remindersSwitch
////
////            if data.duedateAt == nil {
////                remindersSwitch.isEnabled = false
////            }
//            
////            if data.duedateAt == nil {
////                cell.detailTextLabel?.text = NSLocalizedString("None", tableName: "Localizable", bundle: .main, value: "** Did not find None **", comment: "")
////            } else {
////
////                UISwitch *theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
////                [cell addSubview:theSwitch];
////                cell.accessoryView = theSwitch;
////            }
//        }
//        
//        if section == 3 {
//            // multiple entries
//            let customCell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! DVMultipleTodoitemtaskItemsInputTableViewCell
//            
//            cell = customCell
//        }
//        
//        return cell
//    }
//    
//    // MARK: - DatePicker
//    func datePickerTappedForDuedateAtDateCell() {
//        let datePicker = DatePickerDialog()
//        
//        let setDueDateTitle = NSLocalizedString("Set Due Date", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Set Due Date ***", comment: "")
//        let setString = NSLocalizedString("Set", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Done ***", comment: "")
//        let cancelString = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .main, value: "** DID NOT FIND Cancel ***", comment: "")
//        
//        datePicker.show(setDueDateTitle,
//                        doneButtonTitle: setString,
//                        cancelButtonTitle: cancelString,
//                        defaultDate: Date().endTime()) { [unowned self] (date) in
//                            if let dt = date {
//                                self.data.duedateAt = dt
//                                self.tableView.reloadData()
//                            }
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let section = indexPath.section
//        
//        if section == 0 {
//            let storyboard = UIStoryboard.init(name: "DVProjectListStoryboard", bundle: nil)
//            let tvc = storyboard.instantiateViewController(withIdentifier: "DVListTableViewController")
//            navigationController?.pushViewController(tvc, animated: true)
//        }
//        
//        if section == 1 {
//            datePickerTappedForDuedateAtDateCell()
//        }
//    }
//    
//    /*
//     // Override to support conditional editing of the table view.
//     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//     // Return false if you do not want the specified item to be editable.
//     return true
//     }
//     */
//    
//    /*
//     // Override to support editing the table view.
//     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//     if editingStyle == .delete {
//     // Delete the row from the data source
//     tableView.deleteRows(at: [indexPath], with: .fade)
//     } else if editingStyle == .insert {
//     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//     }
//     }
//     */
//    
//    /*
//     // Override to support rearranging the table view.
//     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//     
//     }
//     */
//    
//    /*
//     // Override to support conditional rearranging of the table view.
//     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//     // Return false if you do not want the item to be re-orderable.
//     return true
//     }
//     */
//    
//    /*
//     // MARK: - Navigation
//     
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//     }
//     */
//    
//}
//extension DVMultipleTodoitemtaskItemsTVC: GrowingTextViewDelegate {
//    
//    // *** Call layoutIfNeeded on superview for animation when changing height ***
//    
//    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
//        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
//            self.view.layoutIfNeeded()
//        }, completion: nil)
//    }
//}

