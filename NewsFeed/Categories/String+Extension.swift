//
//  String+Extension.swift
//  NewsFeed
//
//  Created by WorkHarder on 9/3/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import Foundation

extension String {
    func trimLength() -> Int {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count
    }
}