//
//  DateFormatters.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class DateFormatters {
    
    lazy var monthDayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    lazy var yearDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    func format(date: Date) -> String {
        return monthDayDateFormatter.string(from: date)
    }
    
    func formatDateToYear(date: Date) -> String {
        return yearDateFormatter.string(from: date)
    }
    
}
