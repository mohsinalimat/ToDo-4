//
//  MonthCollectionView.swift
//  FBSnapshotTestCase
//
//  Created by Tuyen Le on 15.04.19.
//

import UIKit

protocol MonthCollectionViewDelegate: AnyObject {
    func monthCollectionView(_ selectedDateCell: UICollectionViewCell, _ selectedDate: DateComponents)
}

class MonthCollectionView: UICollectionView {
    
    weak var monthCollectionViewDelegate: MonthCollectionViewDelegate?

    open var currentDisplayMonth: Int
    open var currentDisplayYear: Int {
        didSet {
            currentDateIncremental = 1
            reloadData()
        }
    }
    
    private var present = Calendar.current.dateComponents([.year, .month, .day], from: Date())

    private var currentDateIncremental: Int = 1

    /// first week day of current month appears on the calendar
    open var firstWeekDay: Int {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myCalendar: Calendar = Calendar(identifier: .gregorian)
        let firstWeekDayOfCurrentMonthAndYear: String = "\(currentDisplayYear)-\(currentDisplayMonth)-01"
        let firstWeekDay: Int = myCalendar.component(.weekday, from: formatter.date(from: firstWeekDayOfCurrentMonthAndYear)!)
        
        return firstWeekDay
    }

    /// date cell identifier
    let dateCellIdentifier: String = "SingleDatePickerCell"

    /// header view calender identifier
    let headerViewIdentifier: String = "HeaderView"

    /// total day of current month appears on the calendar
    open var totalDayCurrentMonth: Int {
        let calendar: Calendar = Calendar.current
        var dateComponent: DateComponents = DateComponents()
        dateComponent.month = currentDisplayMonth
        dateComponent.year = currentDisplayYear
        let date: Date = calendar.date(from: dateComponent)!
        let numsDay = calendar.range(of: .day, in: .month, for: date)?.count
        
        return numsDay!
    }

    /// return full month in string
    open var monthInString: String {
        switch currentDisplayMonth {
        case 1: return "January"
        case 2: return "Feburary"
        case 3: return "March"
        case 4: return "April"
        case 5: return "May"
        case 6: return "June"
        case 7: return "July"
        case 8: return "August"
        case 9: return "September"
        case 10: return "October"
        case 11: return "November"
        case 12: return "December"
        default: fatalError("Invalid month")
        }
    }

    open lazy var monthLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "\(monthInString)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(frame: CGRect, month: Int, year: Int) {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 15
        currentDisplayMonth = month
        currentDisplayYear = year
        
        super.init(frame: frame, collectionViewLayout: flowLayout)

        delegate = self
        dataSource = self
        isScrollEnabled = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        bounces = false
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
  
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: dateCellIdentifier)
        register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerViewIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MonthCollectionView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 2, bottom: 0, right: 2)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dateCell = collectionView.cellForItem(at: indexPath),
            dateCell.subviews.count == 2, // check if subview is 2 because date label is a subview of date cell
            let dateLabel = dateCell.subviews[1] as? UILabel else { return }
        var dateComponent: DateComponents = DateComponents()
        dateComponent.year = currentDisplayYear
        dateComponent.month = currentDisplayMonth
        dateComponent.day = Int(dateLabel.text!)
        monthCollectionViewDelegate?.monthCollectionView(dateCell, dateComponent)
    }
}

extension MonthCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dateCell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: dateCellIdentifier, for: indexPath)
        let dateLabel: UILabel = UILabel()
        
        if dateCell.subviews.count == 2 {
            dateCell.subviews[1].removeFromSuperview()
        }

        if  indexPath.section == 0 && indexPath.row+1 < firstWeekDay || currentDateIncremental > totalDayCurrentMonth {
            return dateCell
        } else {
            if currentDisplayYear < present.year! || (currentDisplayMonth < present.month! && currentDisplayYear == present.year!)
                || (currentDisplayMonth == present.month! && currentDisplayYear == present.year! && currentDateIncremental < present.day!) {
                dateLabel.textColor = UIColor(red: 0.32, green: 0.36, blue: 0.41, alpha: 1)
                dateLabel.font = UIFont(name: "AppleSDGothicNeo-UltraLight", size: 18)
                dateCell.isUserInteractionEnabled = false
            } else {
                dateLabel.textColor = UIColor.black
                dateLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
            }
            dateLabel.text = String(currentDateIncremental)
            currentDateIncremental += 1
        }

        dateCell.addSubview(dateLabel)
        if #available(iOS 9.0, *) {
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.centerXAnchor.constraint(equalTo: dateCell.centerXAnchor).isActive = true
            dateLabel.centerYAnchor.constraint(equalTo: dateCell.centerYAnchor).isActive = true
        }
        return dateCell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerViewIdentifier, for: indexPath)

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if indexPath.section == 0 {
                headerView.addSubview(monthLabel)
                if #available(iOS 9.0, *) {
                    monthLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
                    monthLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
                }
            }
            return headerView
        default:
            return headerView
        }
    }
}

extension MonthCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 20, height: 20)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: frame.width, height: 30)
        }
        return CGSize(width: 0, height: 0)
    }
}
