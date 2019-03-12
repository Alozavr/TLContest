//
//  UIColor+Extensions.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hexString: String) {
        // Trim leading '#' if needed
        var cleanedHexString = hexString
        if hexString.hasPrefix("#") {
            //            cleanedHexString = dropFirst(hexString) // Swift 1.2
            cleanedHexString = String(hexString.dropFirst()) // Swift 2
        }
        
        // String -> UInt32
        var rgbValue: UInt32 = 0
        Scanner(string: cleanedHexString).scanHexInt32(&rgbValue)
        
        // UInt32 -> R,G,B
        let red = CGFloat((rgbValue >> 16) & 0xff) / 255.0
        let green = CGFloat((rgbValue >> 08) & 0xff) / 255.0
        let blue = CGFloat((rgbValue >> 00) & 0xff) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}
