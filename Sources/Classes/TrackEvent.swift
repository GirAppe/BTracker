//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation

typealias TrackEventHandler = (_ event: TrackEvent) -> Void

enum TrackEvent {
    case motionDidStart
    case motionDidEnd
    case proximityDidChange(proximity: Meters)
    case regionDidEnter
    case regionDidExit
}

extension TrackEvent: Equatable {
    static func == (lhs: TrackEvent, rhs: TrackEvent) -> Bool {
        switch (lhs, rhs) {
            default: return false
        }
    }
}