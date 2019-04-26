//
//  Tasks.swift
//  ToDo
//
//  Created by Tuyen Le on 31.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

class TaskTableView: UITableView {
    
    let tasksId: String = "Tasks"
    
    var tasks: [String: [String]] = [:]
    
    var taskType: Type!

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
    
    func checkboxOnTap(trashCan: UIButton, cell: UITableViewCell, indexPath: IndexPath) -> (Bool, String) -> () {
        return {
            (checked: Bool, label: String) in
            if checked {
                cell.addSubview(trashCan)
                trashCan.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
                trashCan.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -20).isActive = true
                self.checkedIndexPath.append(indexPath)
            } else {
                self.removeCheckedIndexPath(indexPath: indexPath)
                trashCan.removeFromSuperview()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "\(tasksId) \(indexPath.section)", for: indexPath)
        let trashCan: UIButton = UIButton()
        let dictionary: (key: String, value: [String]) = Array(tasks)[indexPath.section]
        
        trashCan.translatesAutoresizingMaskIntoConstraints = false
        trashCan.setImage(UIImage(named: "garbage"), for: .normal)

        // TODO: need to refactor
        if cell.subviews.count > 2 {
            let checkbox: CheckBox
            if cell.subviews.count == 4 {
                let trashCan: UIButton = cell.subviews[3] as? UIButton != nil ? cell.subviews[3] as! UIButton : cell.subviews[1] as! UIButton
                checkbox = cell.subviews[1] as? CheckBox != nil ? cell.subviews[1] as! CheckBox : cell.subviews[2] as! CheckBox


                if !self.isIndexPathChecked(indexPath: indexPath) && checkbox.checked {
                    checkbox.checked = false
                    trashCan.removeFromSuperview()
                } else if self.isIndexPathChecked(indexPath: indexPath) {
                    checkbox.checked = true
                }
                checkbox.onTapAction = checkboxOnTap(trashCan: trashCan, cell: cell, indexPath: indexPath)
            } else {
                checkbox = cell.subviews[1] as! CheckBox
                if self.isIndexPathChecked(indexPath: indexPath) {
                    checkbox.checked = true
                    
                    cell.addSubview(trashCan)
                    trashCan.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
                    trashCan.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -20).isActive = true
                }
                checkbox.onTapAction = checkboxOnTap(trashCan: trashCan, cell: cell, indexPath: indexPath)
            }

            checkbox.label = dictionary.value[indexPath.row]
            
            return cell
        }
        
        let checkbox: CheckBox = CheckBox()
        checkbox.label = dictionary.value[indexPath.row]
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        
        if self.isIndexPathChecked(indexPath: indexPath) {
            checkbox.checked = true
            cell.addSubview(trashCan)

            trashCan.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            trashCan.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -20).isActive = true
        }
        checkbox.onTapAction = checkboxOnTap(trashCan: trashCan, cell: cell, indexPath: indexPath)

        cell.addSubview(checkbox)
        checkbox.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        checkbox.widthAnchor.constraint(equalToConstant: 15).isActive = true
        checkbox.heightAnchor.constraint(equalToConstant: 15).isActive = true

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
}

extension TaskTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(tasksId) \(section)"), Array(tasks).count - 1 >= section  else { return nil }
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        let dictionary: (key: String, value: [String]) = Array(tasks)[section]
        label.textColor = UIColor.lightGray
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
        label.text = dictionary.key
        return label
    }
}

