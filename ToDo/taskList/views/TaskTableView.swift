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
    
    /** task reuseable id **/
    let tasksId: String = "Tasks"
    
    
    /** tasks according to date in tuple **/
    var tasks: [(String, [String])] = [(String, [String])]()
    
    /** task delegate, need for deletion to notify controller **/
    weak var taskDelegate: TaskTableViewDelegate?

    /**
     Need to keep track of checked index path in a section.
     Because when reusing the cell, we need to determined
     whether that cell has been checked.
    **/
    var checkedIndexPaths: [IndexPath] = [IndexPath]()
    
    func isIndexPathChecked(indexPath: IndexPath) -> Bool {
        for checkedIndexPath in self.checkedIndexPaths {
            if checkedIndexPath.row == indexPath.row && checkedIndexPath.section == indexPath.section {
                return true
            }
        }
        return false
    }
    
    func removeCheckedIndexPath(indexPath: IndexPath) {
        for (index, checkedIndexPath) in self.checkedIndexPaths.enumerated() {
            if checkedIndexPath.row == indexPath.row && checkedIndexPath.section == indexPath.section {
                self.checkedIndexPaths.remove(at: index)
                break
            }
        }
    }
    
    //MARK: - override funcs
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        dataSource = self
        delegate = self
        allowsSelection = false
        showsVerticalScrollIndicator = false
        tableFooterView = UIView()
        bounces = false
    }
    
    convenience init(style: UITableViewStyle) {
        self.init(frame: .zero, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TaskTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasks.count == 0 || section >= tasks.count {
            return 0
        }
        let key: (key: String, value: [String]) = Array(tasks)[section]
        return key.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "\(tasksId) \(indexPath.section)", for: indexPath) as? TaskCell else {
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

        taskCell.checkbox.label = tasks[indexPath.section].1[indexPath.row]
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
     This happen when the checkbox below the deleted one has the old
     checkedIndexPath because it needs to move up one row after the one
     above it is deleted
    **/
    func updateCheckIndexPath(_ deletedIndexPath: IndexPath) {
        let deletedSection: Int = deletedIndexPath.section
        let deletedRow: Int = deletedIndexPath.row
        
        // TODO: fix indexPathToDelete for row below deletedIndexPath
        for (index, checkedIndexPath) in checkedIndexPaths.enumerated() {
            if checkedIndexPath.section == deletedSection && checkedIndexPath.row > deletedRow {
                checkedIndexPaths[index].row = checkedIndexPaths[index].row - 1
            }
        }
    }

    /// on delete task cell
    func taskCell(_ deletedIndexPath: IndexPath, _ deletedTaskName: String) {
        let tasksName: [String] = tasks[deletedIndexPath.section].1
        let taskDate: String = tasks[deletedIndexPath.section].0
        
        removeCheckedIndexPath(indexPath: deletedIndexPath)

        if tasksName.count == 1 {                       // remove section if there is only 1 task left
            tasks.remove(at: deletedIndexPath.section)
            deleteSections(IndexSet(integer: deletedIndexPath.section), with: .bottom)
        } else {
            tasks[deletedIndexPath.section].1.remove(at: deletedIndexPath.row)
            deleteRows(at: [deletedIndexPath], with: .bottom)
            updateCheckIndexPath(deletedIndexPath)
            reloadSections(IndexSet(integer: deletedIndexPath.section), with: .none)
        }

        taskDelegate?.taskTableView(deletedTaskName, taskDate) // notify toDoViewController
    }

    /// on check checkbox
    func taskCell(_ checkedIndexPath: IndexPath, _ checked: Bool) {
        if checked {
            self.checkedIndexPaths.append(checkedIndexPath)
        } else {
            removeCheckedIndexPath(indexPath: checkedIndexPath)
        }
    }
}

extension TaskTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(tasksId) \(section)")  else { return nil }
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        let taskDate: DateComponents = Calendar.current.dateComponents([.day, .month], from: date(date: tasks[section].0)!)
        let present: DateComponents = Calendar.current.dateComponents([.day, .month], from: Date())

        if taskDate.day! < present.day! && taskDate.month! <= present.month! {
            label.attributedText = NSMutableAttributedString().normal("\(tasks[section].0)").bold(" - past due")
        } else {
            label.attributedText = NSMutableAttributedString().normal("\(tasks[section].0)")
        }
        
        return label
    }
}

