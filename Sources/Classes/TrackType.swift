//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation

public typealias Meters = Float

public enum TrackType {
    case beacon(Beacon)
    case location(in: CLLocationCoordinate2D, within: Meters)
    case movement(type: MovementType)
}

public enum MovementType {
    case stationary
    case driving
    case cycling
}
