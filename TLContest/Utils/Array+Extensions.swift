//
//  Array+Extensions.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

extension Array where Array.Element: Equatable {
    func index(ofElement element: Element) -> Int? {
        for (currentIndex, currentElement) in self.enumerated() {
            if currentElement == element {
                return currentIndex
            }
        }
        return nil
    }
}
