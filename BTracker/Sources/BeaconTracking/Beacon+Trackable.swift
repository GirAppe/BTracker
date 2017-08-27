//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation

enum BeaconTrackState {
    case none(for: Identifier?)
    case ranged(with: Proximity?, for: Identifier)
}

extension Beacon: Trackable {
    public var trackedBy: TrackType { return .beacon(self) }

    public func matches(any identifier: Identifier) -> Bool {
        return matches(proximity: identifier) || matches(motion: identifier)
    }

    public func deliver(event: TrackEvent) {
        handler?(event)
    }
}
