//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation

public protocol Trackable {
    var trackedBy: TrackType { get }

    func matches(any identifier: Identifier) -> Bool
    func deliver(event: TrackEvent)
}

extension Trackable {
    public func deliver(event: TrackEvent) { }
}

public protocol MultiTrackable {
    var trackedBy: [Trackable] { get }

    func delivered(event: TrackEvent, by trackable: Trackable)
}
