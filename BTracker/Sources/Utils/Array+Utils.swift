//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation

extension Array {
    mutating func remove(`where` toRemove: (Element) -> Bool) {
        guard let index = self.index(where: toRemove) else { return }
        self.remove(at: index)
    }
}

extension Array {
    /// Splits array into two separate array, stored as tuple:
    ///
    ///  * __passing__: Contains array of elements passing test
    ///  * __rest__: Contains elements not passing test
    ///
    /// It is equvalent of calling filter twice, once for T, once for !T:
    ///
    /// - Parameter isIncluded: Closure returning, whether given element passes test
    /// - Returns: Tuple consising of two arrays - passing and rest
    /// - Throws: Error thrown by filter
    func split(filter isIncluded: (Element) throws -> Bool) throws -> (passing: Array<Element>, rest: Array<Element>) {
        let included = try self.filter { return try isIncluded($0) }
        let notIncluded = try self.filter { return try !isIncluded($0) }
        return (passing: included, rest: notIncluded)
    }

    /// Splits array into separate arrays, divided and categorized by closure passed.
    /// Elements producing same identifier (of type U: Hashable) will be stored in same subarray.
    ///
    /// - Parameter splitter: Returns category (identifier) for given element
    /// - Returns: Dictionary, where category(identifier) is key, and array of elements categorized is value
    /// - Throws: splitter thrown error
    func split<U>(by splitter: (Element) throws -> U) throws -> [U:[Element]] {
        var dict: [U:[Element]] = [:]

        try self.forEach { element in
            let identifier = try splitter(element)

            if dict[identifier] == nil {
                dict[identifier] = []
            }

            dict[identifier]?.append(element)
        }

        return dict
    }
}
