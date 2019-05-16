//
//  Extension.swift
//  ToDo
//
//  Created by Tuyen Le on 27.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, size: CGFloat?) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "AvenirNext-Bold", size: size ?? 12)!]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        
        append(boldString)
        
        return self
    }

    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "AppleSDGothicNeo-Regular", size: 15)!, .foregroundColor: UIColor.lightGray]
        let normal = NSMutableAttributedString(string: text, attributes: attrs)

        append(normal)
        
        return self
    }
}
