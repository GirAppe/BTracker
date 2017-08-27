//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation

public enum Value<T:Equatable>: Equatable {
    case any
    case some(T)
}

public protocol AnyValueEquatable: Equatable {
    associatedtype ValueType: Equatable

    func value() -> ValueType?
}

extension Value: AnyValueEquatable {
    public typealias ValueType = T

    public func value() -> ValueType? {
        switch self {
            case let .some(value): return value
            default: return nil
        }
    }
}

extension AnyValueEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard let lhs = lhs.value() else { return true }
        guard let rhs = rhs.value() else { return true }
        return lhs == rhs
    }

    public static func == (lhs: Self, rhs: ValueType) -> Bool {
        guard let lhs = lhs.value() else { return true }
        return lhs == rhs
    }

    public static func == (lhs: ValueType, rhs: Self) -> Bool {
        guard let rhs = rhs.value() else { return true }
        return lhs == rhs
    }
}
