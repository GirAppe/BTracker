//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation

struct Track: Equatable {
    let proximity: Meters?
    let coordinate: CLLocationCoordinate2D?

    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.proximity == rhs.proximity && lhs.coordinate?.latitude == rhs.coordinate?.latitude && lhs.coordinate?.longitude == rhs.coordinate?.longitude
    }
}
