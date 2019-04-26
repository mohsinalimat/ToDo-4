//
//  ViewControllerAnimator.swift
//  ToDo
//
//  Created by Tuyen Le on 29.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

class ToDoCardPresentAnimator: NSObject {
    
    let todoCardFrame: CGRect = CGRect(x: UIScreen.main.bounds.width/8,
                                       y: UIScreen.main.bounds.maxY - UIScreen.main.bounds.height/2 + 25,
                                       width: UIScreen.main.bounds.width/1.5,
                                       height: UIScreen.main.bounds.height/2.5)
    
    /// maximum point for navigationBar to determine offsetY for icon, numberOfTask, taskType, progressBar and tableView
    var navigationBarMaxY: CGFloat
    
    var todoCardIndex: Int
    
    lazy var translateY: CABasicAnimation = {
        let translateY: CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.y")

        translateY.duration = 1.5
        translateY.fromValue = 0
        translateY.fillMode = kCAFillModeForwards
        translateY.isRemovedOnCompletion = false

        return translateY
    }()
    
    init(navigationBarMaxY: CGFloat, todoCardIndex: Int) {
        self.navigationBarMaxY = navigationBarMaxY
        self.todoCardIndex = todoCardIndex
    }
}

extension ToDoCardPresentAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView: UIView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view
        let containerView: UIView = transitionContext.containerView
        let todoCard: ToDoCardExt = ToDoCardExt(frame: todoCardFrame) // TODO: can be reuse

        translateY.toValue = todoCard.topLeftIcon.bounds.maxY - todoCard.numOfTaskLayer.frame.minY + (todoCard.topLeftIcon.bounds.maxY * 3)
        
        toView.frame = todoCardFrame
        toView.layer.cornerRadius = 10
        
        containerView.addSubview(toView)
        containerView.insertSubview(todoCard, aboveSubview: toView)

        
        todoCard.numOfTaskLayer.add(translateY, forKey: translateY.keyPath)
        todoCard.taskTypeLabelLayer.add(translateY, forKey: translateY.keyPath)
        todoCard.backgroundColor = .clear
        todoCard.taskType = realm.objects(Person.self).first!.taskType[todoCardIndex - 1].type.rawValue // TODO: fix, not always first person
        
        UIView.animate(withDuration: 1.5, animations: {
            
            toView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: UIScreen.main.bounds.width,
                                  height: UIScreen.main.bounds.height)
            todoCard.frame = CGRect(x: todoCard.frame.origin.x,
                                    y: self.navigationBarMaxY,
                                    width: UIScreen.main.bounds.width/1.5,
                                    height: UIScreen.main.bounds.height/4)
            todoCard.progressBar.frame.origin.y = todoCard.taskTypeLabelLayer.bounds.maxY * 4.8
        }, completion: {
            (finished: Bool) in
            let toDoViewController: ToDoViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! as! ToDoViewController
            toDoViewController.todoCard = todoCard
            toDoViewController.taskType = Type(rawValue: todoCard.taskType)
            transitionContext.completeTransition(true)
        })
    }
}
