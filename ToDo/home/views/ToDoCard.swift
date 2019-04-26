//
//  ToDoCard.swift
//  ToDo
//
//  Created by Tuyen Le on 24.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit
import ProgressBar

struct TopLeftIconConstraint {
    var top: NSLayoutConstraint!
    var left: NSLayoutConstraint!
}


class ToDoCard: UICollectionViewCell {
    
    var topLeftIcon: TopLeftIcon = TopLeftIcon(image: UIImage(named: "personal"))
    
    var numOfTask: Int = 0 {
        didSet {
            numOfTaskLayer.string = "\(numOfTask) Tasks"
        }
    }
    
    var taskType: String = "Other" {
        didSet {
            taskTypeLabelLayer.string = taskType
        }
    }
    
    var progressBar: ProgressBar!
    
    var topLeftIconContraint: TopLeftIconConstraint = TopLeftIconConstraint()
    
    lazy var numOfTaskLayer: CATextLayer = {
        let label: CATextLayer = CATextLayer()
        label.string = "\(numOfTask) Tasks"
        label.font =  CTFontCreateWithName("AppleSDGothicNeo-SemiBold" as CFString, 0, nil)
        label.foregroundColor = UIColor.lightGray.cgColor
        label.fontSize = 12
        label.contentsScale = UIScreen.main.scale
        label.frame = CGRect(x: frame.width/15,
                             y: taskTypeLabelLayer.frame.minY - label.preferredFrameSize().height*1.5,
                             width: label.preferredFrameSize().width,
                             height: label.preferredFrameSize().height)
        return label
    }()
    
    lazy var taskTypeLabelLayer: CATextLayer = {
        let label: CATextLayer = CATextLayer()
        label.string = taskType
        label.font =  CTFontCreateWithName("AppleSDGothicNeo-Regular" as CFString, 0, nil)
        label.foregroundColor = UIColor.darkGray.cgColor
        label.fontSize = 25
        label.contentsScale = UIScreen.main.scale
        label.frame = CGRect(x: frame.width/15,
                             y: bounds.maxY - label.preferredFrameSize().height*2,
                             width: bounds.width - frame.width/15,
                             height: label.preferredFrameSize().height)
        return label
    }()
    
    lazy var shadowLayer: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        
        shadowLayer.shadowColor = UIColor.darkGray.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 10
        
        
        return shadowLayer
    }()
    
    func defaultSetup() {
        backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 1.0)
        progressBar = ProgressBar(frame: CGRect(x: frame.width/15, y: bounds.maxY - 20, width: bounds.width - 15, height: 5))
        
        layer.cornerRadius = 10
        layer.insertSublayer(shadowLayer, at: 0)
        layer.addSublayer(taskTypeLabelLayer)
        layer.addSublayer(numOfTaskLayer)

        addSubview(topLeftIcon)
        addSubview(progressBar)
        
        // auto layout for top left icon
        topLeftIconContraint.top = topLeftIcon.topAnchor.constraint(equalTo: topAnchor, constant: 20)
        topLeftIconContraint.left = topLeftIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: frame.width/10)
        topLeftIconContraint.top.isActive = true
        topLeftIconContraint.left.isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
