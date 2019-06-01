//
//  TimePickerSoundOption.swift
//  ToDo
//
//  Created by Tuyen Le on 15.05.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit
import AVFoundation

class ReminderCell: UITableViewCell {
    var imageViewd: UIImageView?
    
    var label: String? {
        didSet {
            guard let soundLabel = label  else { return }
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = soundLabel

            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    var switchReminder: UISwitch = {
        let switchReminder = UISwitch()
        switchReminder.translatesAutoresizingMaskIntoConstraints = false
        switchReminder.isOn = false
        return switchReminder
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(switchReminder)
        switchReminder.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        switchReminder.heightAnchor.constraint(equalToConstant: frame.height/2).isActive = true
        switchReminder.widthAnchor.constraint(equalToConstant: 50).isActive = true
        switchReminder.topAnchor.constraint(equalTo: topAnchor, constant: frame.height/6).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Reminder: UITableView {
    let identifier = "TimePickerSoundOption"
    
    private(set) var isReminderOn: Bool = false

    init() {
        super.init(frame: .zero, style: .plain)
        dataSource = self
        allowsSelection = false
        isScrollEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        register(ReminderCell.self, forCellReuseIdentifier: identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reminder: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    @objc fileprivate func reminderToggleAction() {
        isReminderOn = !isReminderOn
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reminder = tableView.dequeueReusableCell(withIdentifier: identifier) as? ReminderCell else {
            return UITableViewCell()
        }
        
        if reminder.subviews.count == 3 {
            reminder.switchReminder.isOn = false
            isReminderOn = false
            return reminder
        }
        reminder.switchReminder.addTarget(self, action: #selector(reminderToggleAction), for: .valueChanged)
        reminder.label = "Remind me on this day"
        return reminder
    }
}
