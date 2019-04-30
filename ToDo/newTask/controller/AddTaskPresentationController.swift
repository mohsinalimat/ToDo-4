//
//  AddTask.swift
//  ToDo
//
//  Created by Tuyen Le on 05.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit
import AddButtonExpand

class AddTaskPresentationController: UIPresentationController {
    
    @objc internal func keyboardWillShow(notification: Notification) {
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        containerView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: keyboardFrame.minY - 40)
    }

    override func presentationTransitionWillBegin() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        containerView?.frame = .zero
    }

}
