//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation

enum TrackState {
    case none(for: Identifier?)
    case ranged(with: Proximity?, for: Identifier)
}

public class TrackableProxy {
    let base: Trackable
    var state: TrackState = .none(for: nil)
    var handler: TrackEventHandler?

    init(_ base: Trackable) {
        self.base = base
    }

    func deliver(event: TrackEvent) {
        handler?(event)
    }

    func set(state: TrackState) {
        // TODO: implement delivering events logic - for location and motion

        switch trackedBy {
            case let .beacon(beacon) where beacon.isMotion:
                setMotionBeacon(state: state)
            case .beacon:
                setBeacon(state: state)
            default:
                self.state = state
        }
    }

    public func onEvent(_ handler: @escaping TrackEventHandler) {
        self.handler = handler
    }
}

extension TrackableProxy {
    fileprivate func setBeacon(state newState: TrackState) {
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

    fileprivate func setMotionBeacon(state newState: TrackState) {
        guard case let .beacon(beacon) = trackedBy, beacon.isMotion else { return }

//        if case let TrackState.ranged(with: _, for: someId) = newState {
//            print("RANGE IDENTIFIER = \(someId)")
//        }
//
//        if case let TrackState.none(for: someId) = newState {
//            print("NONE IDENTIFIER = \(someId ?? "unknown")")
//        }

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

extension TrackableProxy: Trackable {
    public var trackedBy: TrackType { return base.trackedBy }

    public func matches(any identifier: Identifier) -> Bool {
        return base.matches(any: identifier)
    }
}
