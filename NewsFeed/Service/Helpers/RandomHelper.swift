//
//  RandomHelper.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//



class RandomHelper: NSObject {
    
    static func random(min: UInt32, max: UInt32) -> UInt32 {
        
        return  arc4random_uniform(max - min) + min
        
    }
    
    static func randomString(min: UInt32, max: UInt32) -> String {
        return randomString(random(min, max: max))
    }
    
    static func randomString(len: UInt32) -> String {
        
        let min: UInt32 = 65, max:UInt32 = 90
        
        var string = ""
        
        for _ in 0..<len {
            
            string.append(UnicodeScalar(random(min, max: max)))
            
        }
        
        return string
        
    }
}
