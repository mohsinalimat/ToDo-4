//
//  NewCategoryCard.swift
//  ToDo
//
//  Created by Tuyen Le on 07.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

class NewCategoryCard: ToDoCard {
    
    lazy var label: UILabel = {
        let label: UILabel = UILabel()
        label.text = "Add Category"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        taskTypeLabelLayer.removeFromSuperlayer()
        numOfTaskLayer.removeFromSuperlayer()
        topLeftIcon.removeFromSuperview()
        progressBar.removeFromSuperview()
        
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
