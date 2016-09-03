//
//  SignalProducer+Helper.swift
//  Pods
//
//  Created by Antoine van der Lee on 15/01/16.
//
//

import Foundation
import ReactiveCocoa

public enum ALCastError : ErrorType {
    case CouldNotCastToType
}

private extension SignalProducerType  {
    func mapToType<U>() -> SignalProducer<U, ALCastError> {
        return flatMapError({ (_) -> SignalProducer<Value, ALCastError> in
            return SignalProducer(error: ALCastError.CouldNotCastToType)
        }).flatMap(.Concat) { object -> SignalProducer<U, ALCastError> in
            if let castedObject = object as? U {
                return SignalProducer(value: castedObject)
            } else {
                return SignalProducer(error: ALCastError.CouldNotCastToType)
            }
        }
    }
}

public extension SignalProducerType {
    func onStarted(callback:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(started: callback)
    }
    
    func onError(callback:(error:Error) -> () ) -> SignalProducer<Value, Error> {
        return self.on(failed: { (error) -> () in
            callback(error: error)
        })
    }
    
    func onNext(nextClosure:(Value) -> ()) -> SignalProducer<Value, Error> {
        return self.on(next: nextClosure)
    }
    
    func onCompleted(nextClosure:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(completed: nextClosure)
    }
    
    func onNextAs<U>(nextClosure:(U) -> ()) -> SignalProducer<U, ALCastError> {
        return self.mapToType().on(next: nextClosure)
    }
    
    func startWithNextAs<U>(nextClosure:(U) -> ()) -> Disposable {
        return self.mapToType().startWithNext(nextClosure)
    }
}

/// Deprecated methods
public extension SignalProducerType {
    @available(*, deprecated, message="This will be removed. Use onStarted instead.")
    func initially(callback:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(started: callback)
    }
    
    @available(*, deprecated, message="This will be removed. Use onError instead.")
    func doError(callback:(error:Error) -> () ) -> SignalProducer<Value, Error> {
        return self.on(failed: { (error) -> () in
            callback(error: error)
        })
    }
    
    @available(*, deprecated, message="This will be removed. Use onNext instead.")
    func doNext(nextClosure:(object:Value) -> ()) -> SignalProducer<Value, Error> {
        return self.on(next: nextClosure)
    }
    
    @available(*, deprecated, message="This will be removed. Use onCompleted instead.")
    func doCompleted(nextClosure:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(completed: nextClosure)
    }
    
    @available(*, deprecated, message="This will be removed. Use startWithNext instead.")
    func subscribeNext(nextClosure:(object:Value) -> ()) -> Disposable {
        return self.startWithNext(nextClosure)
    }
    
    @available(*, deprecated, message="This will be removed. Use start instead.")
    func execute() -> Disposable {
        return self.start()
    }
    
    @available(*, deprecated, message="This will be removed. Use startWithCompleted instead.")
    func subscribeCompleted(completed: () -> ()) -> Disposable {
        return self.startWithCompleted(completed)
    }
    
    @available(*, deprecated, message="This will be removed. Use onNextAs instead.")
    func doNextAs<U>(nextClosure:(U) -> ()) -> SignalProducer<U, ALCastError> {
        return self.mapToType().on(next: nextClosure)
    }
    
    @available(*, deprecated, message="This will be removed. Use startWithNextAs instead.")
    func subscribeNextAs<U>(nextClosure:(U) -> ()) -> Disposable {
        return self.mapToType().startWithNext(nextClosure)
    }
}
