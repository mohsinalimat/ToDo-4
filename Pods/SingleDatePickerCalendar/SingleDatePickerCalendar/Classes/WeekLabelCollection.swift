//
//  WeekLabelCollection.swift
//  FBSnapshotTestCase
//
//  Created by Tuyen Le on 15.04.19.
//

import UIKit

class WeekLabelCollection: UICollectionView {
    /// weekday abbreviation
    open var weekAbbreviation: [String] {
        return ["S", "M", "T", "W", "T", "F", "S"]
    }
    
    let  weekIdentifier: String = "WeekIdentifier"
    
    init(frame: CGRect) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 18
        layout.itemSize = CGSize(width: 20, height: 20)
        super.init(frame: frame, collectionViewLayout: layout)
        
        dataSource = self
        delegate = self

        register(WeekLabelCell.self, forCellWithReuseIdentifier: weekIdentifier)

        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WeekLabelCollection: UICollectionViewDelegate {

}

extension WeekLabelCollection: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let weekCell: WeekLabelCell = collectionView.dequeueReusableCell(withReuseIdentifier: weekIdentifier, for: indexPath) as! WeekLabelCell
        weekCell.label = weekAbbreviation[indexPath.row]
        return weekCell
    }
}

extension WeekLabelCell: UICollectionViewDelegateFlowLayout {

}
