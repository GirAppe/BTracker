//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation

class TrackableProxy {
    let base: Trackable
    var state: BeaconTrackState = .none(for: nil)
    var handler: TrackEventHandler?

    init(_ base: Trackable) {
        self.base = base
    }

    func deliver(event: TrackEvent) {
        handler?(event)
        base.deliver(event: event)
    }

    func onEvent(_ handler: @escaping TrackEventHandler) {
        self.handler = handler
    }
}

// MARK: - Beacon tracking state
extension TrackableProxy {
    func set(state: BeaconTrackState) {
        switch trackedBy {
        case let .beacon(beacon) where beacon.isMotion:
            setMotionBeacon(state: state)
        case .beacon:
            setBeacon(state: state)
        default:
            self.state = state
        }
    }

    fileprivate func setBeacon(state newState: BeaconTrackState) {
        guard case let .beacon(beacon) = trackedBy, !beacon.isMotion else { return }

        switch (state, newState) {
            case let (.none, .ranged(with: proximity, for: _)):
                deliver(event: .regionDidEnter)
                deliver(event: .proximityDidChange(proximity))
                self.state = newState
            case let (.ranged(with: oldProximity, for: _), .ranged(with: proximity, for: _)) where oldProximity != proximity:
                deliver(event: .proximityDidChange(proximity))
                self.state = newState
            case (.ranged, .none):
                deliver(event: .regionDidExit)
                self.state = newState
            default:
                break
        }
    }

    fileprivate func setMotionBeacon(state newState: BeaconTrackState) {
        guard case let .beacon(beacon) = trackedBy, beacon.isMotion else { return }

        switch (state, newState) {
        // Ranging - makes sense only from none or unknown state
        case let (.none, .ranged(with: proximity, for: id)) where beacon.matches(proximity: id):
            deliver(event: .regionDidEnter)
            deliver(event: .proximityDidChange(proximity))
            self.state = newState
        case let (.none, .ranged(with: proximity, for: id)) where beacon.matches(motion: id):
            deliver(event: .regionDidEnter)
            deliver(event: .motionDidStart)
            deliver(event: .proximityDidChange(proximity))
            self.state = newState
        // Proximity and motion change
        // If ranged same
        case let (.ranged(with: _, for: oldId), .ranged(with: proximity, for: newId)) where oldId == newId:
            deliver(event: .proximityDidChange(proximity))
            self.state = newState
        // If ranged different - motion changed some way
        case let (.ranged, .ranged(with: proximity, for: newId)) where beacon.matches(motion: newId):
            deliver(event: .motionDidStart)
            deliver(event: .proximityDidChange(proximity))
            self.state = newState
        case let (.ranged, .ranged(with: proximity, for: newId)) where beacon.matches(proximity: newId):
            deliver(event: .motionDidEnd)
            deliver(event: .proximityDidChange(proximity))
            self.state = newState
        // Leaving region - only when leavin same as last ranged, otherwise might be glitch with changing motion
        case let (.ranged(with: _, for: oldId), .none(for: newId)) where beacon.matches(proximity: oldId) && oldId == newId:
            deliver(event: .regionDidExit)
            self.state = newState
        case let (.ranged(with: _, for: oldId), .none(for: newId)) where beacon.matches(motion: oldId) && oldId == newId:
            deliver(event: .motionDidEnd)
            deliver(event: .regionDidExit)
            self.state = newState
        default:
            break
        }
    }
}

// MARK: - Trackable
extension TrackableProxy: Trackable {
    var identifier: Identifier { return base.identifier }
    var trackedBy: TrackType { return base.trackedBy }

    func matches(any identifier: Identifier) -> Bool { return base.matches(any: identifier) }
}
