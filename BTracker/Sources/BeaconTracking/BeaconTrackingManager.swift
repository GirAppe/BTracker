//
// Copyright (c) 2017 CocoaPods. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconTrackingManager: NSObject {
    let location: CLLocationManager
    var tracked: [Trackable] = []

    init(location: CLLocationManager? = nil) {
        self.location = location ?? CLLocationManager()
        super.init()

        self.location.delegate = self
    }

    func start() {
        location.requestAlwaysAuthorization()
        location.allowsBackgroundLocationUpdates = true
    }
}

// MARK: - AnyTrackingManager
extension BeaconTrackingManager: AnyTrackingManager {
    func track(_ item: Trackable) {
        switch item.trackedBy {
            case let .beacon(beacon):
                setupTracking(for: beacon)
                tracked.append(item)
            default:
                break
        }
    }

    func stop(tracking item: Trackable) {
        switch item.trackedBy {
            case let .beacon(beacon): stopTracking(for: beacon)
            default: break
        }
    }

    private func setupTracking(for beacon: Beacon) {
        if beacon.isMotion {
            guard let proximityRegion = beacon.proximity else { return }
            location.startRangingBeacons(in: proximityRegion)
            guard let motionRegion = beacon.motion else { return }
            location.startRangingBeacons(in: motionRegion)
        } else {
            guard let proximityRegion = beacon.proximity else { return }
            location.startMonitoring(for: proximityRegion)
            location.startRangingBeacons(in: proximityRegion)
        }
    }

    private func stopTracking(for beacon: Beacon) {
        if beacon.isMotion {
            guard let proximityRegion = beacon.proximity else { return }
            location.stopRangingBeacons(in: proximityRegion)
            tracked.remove(where: { $0.matches(any: beacon.proximityIdentifier) })
            guard let motionRegion = beacon.motion else { return }
            tracked.remove(where: { $0.matches(any: beacon.motionIdentifier) })
            location.stopRangingBeacons(in: motionRegion)
        } else {
            guard let proximityRegion = beacon.proximity else { return }
            tracked.remove(where: { $0.matches(any: beacon.proximityIdentifier) })
            location.stopMonitoring(for: proximityRegion)
            location.stopRangingBeacons(in: proximityRegion)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension BeaconTrackingManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        debugPrint("Ranged beacons \(beacons)")

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
            .sorted(by: { (first, second) -> Bool in
                first.proximityOrder < second.proximityOrder
            })

            (proxy as? TrackableProxy)?.set(state: .ranged(with: matching.first?.accuracy, for: region.identifier))
        }

        rangeResult?.rest.forEach { proxy in
            (proxy as? TrackableProxy)?.set(state: .none(for: region.identifier))
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        debugPrint("Ranged enter region")

        let tracked = self.tracked.filter { proxy -> Bool in
            return proxy.matches(any: region.identifier)
        }

        tracked.forEach { proxy in
            (proxy as? TrackableProxy)?.set(state: .ranged(with: nil, for: region.identifier))
        }
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        debugPrint("Ranged exit region")

        let tracked = self.tracked.filter { proxy -> Bool in
            return proxy.matches(any: region.identifier)
        }

        tracked.forEach { proxy in
            (proxy as? TrackableProxy)?.set(state: .none(for: region.identifier))
        }
    }
}
