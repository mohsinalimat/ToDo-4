//
//  ToDoControllerViewController.swift
//  ToDo
//
//  Created by Tuyen Le on 29.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit
import AddButtonExpand

class ToDoViewController: UIViewController {

    lazy var todoViewModel: ToDoViewModel = {
        return ToDoViewModel(taskType: taskType!)
    }()

    lazy var addButtonExpand: AdddButtonExpand = {
        let button: AdddButtonExpand = AdddButtonExpand(frame: CGRect(x: view.bounds.maxX - 80,
                                                                      y: view.bounds.maxY - 80,
                                                                      width: 40,
                                                                      height: 40))
        button.addButtonDelegate = self
        button.animateDuration = 0.1
        return button
    }()
    
    var taskTableView: TaskTableView = TaskTableView(style: UITableView.Style.plain)
    
    /**
     default to current hour and minute when picking timer
    **/
    var datePickedComponent: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
    
    var todoCard: ToDoCardExt? {
        didSet {
            guard let todoCard = todoCard else { return }
    
            view.addSubview(todoCard)

            taskTableView.translatesAutoresizingMaskIntoConstraints = false
            taskTableView.taskDelegate = self

            view.addSubview(taskTableView)
            taskTableView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/1.3).isActive = true
            taskTableView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - todoCard.frame.maxY).isActive = true
            taskTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: todoCard.frame.maxY).isActive = true
            taskTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: UIScreen.main.bounds.width/5.9).isActive = true
            view.insertSubview(addButtonExpand, aboveSubview: taskTableView)
        }
    }
    
    var taskType: Type? {
        didSet {
            guard let _ = taskType else { return }

            taskTableView.tasks = todoViewModel.tasks
            todoCard?.numOfTask = todoViewModel.tasksCount
        }
    }
    
    /// go back to home controller
    @objc func leftBarButtonAction() {
        if view.subviews.count == 4 {
            navigationItem.rightBarButtonItem = nil
            title = "Tasks"
            view.subviews[3].removeFromSuperview()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Tasks"
        navigationController?.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(leftBarButtonAction))
    }
    
    override func viewDidLayoutSubviews() {
        taskTableView.separatorInset = .zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ToDoViewController: TaskTableViewDelegate {
    /// delete task in realm
    func taskTableView(_ deletedTaskName: String, _ taskDateToDelete: String) {
        try! realm.write {
            todoViewModel.deleteTask(taskNameToDelete: deletedTaskName, taskDateToDelete: taskDateToDelete)
            todoCard?.numOfTask = todoViewModel.tasksCount
            let percentage: Int = todoViewModel.tasksCompletedPercentage
            todoCard?.progressBar.setPercentage(percentage, animated: true)
            if todoCard?.progressBar.percentage ==  100 {
                todoViewModel.resetCompletedTask()
            }
        }
    }
}

extension ToDoViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12
        } else if component == 1 {
            return 60
        }
        return 2
    }
    
    
}

extension ToDoViewController: UIPickerViewDelegate {
    var hours: [String] {
        let hour = 12
        var hours: [String] = [String]()
        for i in 1...hour {
            hours.append(String(i))
        }
        return hours
    }
    
    var minutes: [String] {
        let minute = 60
        var minutes: [String] = [String]()
        for i in 1...minute {
            if i < 10 {
                minutes.append("0\(i)")
            } else {
                minutes.append(String(i))
            }
        }
        return minutes
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return hours[row]
        } else if component == 1 {
            return minutes[row]
        } else {
            if row == 0 {
                return "AM"
            } else {
                return "PM"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let date = todoViewModel.recentlyAddedTask?.date
        var dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: date!)

        if component == 0 {
            let hour = Int(hours[row])
            dateComponent.setValue(hour, for: .hour)
            datePickedComponent = dateComponent
        } else if component == 1 {
            let minute = Int(minutes[row])
            dateComponent.setValue(minute, for: .minute)
            datePickedComponent = dateComponent
        }
    }
}

extension ToDoViewController: AddButtonExpandDelegate {
    var blurView: UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        let timePicker = UIPickerView()
        let currentTime = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let hour = Int(floor(Double(currentTime.hour!) / 2.0))
        let minute = currentTime.minute!

        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.showsSelectionIndicator = true
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.selectRow(hour - 1, inComponent: 0, animated: true)
        timePicker.selectRow(minute, inComponent: 1, animated: true)

        blurredView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView.contentView.addSubview(timePicker)
        blurredView.frame = CGRect(x: 0,
                                   y: -navigationController!.navigationBar.frame.height,
                                   width: view.bounds.width,
                                   height: view.bounds.height + navigationController!.navigationBar.frame.height)
        
        timePicker.widthAnchor.constraint(equalToConstant: blurredView.frame.width).isActive = true
        timePicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
        timePicker.centerYAnchor.constraint(equalTo: blurredView.centerYAnchor).isActive = true
        timePicker.leftAnchor.constraint(equalTo: blurredView.leftAnchor).isActive = true
        
        return blurredView
    }
    
    /// save timer
    @objc func saveTimer() {
        if view.subviews.count == 4 {
            title = "Tasks"
            navigationItem.rightBarButtonItem = nil
            view.subviews[3].removeFromSuperview()
            
            guard let recentlyAddedTask = todoViewModel.recentlyAddedTask else { return }
            let recentlyAddedTaskDate = todoViewModel.dateString(date: recentlyAddedTask.date!)
            
            todoViewModel.saveDate(datePickedComponent)

            // scroll to newly added task
            for (dateSection, date) in taskTableView.tasks.enumerated() {
                if date.0 == recentlyAddedTaskDate {
                    for (taskRow, task) in date.1.enumerated() {
                        if task == recentlyAddedTask.name! {
                            let scrollToIndexPath = IndexPath(row: taskRow, section: dateSection)
                            taskTableView.scrollToRow(at: scrollToIndexPath, at: .top, animated: true)
                            break
                        }
                    }
                }
            }

        }
    }

    /// add task from delegate
    func buttonWillShrink() {
        NotificationCenter.default.post(name: NSNotification.Name.init("buttonShrink"), object: nil)

        guard let _ = taskType,
              let todoCard = todoCard, todoCard.numOfTask < todoViewModel.tasksCount else { return }

        let percentage: Int = todoViewModel.tasksCompletedPercentage

        todoCard.numOfTask = todoViewModel.tasksCount
        todoCard.progressBar.setPercentage(percentage, animated: true)
        taskTableView.tasks = todoViewModel.tasks   // new task
        taskTableView.reloadData()

        // TODO: add time picker
        view.addSubview(blurView)
        title = "Add Alarm"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(saveTimer))
    }
    
    
    /// open new task controller
    func buttonWillExpand() {
        let addTaskController: AddTaskController = AddTaskController(type: taskType!)
        addTaskController.modalPresentationStyle = .custom
        addTaskController.transitioningDelegate = self

        present(addTaskController, animated: true, completion: nil)
    }
}

extension ToDoViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AddTaskPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension ToDoViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ToDoCardDismissAnimator()
    }
}
