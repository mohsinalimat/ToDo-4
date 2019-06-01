//
//  ToDoCardCollectionViewLayout.swift
//  ToDo
//
//  Created by Tuyen Le on 06.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

class ToDoCardCollectionViewFLowLayout: UICollectionViewFlowLayout {

    private var previousOffset: CGFloat = 0
    private var currentPage: Int = 0
    var newToDoCard: Bool = false
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let itemsCount: Int = collectionView.numberOfItems(inSection: 0)
        
        if previousOffset > collectionView.contentOffset.x && velocity.x < 0 { // left slide
            currentPage = max(currentPage - 1, 0)
        } else if previousOffset < collectionView.contentOffset.x && velocity.x > 0 { // right slide
            if newToDoCard {
                currentPage += 1
                newToDoCard = false
            }
            currentPage = min(currentPage + 1, itemsCount - 1)
        } else {
             newToDoCard = false
        }
        
        let updatedOffset: CGFloat = (itemSize.width + minimumInteritemSpacing) * CGFloat(currentPage)
        previousOffset = updatedOffset
        return CGPoint(x: updatedOffset, y: proposedContentOffset.y)
    }

}
