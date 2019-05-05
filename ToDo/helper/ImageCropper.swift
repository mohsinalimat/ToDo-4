//
//  ImageCropper.swift
//  ToDo
//
//  Created by Tuyen Le on 02.05.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

struct CircleCropView {
    func cropImage(_ image: UIImage, _ targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let heightRatio = targetSize.height / size.height
        let widthRatio = targetSize.width / size.width
        
        let scaleWidth = size.width * widthRatio
        let scaleHeight = size.height * heightRatio
        let rect = CGRect(x: 0, y: 0, width: scaleWidth, height: scaleHeight)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return maskRoundedImage(newImage)
    }
    
    func maskRoundedImage(_ image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        let imageView = UIImageView(image: image)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = image.size.width/2
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, UIScreen.main.scale)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
    
    /** TODO: Implement crop functionality
    lazy var focusShape: CAShapeLayer = {
        let shape = CAShapeLayer()
        let path = UIBezierPath()
        
        // 2 vertical line
        path.move(to: CGPoint(x: bounds.midX - 60, y: 15))
        path.addLine(to: CGPoint(x: bounds.midX - 60, y: bounds.maxY - 15))
        path.move(to: CGPoint(x: bounds.midX + 60, y: 15))
        path.addLine(to: CGPoint(x: bounds.midX + 60, y: bounds.maxY - 15))
        
        // 2 horizontal line
        path.move(to: CGPoint(x: 15, y: bounds.midY - 60))
        path.addLine(to: CGPoint(x: bounds.maxX - 15, y: bounds.midY - 60))
        path.move(to: CGPoint(x: 15, y: bounds.midY + 60))
        path.addLine(to: CGPoint(x: bounds.maxX - 15, y: bounds.midY + 60))
        shape.path = path.cgPath
        shape.lineWidth = 0.5
        shape.strokeColor = UIColor.lightGray.cgColor
        return shape
    }()

    @objc func dragView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let velocity = sender.velocity(in: self)
        let parentMaxX = UIScreen.main.bounds.maxX
        let parentMaxY = UIScreen.main.bounds.maxY

        if frame.minX >= 0 && frame.maxX <= parentMaxX && frame.minY >= 0 && frame.maxY <= parentMaxY {
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        } else if frame.minX < 0 && velocity.x < 0 {
            center = CGPoint(x: center.x - translation.x, y: center.y + translation.y)
        } else if frame.minX < 0 && velocity.x > 0 {
             center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        } else if frame.maxX > parentMaxX && velocity.x > 0 {
            center = CGPoint(x: center.x - translation.x, y: center.y + translation.y)
        } else if frame.maxX > parentMaxX && velocity.x < 0 {
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        } else if frame.minY < 0 && velocity.y < 0 {
            center = CGPoint(x: center.x + translation.x, y: center.y - translation.y)
        } else if frame.minY < 0 && velocity.y > 0 {
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        } else if frame.maxY > parentMaxY && velocity.y > 0 {
            center = CGPoint(x: center.x + translation.x, y: center.y - translation.y)
        } else if frame.maxY > parentMaxY && velocity.y < 0 {
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        }

        sender.setTranslation(CGPoint.zero, in: self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.cornerRadius = frame.size.height/2
        clipsToBounds = true
        layer.addSublayer(focusShape)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragView(_:)))
        addGestureRecognizer(panGesture)
    }

    override func draw(_ rect: CGRect) {
        let newRect = CGRect(x: rect.origin.x + 5, y: rect.origin.y + 5, width: rect.width - 10, height: rect.height - 10)
        let circle = UIBezierPath(ovalIn: newRect)
        UIColor.white.setStroke()
        circle.lineWidth = 1
        circle.stroke()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    } **/
}
