//
//  EPExtensions.swift
//  ContactPikerDemo
//
//  Created by iFlame on 5/25/17.
//  Copyright © 2017 iFlame. All rights reserved.
//

import UIKit
import Foundation

extension String {
    subscript(r: Range<Int>) -> String? {
        get {
            let stringCount = self.characters.count as Int
            if ( stringCount < r.upperBound) ||
                (stringCount < r.lowerBound) {
                return nil
        }
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            return self[(startIndex ..< endIndex)]
    }
}

    func containAlphabets() -> Bool {
        let set = NSCharacterSet.letters
        return self.utf16.contains(where: { return set.contains(UnicodeScalar($0)!)   })
   }
}
