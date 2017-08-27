//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

public protocol AnyTrackingManager {
    func track(_ item: Trackable)
    func stop(tracking item: Trackable)
}

public class TrackingManager: NSObject {
    let location: CLLocationManager
    let beacon: BeaconTrackingManager
    let motion: MotionTrackingManager

    var tracked: [TrackableProxy] = [] {
        didSet { start() }
    }

    public var currentLocation: CLLocation? {
        return location.location
    }

    public override init() {
        let location = CLLocationManager()
        self.location = location
        self.beacon = BeaconTrackingManager(location: location)
        self.motion = MotionTrackingManager()
        super.init()
    }

    public func start() {
        location.requestAlwaysAuthorization()
        location.allowsBackgroundLocationUpdates = true

        if tracked.contains(where: { (proxy: TrackableProxy) -> Bool in
            if case TrackType.beacon = proxy.trackedBy {
                return true
            } else {
                return false
            }
        }) {
            beacon.start()
        }

        if tracked.contains(where: { (proxy: TrackableProxy) -> Bool in
            if case TrackType.movement = proxy.trackedBy {
                return true
            } else {
                return false
            }
        }) {
            motion.start()
        }
    }
}

// MARK: - AnyTrackingManager
extension TrackingManager: AnyTrackingManager {
    public func track(_ item: Trackable) {
        track(item: item)
        start()
    }

    public func stop(tracking item: Trackable) {
        beacon.stop(tracking: item)
        motion.stop(tracking: item)
        tracked.remove { proxy in
            proxy.matches(any: item.identifier)
        }
    }

    public func track(_ item: MultiTrackable) {
        track(item: item)
    }

    public func stop(tracking item: MultiTrackable) {
        item.trackedBy.forEach(self.stop)
    }

    @discardableResult
    private func track(item: Trackable) -> TrackableProxy {
        let proxy = TrackableProxy(item)

        tracked.append(proxy)

        switch proxy.trackedBy {
        case .beacon:
            beacon.track(proxy)
        case .movement:
            motion.track(proxy)
        }

        return proxy
    }

    @discardableResult
    private func track(item: MultiTrackable) -> [TrackableProxy] {
        let proxies = item.trackedBy.map {
            self.track(item: $0)
        }

        proxies.forEach { proxy in
            proxy.onEvent { item.delivered(event: $0, by: proxy.base) }
        }
        return proxies
    }
}
