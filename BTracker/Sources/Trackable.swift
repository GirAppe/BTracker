//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation

public protocol Trackable {
    var trackedBy: TrackType { get }

    func matches(any identifier: Identifier) -> Bool
}
