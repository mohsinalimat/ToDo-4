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

    @objc func leftBarButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    lazy var todoViewModel: ToDoViewModel = {
        return ToDoViewModel(taskType: taskType!)
    }()

    lazy var addButtonExpand: AdddButtonExpand = {
        let button: AdddButtonExpand = AdddButtonExpand(frame: CGRect(x: view.bounds.maxX - 80,
                                                                      y: view.bounds.maxY - 80,
                                                                      width: 40,
                                                                      height: 40))
        button.addButtonDelegate = self
        button.animateDuration = 0.5
        return button
    }()
    
    var taskTableView: TaskTableView = TaskTableView(style: UITableView.Style.plain)
    
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

extension ToDoViewController: AddButtonExpandDelegate {

    /// add task
    func buttonWillShrink() {
        NotificationCenter.default.post(name: NSNotification.Name.init("buttonShrink"), object: nil)

        guard let _ = taskType else { return }

        let newTasks: [(String, [String])] = todoViewModel.tasks
        let percentage: Int = todoViewModel.tasksCompletedPercentage

        todoCard?.numOfTask = todoViewModel.tasksCount
        todoCard?.progressBar.setPercentage(percentage, animated: true)
        taskTableView.tasks = newTasks
        taskTableView.reloadData()

        // TODO: add time picker
    }
    
    
    /// open new task controller
    func buttonWillExpand() {
        let addTaskController: AddTaskController = AddTaskController(type: taskType!)
        addTaskController.modalPresentationStyle = .custom
        addTaskController.transitioningDelegate = self

        present(addTaskController, animated: false, completion: nil)
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
