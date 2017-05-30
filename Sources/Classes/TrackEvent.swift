//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation

public typealias TrackEventHandler = (_ event: TrackEvent) -> Void

public enum TrackEvent {
    case motionDidStart
    case motionDidEnd
    case proximityDidChange(Proximity?)
    case regionDidEnter
    case regionDidExit
}

extension TrackEvent: Equatable {
    public static func == (lhs: TrackEvent, rhs: TrackEvent) -> Bool {
        switch (lhs, rhs) {
            case let (.proximityDidChange(lhsProximity), .proximityDidChange(rhsProximity)): return lhsProximity == rhsProximity
            case (.motionDidStart, .motionDidStart):    return true
            case (.motionDidEnd, .motionDidEnd):        return true
            case (.regionDidEnter, .regionDidEnter):    return true
            case (.regionDidExit, .regionDidExit):      return true
            default:                                    return false
        }
    }
}
