//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation

extension Beacon: Trackable {
    public var trackedBy: TrackType { return .beacon(self) }
}
