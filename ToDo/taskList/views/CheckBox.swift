//
//  CheckBox.swift
//  ToDo
//
//  Created by Tuyen Le on 31.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

//
//  RadioButtons.swift
//  RadioButtons
//
//  Created by Tuyen Le on 10.02.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

open class CheckBox: UIControl {
    // MARK: - checkbox attribute properties
    
    
    /// cross out line
    lazy var crossOutLine: CAShapeLayer = {
        let path: UIBezierPath = UIBezierPath()
        let shape: CAShapeLayer = CAShapeLayer()
        path.move(to: CGPoint(x: 0, y: textLayer.bounds.midY))
        path.addLine(to: CGPoint(x: textLayer.bounds.maxX, y: textLayer.bounds.midY))
        shape.path = path.cgPath
        shape.strokeColor = UIColor.lightGray.cgColor
        return shape
    }()
    
    /// checkbox label
    open var label: String = "" {
        didSet {
            textLayer.string = label
            textLayer.frame = CGRect(x: bounds.maxX * 2,
                                     y: -2,
                                     width: textLayer.preferredFrameSize().width,
                                     height: textLayer.preferredFrameSize().height)
        }
    }
    
    /// checkbox label color
    open var labelColor: CGColor = UIColor.black.cgColor {
        didSet {
            textLayer.foregroundColor = labelColor
        }
    }
    
    /// checkbox label font
    open var labelFont: CFString = "TimesNewRomanPSMT" as CFString {
        didSet {
            textLayer.font = CTFontCreateWithName(labelFont, 0, nil)
        }
    }
    
    /// label font size
    open var labelFontSize: CGFloat = 15 {
        didSet {
            textLayer.fontSize = self.labelFontSize
        }
    }
    
    /// checkbox size
    open var size: CGSize = CGSize(width: 15, height: 15) {
        didSet {
            frame.size = size
            textLayer.frame = CGRect(x: bounds.maxX * 2,
                                     y: -2,
                                     width: textLayer.preferredFrameSize().width,
                                     height: textLayer.preferredFrameSize().height)
        }
    }
    
    /// checkbox border
    open var borderColor: UIColor = UIColor.black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    /// checkbox border width
    open var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    /// checkbox background color
    open var checkboxBackgroundColor: UIColor = .lightGray {
        didSet {
            layer.backgroundColor = checkboxBackgroundColor.cgColor
        }
    }
    
    /// determine whether checkbox is checked, default to false
    var checked: Bool = false {
        didSet {
            if !checked {
                checkMark.removeFromSuperlayer()
                crossOutLine.removeFromSuperlayer()
                layer.backgroundColor = UIColor.white.cgColor
            } else {
                drawCheckMark()
                textLayer.addSublayer(crossOutLine)
            }
        }
    }

    /// checkmark shape layer
    fileprivate lazy var checkMark: CAShapeLayer = {
        let checkMark: CAShapeLayer = CAShapeLayer()
        checkMark.path = self.checkMarkPath.cgPath
        checkMark.lineWidth = 1
        checkMark.lineCap = CAShapeLayerLineCap.square
        checkMark.fillColor = nil
        
        return checkMark
    }()
    
    /// check mark path
    fileprivate lazy var checkMarkPath: UIBezierPath = {
        let checkMarkPath: UIBezierPath = UIBezierPath()
        checkMarkPath.move(to: CGPoint(x: self.borderWidth, y: frame.height/2))
        checkMarkPath.addLine(to: CGPoint(x: frame.width/2 - self.borderWidth, y: frame.height - self.borderWidth))
        checkMarkPath.addLine(to: CGPoint(x: frame.width - self.borderWidth, y: self.borderWidth))
        
        return checkMarkPath
    }()
    
    /// text layer label next to checkbox
    fileprivate lazy var textLayer: CATextLayer = {
        let textLayer: CATextLayer = CATextLayer()
        textLayer.foregroundColor = self.labelColor
        textLayer.font = CTFontCreateWithName(self.labelFont, 0, nil)
        textLayer.fontSize = self.labelFontSize
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.masksToBounds = true

        return textLayer
    }()
    
    // MARK: - checkbox function properties
    
    /// call back action
    open var onTapAction: ((_ checked: Bool, _ label: String) -> Void)?
    
    /// pulsate checkbox when tap
    private func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        textLayer.removeAllAnimations()
        layer.add(pulse, forKey: nil)
    }
    
    /// default setup
    private func defaultSetUp() {
        /// checkbox border
        layer.borderWidth = self.borderWidth
        layer.borderColor = self.borderColor.cgColor
        
        layer.addSublayer(textLayer)
        
        /// add action to checkbox
        addTarget(self, action: #selector(self.onTapCheckBox), for: .touchUpInside)
    }
    
    /// on tap checkbox action to add checkmark
    @objc private func onTapCheckBox() {
        self.checked = !self.checked
        pulsate()
        if checked {
            drawCheckMark()
            textLayer.addSublayer(crossOutLine)
        } else {
            undrawCheckMark()
            crossOutLine.removeFromSuperlayer()
        }
        self.onTapAction?(self.checked, self.label)
    }
    
    /// undraw checkmark
    public func undrawCheckMark() {
        checkMark.strokeColor = UIColor.black.cgColor
        self.animateUnCheckMark()
        layer.backgroundColor = UIColor.white.cgColor
    }
    
    /// draw checkmark
    public func drawCheckMark() {
        self.animateCheckMark()
        
        if layer.sublayers?.count == 1 {
            layer.addSublayer(checkMark)
        }
        checkMark.strokeColor = UIColor.white.cgColor
        layer.backgroundColor = checkboxBackgroundColor.cgColor
    }
    
    /// animate uncheckmark
    private func animateUnCheckMark() {
        checkMark.removeAllAnimations()

        let duration: CFTimeInterval = 1
        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.toValue = checkMark.strokeStart
        end.fromValue = checkMark.strokeEnd
        end.duration = duration
        end.fillMode = CAMediaTimingFillMode.forwards
        end.isRemovedOnCompletion = false
        end.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.88, 0.09, 0.99)
        
        checkMark.add(end, forKey: "uncheckMark")
    }
    
    /// animate checkmark
    private func animateCheckMark() {
        checkMark.removeAllAnimations()
        
        let duration: CFTimeInterval = 1
        
        let end: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        end.fromValue = checkMark.strokeStart
        end.toValue = checkMark.strokeEnd
        end.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.88, 0.09, 0.99)
        
        let begin: CABasicAnimation = CABasicAnimation(keyPath: "strokeStart")
        begin.fromValue = checkMark.strokeStart
        begin.toValue = checkMark.strokeEnd
        begin.beginTime = duration
        begin.duration = duration * 0.85
        begin.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.88, 0.09, 0.99)
        
        let group = CAAnimationGroup()
        group.animations = [end, begin]
        group.duration = duration
        
        checkMark.add(group, forKey: "checkMark")
    }
    
    // MARK: - override funcs
    public init() {
        super.init(frame: .zero)
        frame.size = self.size
        self.defaultSetUp()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.defaultSetUp()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
