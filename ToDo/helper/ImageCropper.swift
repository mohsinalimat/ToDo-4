//
//  ImageCropper.swift
//  ToDo
//
//  Created by Tuyen Le on 02.05.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//
import UIKit

class CircleCropView: UIView {
    func cropImage(_ image: UIImage, _ targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        image.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return maskRoundedImage(newImage)
    }
    
    func cropImage(_ imageView: UIImageView, _ targetSize: CGSize) -> UIImage? {
        guard let image = imageView.image else { return nil }
        
        let imageViewScale = max(image.size.width / imageView.frame.size.width, image.size.height / imageView.frame.size.height)
        let x = (imageView.frame.midY * imageViewScale)/1.5 < frame.origin.y * imageViewScale
            ? frame.origin.x * imageViewScale + (frame.width * imageViewScale)/1.5
            : frame.origin.x * imageViewScale
        let y = (imageView.frame.midY * imageViewScale)/1.5 < frame.origin.y * imageViewScale
            ? frame.origin.y * imageViewScale - (frame.height * imageViewScale)/1.5
            : frame.origin.y * imageViewScale
        let width = (imageView.frame.midY * imageViewScale)/1.5 < frame.origin.y * imageViewScale
            ? frame.height/2 * imageViewScale
            : frame.height * imageViewScale
        let height = (imageView.frame.midY * imageViewScale)/1.5 < frame.origin.y * imageViewScale
            ? frame.width/2 * imageViewScale
            : frame.width * imageViewScale
        
        let cropZone = CGRect(x: x,
                              y: y,
                              width: width,
                              height: height)
        
        
        let imageRef = UIImage(cgImage: image.cgImage!.cropping(to: cropZone)!, scale: image.scale, orientation: image.imageOrientation)
        let resizeImage = resize(imageRef, to: targetSize)
        
        return maskRoundedImage(resizeImage)
    }
    
    func resize(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizeImage
    }
    
    func maskRoundedImage(_ image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        let imageView = UIImageView(image: image)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = image.size.width/2
        imageView.contentMode = .scaleAspectFit

        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, UIScreen.main.scale)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return roundedImage
    }
    
    /// TODO: Implement crop functionality
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
    }
}

