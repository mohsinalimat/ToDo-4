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
            guard let type = taskType else { return }
            let tasks: [(String, [String])] = getTasks(type: type)
            taskTableView.tasks = tasks
            todoCard?.numOfTask = getTasksCount(type: type)
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
    func taskTableView(_ deletedTaskName: String, _ taskDateToDelete: String) {
        try! realm.write {
            deleteTask(type: taskType!, taskNameToDelete: deletedTaskName, taskDateToDelete: taskDateToDelete)  // delete task in realm
        }
        
        if let type = self.taskType {
            todoCard?.numOfTask = getTasksCount(type: type)
        }
    }
}

extension ToDoViewController: AddButtonExpandDelegate {

    /// add task
    func buttonWillShrink() {
        NotificationCenter.default.post(name: NSNotification.Name.init("buttonShrink"), object: nil)

        guard let type = taskType else { return }

        let newTasks: [(String, [String])] = getTasks(type: type)

        todoCard?.numOfTask = getTasksCount(type: type)
        taskTableView.tasks = newTasks
        taskTableView.reloadData()
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
