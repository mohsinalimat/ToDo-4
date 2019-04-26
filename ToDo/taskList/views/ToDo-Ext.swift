//
//  Task.swift
//  ToDo
//
//  Created by Tuyen Le on 30.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

class ToDoCardExt: ToDoCard {

    override init(frame: CGRect) {
        super.init(frame: frame)
        progressBar.percentage = 0
        layer.cornerRadius = 0
        shadowLayer.removeFromSuperlayer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
