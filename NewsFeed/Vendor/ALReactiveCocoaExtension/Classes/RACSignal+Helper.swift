//
//  RACSignal+Helper.swift
//  Pods
//
//  Created by Antoine van der Lee on 15/01/16.
//
//

import Foundation
import ReactiveCocoa

public extension RACSignal {
    
    private func errorLogCastNext<T>(next:AnyObject!, withClosure nextClosure:(T) -> ()){
        if let nextAsT = next as? T {
            nextClosure(nextAsT)
        } else {
            print("ERROR: Could not cast! \(next)")
        }
    }
    
    func subscribeNextAs<T>(nextClosure:(T) -> ()) -> RACDisposable {
        return self.subscribeNext {
            (next: AnyObject!) -> () in
            self.errorLogCastNext(next, withClosure: nextClosure)
        }
    }
    
    func trySubscribeNextAs<T>(nextClosure:(T) -> ()) -> () {
        self.filter { (next: AnyObject!) -> Bool in
            return next != nil
            }.subscribeNext {
                (next: AnyObject!) -> () in
                
                self.errorLogCastNext(next, withClosure: nextClosure)
        }
    }
    
    func subscribeNextAs<T>(nextClosure:(T) -> (), error: (NSError) -> ()) -> RACDisposable {
        return self.subscribeNext({ (next: AnyObject!) -> Void in
            self.errorLogCastNext(next, withClosure: nextClosure)
            }, error: { (err: NSError!) -> Void in
                error(err)
        })
    }
    
    func subscribeNextAs<T>(nextClosure:(T) -> (), error: (NSError) -> (), completed:() ->()) -> () {
        self.subscribeNext({
            (next: AnyObject!) -> () in
            self.errorLogCastNext(next, withClosure: nextClosure)
            }, error: {
                (err: NSError!) -> () in
                error(err)
            }, completed: completed)
    }
    
    func flattenMapAs<T: AnyObject>(flattenMapClosure:(T) -> RACStream) -> RACSignal {
        return self.flattenMap {
            (next: AnyObject!) -> RACStream in
            let nextAsT = next as! T
            return flattenMapClosure(nextAsT)
        }
    }
    
    func mapAs<T, U: AnyObject>(mapClosure:(T) -> U) -> RACSignal {
        return self.map {
            (next: AnyObject!) -> AnyObject! in
            let nextAsT = next as! T
            return mapClosure(nextAsT)
        }
    }
    
    func filterAs<T: AnyObject>(filterClosure:(T) -> Bool) -> RACSignal {
        return self.filter {
            (next: AnyObject!) -> Bool in
            let nextAsT = next as! T
            return filterClosure(nextAsT)
        }
    }
    
    func doNextAs<T>(nextClosure:(T) -> ()) -> RACSignal {
        return self.doNext {
            (next: AnyObject!) -> () in
            self.errorLogCastNext(next, withClosure: nextClosure)
        }
    }
    
    func execute() -> RACDisposable {
        return self.subscribeCompleted { () -> Void in
            
        }
    }
    
    func executeWithDelay(interval:NSTimeInterval) -> RACDisposable {
        let signals = [RACSignal.empty().delay(interval), self]
        let delayedSignal = RACSignal.concat(signals)
        return delayedSignal.execute()
    }
    
    func ignoreNil() -> RACSignal {
        return self.filter({ (innerValue) -> Bool in
            return innerValue != nil
        })
    }
}