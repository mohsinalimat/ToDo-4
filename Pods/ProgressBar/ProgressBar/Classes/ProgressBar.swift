

//
//  ProgressBar.swift
//  ProgressBarDemo
//
//  Created by Tuyen Le on 22.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

open
class ProgressBar: UIView {
    
    /// gradient layer
    private
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.mask = shape
        gradientLayer.anchorPoint = CGPoint(x: 0, y: 0)
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = CGRect(x: bounds.origin.x,
                                     y: bounds.origin.y,
                                     width: bounds.width/1.3,
                                     height: bounds.height)
        gradientLayer.colors = [
            UIColor(red: 0.37, green: 0.63, blue: 0.85, alpha: 1.0),
            UIColor(red: 0.58, green: 0.42, blue: 0.98, alpha: 1.0).cgColor,
        ]
        
        return gradientLayer
    }()
    
    /// percentage
    open var percentage: Int = 0 {
        didSet {
            percentageLabel.text = "\(percentage) %"
            self.animatePercentage()
        }
    }
    
    /// percentage label font size
    open var fontSize: CGFloat = 10 {
        didSet {
            percentageLabel.font = UIFont(name: font, size: fontSize)
        }
    }
    
    /// percentage label family font
    open var font: String = "TimesNewRomanPSMT" {
        didSet {
            percentageLabel.font = UIFont(name: font, size: fontSize)
        }
    }
    
    private
    lazy var path: UIBezierPath = {
        return UIBezierPath(roundedRect: CGRect(x: bounds.origin.x,
                                                y: bounds.origin.y,
                                                width: bounds.width/1.3,
                                                height: bounds.height),
                            cornerRadius: 20)
    }()
    
    private
    lazy var shape: CAShapeLayer = {
        let shape: CAShapeLayer = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillColor = UIColor(red: 0.37, green: 0.63, blue: 0.85, alpha: 1.0).cgColor
        shape.lineWidth = 0.5
        return shape
    }()
    
    open func animatePercentage() {
        let animate = CABasicAnimation(keyPath: "transform.scale.x")
        animate.fromValue = 0
        animate.toValue = CGFloat(percentage) / 100
        animate.duration = 5
        animate.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.88, 0.09, 0.99)
        animate.fillMode = CAMediaTimingFillMode.forwards
        animate.isRemovedOnCompletion = false
        gradientLayer.add(animate, forKey: animate.keyPath)
    }
    
    private
    lazy var outLine: CAShapeLayer = {
        let shape: CAShapeLayer = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = nil
        return shape
    }()
    
    private
    lazy var percentageLabel: UILabel = {
        let label: UILabel = UILabel(frame: .zero)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "TimesNewRomanPSMT", size: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.addSubview(percentageLabel)
        if #available(iOS 9.0, *) {
            percentageLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            percentageLabel.widthAnchor.constraint(equalToConstant: bounds.maxX - bounds.width/1.4).isActive = true
        }
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.layer.insertSublayer(outLine, above: gradientLayer)
        self.animatePercentage()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
