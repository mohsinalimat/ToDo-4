//
//  ToDoCardDismissAnimator.swift
//  ToDo
//
//  Created by Tuyen Le on 31.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

class ToDoCardDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let todoCardFrame: CGRect = CGRect(x: UIScreen.main.bounds.width/8,
                                       y: UIScreen.main.bounds.maxY - UIScreen.main.bounds.height/2 + 25,
                                       width: UIScreen.main.bounds.width/1.5,
                                       height: UIScreen.main.bounds.height/2.5)

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView: UIView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view
        let fromView: UIView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view
        let containerView: UIView = transitionContext.containerView
        let todoView: UIView = containerView.subviews[0]
        let todoCard: ToDoCardExt = fromView.subviews[0] as! ToDoCardExt
        let tasksTable: UITableView = fromView.subviews[1] as! UITableView
        let translateY: CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.y")

        translateY.fromValue = todoCard.topLeftIcon.bounds.maxY - todoCard.numOfTaskLayer.frame.minY + (todoCard.topLeftIcon.bounds.maxY * 3)
        translateY.toValue = 0
        translateY.duration = 1

        fromView.layer.cornerRadius = 10

        todoCard.layer.cornerRadius = 10
        todoCard.numOfTaskLayer.removeAllAnimations()
        todoCard.taskTypeLabelLayer.removeAllAnimations()
        todoCard.numOfTaskLayer.add(translateY, forKey: translateY.keyPath)
        todoCard.taskTypeLabelLayer.add(translateY, forKey: translateY.keyPath)
        todoCard.backgroundColor = .white

        containerView.insertSubview(toView, belowSubview: todoView)
        
        tasksTable.transform = CGAffineTransform(scaleX: 0, y: 0)

        UIView.animate(withDuration: 1, animations: {
            fromView.frame = self.todoCardFrame
            todoCard.frame = CGRect(x: 0, y: 0, width: self.todoCardFrame.width, height: self.todoCardFrame.height)
            todoCard.progressBar.frame.origin.y = todoCard.bounds.maxY - 20
        }, completion: {
            (finished: Bool) in
            todoCard.removeFromSuperview()
            todoView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })

    }
    
    
}
