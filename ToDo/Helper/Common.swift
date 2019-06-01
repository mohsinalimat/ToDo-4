//
//  Common.swift
//  ToDo
//
//  This file is for common function used throughout the code base
//
//  Created by Tuyen Le on 01.06.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import Foundation

func monthInString(_ month: Int) -> String {
    switch month {
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
