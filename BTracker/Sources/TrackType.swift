//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

public typealias Meters = Double
public typealias Proximity = Meters

public enum TrackType {
    case beacon(Beacon)
//    case location(in: CLLocationCoordinate2D, within: Meters) // Not implemented yet
    case movement(type: MovementType)

    func matches(beacon: CLBeacon) -> Bool {
        guard case let .beacon(proximityBeacon) = self else { return false }
        return proximityBeacon == beacon
    }
}

public enum MovementType {
    case stationary
    case driving
    case cycling
    case walking
}

extension CMMotionActivity {
    func applies(to movement: MovementType) -> Bool {
        switch movement {
            case .stationary: return stationary
            case .cycling: return cycling
            case .driving: return automotive
            case .walking: return walking
        }
    }
}
