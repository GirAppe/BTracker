//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation

class TrackableProxy {
    let base: Trackable
    var handler: TrackEventHandler?

    init(_ base: Trackable) {
        self.base = base
    }

    func deliver(event: TrackEvent) {
        // ???
    }
}

extension TrackableProxy: Trackable {
    var trackedBy: TrackType { return base.trackedBy }

    func onEvent(_ handler: @escaping TrackEventHandler) {
        self.handler = handler
    }
}

class TrackingManager {
    func track(_ item: Trackable) -> TrackableProxy {
        return TrackableProxy(item)
    }
}
