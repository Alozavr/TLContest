//
//  Colors.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 18/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class Colors {
    static var shared = Colors()
    
    var primaryColor = UIColor.white
    var secondaryAColor = UIColor(hexString: "cbd3dd")
    var secondaryBColor = UIColor(hexString: "f6f8fa")
    var secondaryCColor = UIColor(hexString: "77777c")
    var infoColor = UIColor(hexString: "fafafa")
    var backgroundColor = UIColor(hexString: "fafafa")
    var textColor = UIColor.black
    
    var statusBarStyle: UIStatusBarStyle = .default
    var barStyle: UIBarStyle = .black
}
