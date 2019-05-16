//
//  TimePickerSoundOption.swift
//  ToDo
//
//  Created by Tuyen Le on 15.05.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit
import AVFoundation

class SoundCell: UITableViewCell {
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
}

class TimePickerSoundOption: UITableView {
    let identifier = "TimePickerSoundOption"
    
    /**
     default to the first sound
    **/
    var previousSelectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    init() {
        super.init(frame: .zero, style: .plain)
        delegate = self
        dataSource = self
        isScrollEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        register(SoundCell.self, forCellReuseIdentifier: identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TimePickerSoundOption: UITableViewDataSource {
    var sounds: [String] {
        return ["Radar", "Apex", "Beacon", "Bulletin", "By The Seaside", "Chimes", "Circuit", "Constellation", "Cosmic", "Crystals", "Hillside"]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SoundCell else {
            return UITableViewCell()
        }
        
        cell.label = sounds[indexPath.row]
        
        if indexPath.row == 0 {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    
}

extension TimePickerSoundOption: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.cellForRow(at: previousSelectedIndexPath)?.accessoryType = .none
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        previousSelectedIndexPath = indexPath
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString().bold("Sound", size: 15)
        return label
    }
}
