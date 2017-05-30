//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation

extension Beacon: Trackable {
    public var trackedBy: TrackType { return .beacon(self) }

    public func matches(any identifier: Identifier) -> Bool {
        return matches(proximity: identifier) || matches(motion: identifier)
    }
}
