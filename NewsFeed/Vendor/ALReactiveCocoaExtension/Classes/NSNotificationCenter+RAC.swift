//
//  NSNotificationCenter+RAC.swift
//  Pods
//
//  Created by Antoine van der Lee on 15/01/16.
//
//

import Foundation
import ReactiveCocoa

extension NSNotificationCenter {
    func rac_addObserversForNames(names:[String]) -> RACSignal {
        var signals = [RACSignal]()
        for name in names {
            signals.append(self.rac_addObserverForName(name, object: nil))
        }
        
        return RACSignal.merge(signals)
    }
}