//
//  Delegate.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/18.
//

import Foundation

public class Delegate<Input, Output> {
    public init() {}
    
    private var block: ((Input) -> Output?)?
    public func delegate<T: AnyObject>(on target: T, block: ((T, Input) -> Output)?) {
        self.block = { [weak target] input in
            guard let target = target else { return nil }
            return block?(target, input)
        }
    }
    
    public func call(_ input: Input) -> Output? {
        return block?(input)
    }

    public func callAsFunction(_ input: Input) -> Output? {
        return call(input)
    }
}

extension Delegate where Input == Void {
    public func call() -> Output? {
        return call(())
    }

    public func callAsFunction() -> Output? {
        return call()
    }
}

extension Delegate where Input == Void, Output: OptionalProtocol {
    public func call() -> Output {
        return call(())
    }

    public func callAsFunction() -> Output {
        return call()
    }
}

extension Delegate where Output: OptionalProtocol {
    public func call(_ input: Input) -> Output {
        if let result = block?(input) {
            return result
        } else {
            return Output._createNil
        }
    }

    public func callAsFunction(_ input: Input) -> Output {
        return call(input)
    }
}

public protocol OptionalProtocol {
    static var _createNil: Self { get }
}
extension Optional : OptionalProtocol {
    public static var _createNil: Optional<Wrapped> {
         return nil
    }
}
