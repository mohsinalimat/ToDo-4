//
//  PlusSign.swift
//  AddButtonExpand
//
//  Created by Tuyen Le on 03.04.19.
//

import UIKit

open
class PlusSign: UIView {
    
    open var color: UIColor = .white {
        didSet {
            sign.strokeColor = color.cgColor
        }
    }
    
    internal lazy var sign: CAShapeLayer = {
        let plusSign: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        plusSign.lineWidth = 0.5
        plusSign.strokeColor = color.cgColor
        plusSign.fillColor = nil
        path.move(to: CGPoint(x: bounds.midX/2, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.maxX - bounds.midX/2, y: bounds.midY))
        path.move(to: CGPoint(x: bounds.midX, y: bounds.midY/2))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY - bounds.midY/2))
        plusSign.path = path.cgPath
        return plusSign
    }()

    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.addSublayer(sign)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
