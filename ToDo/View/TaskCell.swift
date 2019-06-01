//
//  TaskCell.swift
//  ToDo
//
//  Created by Tuyen Le on 26.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

protocol TaskCellDelegate: AnyObject {
    func taskCell(_ checkedIndexPath: IndexPath, _ checked: Bool)
    func taskCell(_ deletedIndexPath: IndexPath)
}

class TaskCell: UITableViewCell {
    
    weak var delegate: TaskCellDelegate?
    
    var indexPathToDelete: IndexPath!
    
    lazy var checkbox: CheckBox = {
        let checkbox: CheckBox = CheckBox()
        checkbox.onTapAction = {
            (checked: Bool, label: String) in
            if checked {
                self.addSubview(self.trashCan)
                self.trashCan.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                self.trashCan.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            } else {
                self.trashCan.removeFromSuperview()
            }
            self.delegate?.taskCell(self.indexPathToDelete, checked)
        }
        return checkbox
    }()

    lazy var trashCan: UIButton = {
        let trashCan: UIButton = UIButton()
        trashCan.setImage(UIImage(named: "garbage"), for: .normal)
        trashCan.translatesAutoresizingMaskIntoConstraints = false
        trashCan.addTarget(self, action: #selector(trashCanOnTap), for: .touchUpInside)
        return trashCan
    }()
    
    var alarmClock: UIButton = {
        let alarmClock = UIButton()
        alarmClock.setImage(UIImage(named: "clock"), for: .normal)
        alarmClock.setTitleColor(.black, for: .normal)
        alarmClock.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        alarmClock.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        alarmClock.imageEdgeInsets = UIEdgeInsets(top: 0, left: -50, bottom: 0, right: 0)
        alarmClock.translatesAutoresizingMaskIntoConstraints = false
        return alarmClock
    }()
    
    @objc func trashCanOnTap() {
        checkbox.checked = false
        trashCan.removeFromSuperview()
        delegate?.taskCell(indexPathToDelete)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        checkbox.translatesAutoresizingMaskIntoConstraints = false

        addSubview(checkbox)
        
        checkbox.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        checkbox.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        checkbox.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkbox.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}