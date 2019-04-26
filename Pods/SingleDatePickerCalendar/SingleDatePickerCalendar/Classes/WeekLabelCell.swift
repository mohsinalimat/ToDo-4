//
//  WeekLabelCell.swift
//  FBSnapshotTestCase
//
//  Created by Tuyen Le on 15.04.19.
//

import UIKit

class WeekLabelCell: UICollectionViewCell {
    open var label: String? {
        didSet {
            let newLabel: UILabel = UILabel()
            newLabel.text = label
            newLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(newLabel)
            if #available(iOS 9.0, *) {
                newLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                newLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            }
        }
    }
}
