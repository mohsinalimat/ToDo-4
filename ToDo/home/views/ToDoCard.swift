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

struct TopRightIconContraint {
    var right: NSLayoutConstraint!
    var top: NSLayoutConstraint!
}

class Icon: UIImageView {

    init(encircle: Bool, image: UIImage?) {
        super.init(image: image)
        translatesAutoresizingMaskIntoConstraints = false
        if let img = image, encircle {
            let circle: CAShapeLayer = CAShapeLayer()
            circle.strokeColor = UIColor.black.cgColor
            circle.fillColor = nil
            circle.lineWidth = 0.5
            let radius: CGFloat = img.size.width > img.size.height ? img.size.width : img.size.height
            circle.path = UIBezierPath(arcCenter: center,
                                       radius: radius,
                                       startAngle: 0,
                                       endAngle: 2 * .pi,
                                       clockwise: true).cgPath
            layer.addSublayer(circle)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ToDoCard: UICollectionViewCell {
    
    var topLeftIcon: Icon = Icon(encircle: true, image: UIImage(named: "personal"))
    
    var topLeftIconContraint: TopLeftIconConstraint = TopLeftIconConstraint()
    
    var moreIcon: Icon = Icon(encircle: false, image: UIImage(named: "more"))
    
    var moreIconContraint: TopRightIconContraint = TopRightIconContraint()
    
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
    
    lazy var numOfTaskLayer: CATextLayer = {
        let label: CATextLayer = CATextLayer()
        label.string = "\(numOfTask) Tasks"
        label.font =  CTFontCreateWithName("AppleSDGothicNeo-SemiBold" as CFString, 0, nil)
        label.foregroundColor = UIColor.lightGray.cgColor
        label.fontSize = 12
        label.contentsScale = UIScreen.main.scale
        label.frame = CGRect(x: frame.width/15,
                             y: taskTypeLabelLayer.frame.minY - label.preferredFrameSize().height*1.5,
                             width: label.preferredFrameSize().width * 1.5,
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
        addSubview(moreIcon)
        
        // auto layout for top right icon
        moreIconContraint.top = moreIcon.topAnchor.constraint(equalTo: topAnchor, constant: 15)
        moreIconContraint.right = moreIcon.rightAnchor.constraint(equalTo: rightAnchor, constant: -frame.width/10)
        moreIconContraint.top.isActive = true
        moreIconContraint.right.isActive = true
        
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
        moreIcon.removeFromSuperview()
        progressBar.removeFromSuperview()
        
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
