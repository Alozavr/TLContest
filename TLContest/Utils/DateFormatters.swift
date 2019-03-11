//
//  DateFormatters.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class DateFormatters {
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
}
