//
//  Chart.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

struct Line {
    let name: String
    let values: [Int]
    let color: UIColor
    let isVisible: Bool
}

struct Chart {
    let dateAxis: [Date]
    let lines: [Line]
}
