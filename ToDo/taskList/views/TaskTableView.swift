//
//  Tasks.swift
//  ToDo
//
//  Created by Tuyen Le on 31.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

protocol TaskTableViewDelegate: AnyObject {
    func taskTableView(_ deletedTaskName: String, _ taskDateToDelete: String)
}

class TaskTableView: UITableView {
    // MARK: - task table view property
    
    let tasksId: String = "Tasks"
    
    /** tasks according to date in tuple **/
    var tasks: [(String, [Task])] = [(String, [Task])]()
    
    /** task delegate, need for deletion to notify controller **/
    weak var taskDelegate: TaskTableViewDelegate?

    /**
     Need to keep track of checked index path in a section.
     Because when reusing the cell, we need to determined
     whether that cell has been checked.
    **/
    var checkedIndexPaths: [IndexPath] = [IndexPath]()
    
    /**
     Need to keep track of index path that has alarm clock.
    **/
    var clockIndexPaths: [IndexPath] = [IndexPath]()
    
    //MARK: - override funcs
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        dataSource = self
        delegate = self
        allowsSelection = false
        showsVerticalScrollIndicator = false
        tableFooterView = UIView()
        bounces = false
        register(TaskCell.self, forCellReuseIdentifier: tasksId)
    }
    
    convenience init(style: UITableView.Style) {
        self.init(frame: .zero, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TaskTableView: UITableViewDataSource {
    fileprivate func isIndexPathChecked(indexPath: IndexPath) -> Bool {
        for checkedIndexPath in self.checkedIndexPaths {
            if checkedIndexPath.row == indexPath.row && checkedIndexPath.section == indexPath.section {
                return true
            }
        }
        return false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasks.count == 0 || section >= tasks.count {
            return 0
        }
        let key: (key: String, value: [Task]) = Array(tasks)[section]
        return key.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = tableView.dequeueReusableCell(withIdentifier: tasksId, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        
        if taskCell.delegate == nil {
             taskCell.delegate = self
        }
        
        if taskCell.checkbox.checked && !isIndexPathChecked(indexPath: indexPath) {
            taskCell.checkbox.checked = false
            taskCell.trashCan.removeFromSuperview()
        } else if !taskCell.checkbox.checked && isIndexPathChecked(indexPath: indexPath) {
            taskCell.checkbox.checked = true
            taskCell.addSubview(taskCell.trashCan)
            taskCell.trashCan.centerYAnchor.constraint(equalTo: taskCell.centerYAnchor).isActive = true
            taskCell.trashCan.rightAnchor.constraint(equalTo: taskCell.rightAnchor).isActive = true
        }
        
        let task = tasks[indexPath.section].1[indexPath.row]
        let dueDateComponent = Calendar.current.dateComponents([.hour, .minute, .year], from: task.date!)
        
        taskCell.alarmClock.removeFromSuperview()
        
        if let hour = dueDateComponent.hour, let minute = dueDateComponent.minute {
            taskCell.alarmClock.setTitle("\(hour):\(minute)", for: .normal)
            taskCell.addSubview(taskCell.alarmClock)
            taskCell.alarmClock.centerYAnchor.constraint(equalTo: taskCell.centerYAnchor).isActive = true
            taskCell.alarmClock.centerXAnchor.constraint(equalTo: taskCell.centerXAnchor, constant: 80).isActive = true
        }

        taskCell.checkbox.label = task.name!
        taskCell.indexPathToDelete = indexPath

        return taskCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
}

extension TaskTableView: TaskCellDelegate {

    /**
     Do this after deletion for the row below the deleted index path.
    **/
    fileprivate func updateRowCheckIndexPath(_ deletedIndexPath: IndexPath) {
        let deletedSection: Int = deletedIndexPath.section
        let deletedRow: Int = deletedIndexPath.row

        for (index, checkedIndexPath) in checkedIndexPaths.enumerated() {
            if checkedIndexPath.section == deletedSection && checkedIndexPath.row > deletedRow {
                checkedIndexPaths[index].row = checkedIndexPaths[index].row - 1
            }
        }
    }
    
    /**
     Do this after deletion for thesection below the deleted index path.
     In case there are checkboxes being checked for sections below the
     deleted section, decrement the section by 1
    **/
    fileprivate func updateSectionCheckIndexPath(_ deletedIndexPath: IndexPath) {
        let deletedSection: Int = deletedIndexPath.section
        
        for (index, checkedIndexPath) in checkedIndexPaths.enumerated() {
            if checkedIndexPath.section > deletedSection {
                checkedIndexPaths[index].section = checkedIndexPaths[index].section - 1
            }
        }
    }
    
    fileprivate func removeCheckedIndexPath(_ indexPath: IndexPath) {
        for (index, checkedIndexPath) in self.checkedIndexPaths.enumerated() {
            if checkedIndexPath.row == indexPath.row && checkedIndexPath.section == indexPath.section {
                self.checkedIndexPaths.remove(at: index)
                break
            }
        }
    }

    /// on delete task cell
    func taskCell(_ deletedIndexPath: IndexPath, _ deletedTaskName: String) {
        let taskDate: String = tasks[deletedIndexPath.section].0
        
        removeCheckedIndexPath(deletedIndexPath)

        if tasks[deletedIndexPath.section].1.count == 1 {       // remove section if there is only 1 task left
            tasks.remove(at: deletedIndexPath.section)
            deleteSections(IndexSet(integer: deletedIndexPath.section), with: .bottom)
            updateSectionCheckIndexPath(deletedIndexPath)
            reloadData()
        } else {
            updateRowCheckIndexPath(deletedIndexPath)
            tasks[deletedIndexPath.section].1.remove(at: deletedIndexPath.row)
            deleteRows(at: [deletedIndexPath], with: .bottom)
            reloadSections(IndexSet(integer: deletedIndexPath.section), with: .none)
        }

        taskDelegate?.taskTableView(deletedTaskName, taskDate) // notify toDoViewController
    }

    /// save checked indexPath
    func taskCell(_ checkedIndexPath: IndexPath, _ checked: Bool) {
        if checked {
            self.checkedIndexPaths.append(checkedIndexPath)
        } else {
            removeCheckedIndexPath(checkedIndexPath)
        }
    }
}

extension TaskTableView: UITableViewDelegate {
    func date(date: String) -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: date)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: UILabel = UILabel()
        let taskDate: DateComponents = Calendar.current.dateComponents([.day, .month], from: date(date: tasks[section].0)!)
        let present: DateComponents = Calendar.current.dateComponents([.day, .month], from: Date())

        if taskDate.day! < present.day! && taskDate.month! <= present.month! {
            label.attributedText = NSMutableAttributedString().normal("\(tasks[section].0)").bold(" - past due", size: nil)
        } else {
            label.attributedText = NSMutableAttributedString().normal("\(tasks[section].0)")
        }
        
        return label
    }
}

