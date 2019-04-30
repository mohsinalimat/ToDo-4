//
//  SingleDatePickerCalendar.swift
//  FBSnapshotTestCase
//
//  Created by Tuyen Le on 14.04.19.
//

import UIKit

public protocol SingleDatePickerCalendarDelegate: AnyObject {
    func singleDatePickerCalendar(_ dateSelected: DateComponents)
}

open
class SingleDatePickerCalendar: UICollectionView {

    let calendarIdentifier: String = "CalendarIdentifier"

    let headerViewIdentifier: String = "HeaderView"

    let monthCollectionIdentifier: String = "Month"
    
    var monthCollectionView: MonthCollectionView {
        return MonthCollectionView(frame: .zero, month: 1, year: year)
    }
    
    /// circle layer
    open var circleLayer: CALayer {
        let circleLayer: CALayer = CALayer()
        circleLayer.frame = CGRect(x: -5, y: -5, width: 30, height: 30)
        circleLayer.cornerRadius = 15
        circleLayer.backgroundColor = UIColor.gray.cgColor
        return circleLayer
    }

    
    private var selectedDateCell: UICollectionViewCell?
    private var selectedDate: DateComponents?
    
    open weak var singleDatePickerDelegate: SingleDatePickerCalendarDelegate?
    
    internal lazy var yearLabel: UILabel =  {
        let yearLabel: UILabel = UILabel()
        yearLabel.text = String(year)
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        return yearLabel
    }()
    
    internal lazy var leftArrow: UIButton = {
        let leftArrow: UIButton = UIButton()
        leftArrow.setImage(UIImage(named: "leftArrow"), for: .normal)
        leftArrow.translatesAutoresizingMaskIntoConstraints = false
        leftArrow.addTarget(self, action: #selector(previousYear), for: .touchUpInside)
        return leftArrow
    }()
    
    internal lazy var rightArrow: UIButton = {
        let rightArrow: UIButton = UIButton()
        rightArrow.setImage(UIImage(named: "rightArrow"), for: .normal)
        rightArrow.translatesAutoresizingMaskIntoConstraints = false
        rightArrow.addTarget(self, action: #selector(nextYear), for: .touchUpInside)
        return rightArrow
    }()
    
    var year: Int = Calendar.current.component(.year, from: Date()) {
        didSet {
            yearLabel.text = String(year)
        }
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        if #available(iOS 9.0, *) {
            flowLayout.sectionHeadersPinToVisibleBounds = true
        }
        super.init(frame: frame, collectionViewLayout: flowLayout)
        dataSource = self
        delegate = self
        showsVerticalScrollIndicator = true
        bounces = false
        backgroundColor = .white

        register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerViewIdentifier)
        for i in 0...12 {
            register(UICollectionViewCell.self, forCellWithReuseIdentifier: "\(monthCollectionIdentifier) \(i)")
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// previous year
    @objc func previousYear() {
        year -= 1
        reloadData()
    }
    
    /// next year
    @objc func nextYear() {
        year += 1
        reloadData()
    }
}

extension SingleDatePickerCalendar: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let monthCell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(monthCollectionIdentifier) \(indexPath.row)", for: indexPath)

        if monthCell.subviews.count == 2 {
            if (monthCell.subviews[1] as! MonthCollectionView).currentDisplayYear != year {
                (monthCell.subviews[1] as! MonthCollectionView).currentDisplayYear = year
                if selectedDate?.year != year && selectedDateCell?.layer.sublayers?.count == 3  {
                    selectedDateCell?.layer.sublayers![0].removeFromSuperlayer()
                    selectedDateCell = nil
                }
            }
            return monthCell
        }

        let monthCollectionView: MonthCollectionView = MonthCollectionView(frame: .zero, month: indexPath.row + 1, year: year)
        monthCollectionView.monthCollectionViewDelegate = self
        monthCell.addSubview(monthCollectionView)

        if #available(iOS 9.0, *) {
            monthCollectionView.centerXAnchor.constraint(equalTo: monthCell.centerXAnchor).isActive = true
            monthCollectionView.centerYAnchor.constraint(equalTo: monthCell.centerYAnchor).isActive = true
            monthCollectionView.widthAnchor.constraint(equalToConstant: 250).isActive = true
            monthCollectionView.heightAnchor.constraint(equalToConstant: monthCell.bounds.height).isActive = true
        }

        return monthCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerViewIdentifier, for: indexPath)

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let weakLabelCollection: WeekLabelCollection = WeekLabelCollection(frame: .zero)
            weakLabelCollection.translatesAutoresizingMaskIntoConstraints = false

            headerView.backgroundColor = .white

            headerView.addSubview(weakLabelCollection)
            headerView.addSubview(rightArrow)
            headerView.addSubview(leftArrow)
            headerView.addSubview(yearLabel)

            if #available(iOS 9.0, *) {
                yearLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
                yearLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true

                rightArrow.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
                rightArrow.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 50).isActive = true
    
                leftArrow.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
                leftArrow.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: -50).isActive = true
    
                weakLabelCollection.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
                weakLabelCollection.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
                weakLabelCollection.widthAnchor.constraint(equalToConstant: 250).isActive = true
                weakLabelCollection.heightAnchor.constraint(equalToConstant: 20).isActive = true
            }
            return headerView
        default:
            return headerView
        }
    }
}

extension SingleDatePickerCalendar: MonthCollectionViewDelegate {
    func monthCollectionView(_ selectedDateCell: UICollectionViewCell, _ selectedDate: DateComponents) {
        if self.selectedDateCell != nil {
            self.selectedDateCell?.layer.sublayers![0].removeFromSuperlayer()
        }
        self.selectedDateCell = selectedDateCell
        self.selectedDate = selectedDate
        self.selectedDateCell?.layer.insertSublayer(circleLayer, at: 0)
        singleDatePickerDelegate?.singleDatePickerCalendar(selectedDate)
    }
}

extension SingleDatePickerCalendar: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: bounds.width, height: 220)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: bounds.width, height: 60)
        }
        return CGSize(width: 0, height: 0)
    }
}
