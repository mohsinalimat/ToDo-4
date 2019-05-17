//
//  AddTaskController.swift
//
//  This file is responsible for adding new task
//  according to task type
//
//  Created by Tuyen Le on 05.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit
import AddButtonExpand
import SingleDatePickerCalendar

class AddTaskController: UIViewController {
    
    var dateSelected: Date?
    
    var type: Type
    
    lazy var todoViewModel: ToDoViewModel = {
        return ToDoViewModel(taskType: type)
    }()

    lazy var inputTask: UITextField = {
        let text: UITextField = UITextField()
        text.becomeFirstResponder()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.tintColor = .lightGray
        return text
    }()

    lazy var crossOut: UIButton = {
        let image: UIButton = UIButton()
        image.setImage(UIImage(named: "crossOutBlack"), for: .normal)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.addTarget(self, action: #selector(cancelTask), for: .touchUpInside)
        return image
    }()

    lazy var taskTypeQuestion: UILabel = {
        let label: UILabel = UILabel()
        label.text = "What tasks are you planning to perform?"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var newTaskLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "New Task"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 20)
        return label
    }()

    lazy var singleDatePickerCalendar: SingleDatePickerCalendar = {
        let singleDatePickerCalendar: SingleDatePickerCalendar = SingleDatePickerCalendar(frame: CGRect(x: 0, y: 160, width: view.frame.width, height: 300))
        singleDatePickerCalendar.singleDatePickerDelegate = self
        return singleDatePickerCalendar
    }()

    @objc func addButtonShrink() {
        if inputTask.text != "" && dateSelected != nil {
            let newTask = Task(name: inputTask.text!, date: dateSelected!)
            todoViewModel.saveTask(newTask)
            dismiss(animated: true, completion: nil)
            inputTask.resignFirstResponder()
        }        
        else {
            let rootVC = UIApplication.shared.windows.last?.rootViewController
            let alert = UIAlertController(title: "Error", message: "Missing date or task description", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            guard rootVC != nil else { return }
            rootVC!.present(alert, animated: true, completion: nil)
        }
    }

    @objc func cancelTask() {
        dismiss(animated: true, completion: nil)
        inputTask.resignFirstResponder()
    }

    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let currentMonth: Int = Calendar.current.component(.month, from: Date()) - 1

        view.addSubview(inputTask)
        view.addSubview(newTaskLabel)
        view.addSubview(taskTypeQuestion)
        view.addSubview(crossOut)
        view.addSubview(singleDatePickerCalendar)
        
        singleDatePickerCalendar.scrollToItem(at: IndexPath(row: currentMonth, section: 0), at: .centeredVertically, animated: true)

        newTaskLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newTaskLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true

        taskTypeQuestion.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        taskTypeQuestion.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true

        inputTask.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        inputTask.topAnchor.constraint(equalTo: view.topAnchor, constant: 130).isActive = true

        crossOut.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        crossOut.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true

        NotificationCenter.default.addObserver(self, selector: #selector(addButtonShrink),
                                               name: NSNotification.Name.init("buttonShrink"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AddTaskController: SingleDatePickerCalendarDelegate {
    func singleDatePickerCalendar(_ dateSelected: DateComponents) {
        let calendar: Calendar = Calendar(identifier: .gregorian)
        let date: Date = calendar.date(from: dateSelected)!
        self.dateSelected = date
    }
}
