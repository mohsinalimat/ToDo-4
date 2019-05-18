//
//  ToDoControllerViewController.swift
//  ToDo
//
//  Created by Tuyen Le on 29.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit
import AddButtonExpand
import UserNotifications
import AVFoundation

class ToDoViewController: UIViewController {
    
    var reminderOption: Reminder = Reminder()

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
    var timerPickedComponent: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
    
    /**
     number of notification appear on app icon
    **/
    var totalNotification: Int = 0
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Tasks"
        reminderOption.separatorStyle = .none
        navigationController?.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backArrowAction))
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
        todoViewModel.deleteTask(taskNameToDelete: deletedTaskName, taskDateToDelete: taskDateToDelete)
        todoCard?.numOfTask = todoViewModel.tasksCount
        let percentage: Int = todoViewModel.tasksCompletedPercentage
        todoCard?.progressBar.setPercentage(percentage, animated: true)
        if todoCard?.progressBar.percentage == 100 {
            todoViewModel.resetCompletedTask()
        }
    }
}

extension ToDoViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 24
        } else if component == 1 {
            return 60
        }
        return 2
    }

}

extension ToDoViewController: UIPickerViewDelegate {
    var hours: [String] {
        let hour = 24
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
                minutes.append("\(i)")
            } else {
                minutes.append(String(i))
            }
        }
        return minutes
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return hours[row]
        } else {
            return minutes[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let hour = Int(hours[row])
            timerPickedComponent.setValue(hour, for: .hour)
        } else if component == 1 {
            let minute = Int(minutes[row])
            timerPickedComponent.setValue(minute, for: .minute)
        }
    }
}

extension ToDoViewController: AddButtonExpandDelegate {
    /// add time picker and uiswitch inside blur view
    var blurView: UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        let timePicker = UIPickerView()
        let hour = timerPickedComponent.hour! == 0 ? 23 : timerPickedComponent.hour!
        let minute = timerPickedComponent.minute! - 1

        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.showsSelectionIndicator = true
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.selectRow(hour , inComponent: 0, animated: true)
        timePicker.selectRow(minute, inComponent: 1, animated: true)

        blurredView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView.contentView.addSubview(timePicker)
        blurredView.contentView.addSubview(reminderOption)
        blurredView.frame = view.frame
        
        timePicker.widthAnchor.constraint(equalToConstant: blurredView.frame.width).isActive = true
        timePicker.heightAnchor.constraint(equalToConstant: 150).isActive = true
        timePicker.topAnchor.constraint(equalTo: blurredView.topAnchor, constant: navigationController!.navigationBar.frame.height * 2).isActive = true
        timePicker.leftAnchor.constraint(equalTo: blurredView.leftAnchor).isActive = true

        reminderOption.widthAnchor.constraint(equalToConstant: blurredView.frame.width).isActive = true
        reminderOption.heightAnchor.constraint(equalToConstant: 45).isActive = true
        reminderOption.topAnchor.constraint(equalTo: blurredView.topAnchor, constant: timePicker.bounds.maxY + 50).isActive = true
        reminderOption.leftAnchor.constraint(equalTo: blurredView.leftAnchor).isActive = true
        
        return blurredView
    }
    
    /**
     go back to home controller.
     Reset sound option to the default selection
     **/
    @objc func backArrowAction() {
        if view.subviews.count == 4 {
            navigationItem.rightBarButtonItem = nil
            title = "Tasks"
            resetReminderOptionAndTimer()
            view.subviews[3].removeFromSuperview()
            scrollToNewTask()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func resetReminderOptionAndTimer() {
        // reset to current time
        timerPickedComponent = Calendar.current.dateComponents([.hour, .minute], from: Date())
        // reset reminder switch to false
        reminderOption.reloadData()
    }
    
    /// scroll to newly added task and reload
    fileprivate func scrollToNewTask() {
        guard let recentlyAddedTask = todoViewModel.recentlyAddedTask else { return }
        let recentlyAddedTaskDate = todoViewModel.dateString(date: recentlyAddedTask.date!)
        for (dateSection, date) in taskTableView.tasks.enumerated() {
            if date.0 == recentlyAddedTaskDate {
                for (taskRow, task) in date.1.enumerated() {
                    if task.name! == recentlyAddedTask.name! {
                        let scrollToIndexPath = IndexPath(row: taskRow, section: dateSection)
                        taskTableView.reloadRows(at: [scrollToIndexPath], with: .none)
                        taskTableView.scrollToRow(at: scrollToIndexPath, at: .top, animated: true)
                        break
                    }
                }
            }
        }
    }
    
    /// save timer
    @objc func saveTimer() {
        if view.subviews.count == 4 {
            title = "Tasks"
            navigationItem.rightBarButtonItem = nil
            view.subviews[3].removeFromSuperview()
            
            let hour = timerPickedComponent.hour!
            let minute = timerPickedComponent.minute!

            todoViewModel.saveTimer(hour: hour, minute: minute)
            
            resetReminderOptionAndTimer()

            // scroll to newly added task and reload
            scrollToNewTask()
            
            // add notification
            addNotification()
            
        }
    }
    
    /// add notification to app when it's due date and time
    fileprivate func addNotification() {
        guard let recentlyAddedTask = todoViewModel.recentlyAddedTask else { return }

        let content = UNMutableNotificationContent()
        content.title = "To Do"
        content.body = recentlyAddedTask.name!
        
        if reminderOption.isReminderOn {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Marimba-notification.caf"))
        }

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: recentlyAddedTask.date!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.delegate = self
        
        notificationCenter.requestAuthorization(options: [.alert, .sound], completionHandler: {
            (success, error) in
            if error != nil {
                print("notification request error: ", error!)
            }
        })
        notificationCenter.add(request, withCompletionHandler: {
            (error) in
            if error != nil {
                print("notification error: ", error!)
            }
        })
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

        view.addSubview(blurView)
        title = "Add Alarm"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(saveTimer))
    }
    
    
    /// open new task controller from delegate
    func buttonWillExpand() {
        let addTaskController: AddTaskController = AddTaskController(type: taskType!)
        addTaskController.modalPresentationStyle = .custom
        addTaskController.transitioningDelegate = self

        present(addTaskController, animated: true, completion: nil)
    }
}

extension ToDoViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // TODO: go to view controller from notification
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
