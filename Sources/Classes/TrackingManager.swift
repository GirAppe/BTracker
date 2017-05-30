//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation

public class TrackingManager: NSObject {
    var manager: CLLocationManager
    var tracked: [TrackableProxy] = []

    public init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
        manager.delegate = self
    }

    public func start() {
        manager.requestAlwaysAuthorization()
    }
}

extension TrackingManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let tracked = self.tracked.filter { proxy -> Bool in
            return proxy.matches(any: region.identifier)
        }

        let rangeResult = try? tracked.split { proxy -> Bool in
            return beacons.contains { proxy.trackedBy.matches(beacon: $0) }
        }

        rangeResult?.passing.forEach { proxy in
            let matching = beacons
            .filter({
                proxy.trackedBy.matches(beacon: $0)
            })
            .sorted(by: {
                $0.0.accuracy < $0.1.accuracy
            })

            proxy.set(state: .ranged(with: matching.first?.accuracy, for: region.identifier))
        }

        rangeResult?.rest.forEach { proxy in
            proxy.set(state: .none(for: region.identifier))
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let tracked = self.tracked.filter { proxy -> Bool in
            return proxy.matches(any: region.identifier)
        }

        tracked.forEach { proxy in
            proxy.set(state: .ranged(with: nil, for: region.identifier))
        }
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let tracked = self.tracked.filter { proxy -> Bool in
            return proxy.matches(any: region.identifier)
        }

        tracked.forEach { proxy in
            proxy.set(state: .none(for: region.identifier))
        }
    }
}

extension TrackingManager {
    public func track(_ item: Trackable) -> TrackableProxy {
        let proxy = TrackableProxy(item)

        tracked.append(proxy)

        switch proxy.trackedBy {
            case let .beacon(beacon): setupTracking(for: beacon)
            // TODO: Other cases setup
            default: break
        }

        return proxy
    }

    private func setupTracking(for beacon: Beacon) {
        if beacon.isMotion {
            guard let proximityRegion = beacon.proximity else { return }
            manager.startRangingBeacons(in: proximityRegion)
            guard let motionRegion = beacon.motion else { return }
            manager.startRangingBeacons(in: motionRegion)
        } else {
            guard let proximityRegion = beacon.proximity else { return }
            manager.startMonitoring(for: proximityRegion)
            manager.startRangingBeacons(in: proximityRegion)
        }
    }

    private func stopTracking(for beacon: Beacon) {
        if beacon.isMotion {
            guard let proximityRegion = beacon.proximity else { return }
            manager.stopRangingBeacons(in: proximityRegion)
            guard let motionRegion = beacon.motion else { return }
            manager.stopRangingBeacons(in: motionRegion)
        } else {
            guard let proximityRegion = beacon.proximity else { return }
            manager.stopMonitoring(for: proximityRegion)
            manager.stopRangingBeacons(in: proximityRegion)
        }
    }
}
