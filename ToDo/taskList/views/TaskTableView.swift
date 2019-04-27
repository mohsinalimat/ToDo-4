//
//  Tasks.swift
//  ToDo
//
//  Created by Tuyen Le on 31.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

protocol TaskTableViewDelegate: AnyObject {
    func taskTableView(_ deletedTaskName: String)
}

class TaskTableView: UITableView {
    
    let tasksId: String = "Tasks"
    
    var tasks: [String: [String]] = [:]
    
    weak var taskDelegate: TaskTableViewDelegate?

    var checkedIndexPath: [IndexPath] = [IndexPath]()
    
    private func isIndexPathChecked(indexPath: IndexPath) -> Bool {
        for checkedIndexPath in self.checkedIndexPath {
            if checkedIndexPath.row == indexPath.row && checkedIndexPath.section == indexPath.section {
                return true
            }
        }
        return false
    }
    
    private func removeCheckedIndexPath(indexPath: IndexPath) {
        for (index, checkedIndexPath) in self.checkedIndexPath.enumerated() {
            if checkedIndexPath.row == indexPath.row && checkedIndexPath.section == indexPath.section {
                self.checkedIndexPath.remove(at: index)
                break
            }
        }
    }
    
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
        let dictionary: (key: String, value: [String]) = Array(tasks)[indexPath.section]
        
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
            taskCell.trashCan.rightAnchor.constraint(equalTo: taskCell.rightAnchor, constant: -20).isActive = true
        }
        
        taskCell.checkbox.label = dictionary.value[indexPath.row]
        taskCell.indexPathToDelete = indexPath

        return taskCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
}

extension TaskTableView: TaskCellDelegate {
    
    /// on delete task cell
    func taskCell(_ deletedIndexPath: IndexPath, _ deletedTaskName: String) {
        removeCheckedIndexPath(indexPath: deletedIndexPath)

        let tasksName: [String] = Array(tasks)[deletedIndexPath.section].value
        let taskDate: String = Array(tasks)[deletedIndexPath.section].key
        
        if tasksName.count == 1 {
            tasks.removeValue(forKey: taskDate)
            deleteSections(IndexSet(integer: deletedIndexPath.section), with: .bottom)
        } else {
            tasks[taskDate]?.remove(at: deletedIndexPath.row)
            deleteRows(at: [deletedIndexPath], with: .automatic)
        }
        
        taskDelegate?.taskTableView(deletedTaskName) // notify toDoViewController
    }

    /// on check checkbox
    func taskCell(_ checkedIndexPath: IndexPath, _ checked: Bool) {
        if checked {
            self.checkedIndexPath.append(checkedIndexPath)
        } else {
            removeCheckedIndexPath(indexPath: checkedIndexPath)
        }
    }
}

extension TaskTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(tasksId) \(section)")  else { return nil }
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        let dictionary: (key: String, value: [String]) = Array(tasks)[section]
        label.textColor = UIColor.lightGray
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
        label.text = dictionary.key
        return label
    }
}

