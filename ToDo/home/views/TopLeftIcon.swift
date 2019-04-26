//
//  TopLeftIcon.swift
//  ToDo
//
//  Created by Tuyen Le on 24.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

class TopLeftIcon: UIImageView {
    
    override init(image: UIImage?) {
        super.init(image: image)
        translatesAutoresizingMaskIntoConstraints = false
        if let img = image {
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
