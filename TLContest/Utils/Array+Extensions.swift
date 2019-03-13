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

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard !isEmpty, size != 0 else { return [[]] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
