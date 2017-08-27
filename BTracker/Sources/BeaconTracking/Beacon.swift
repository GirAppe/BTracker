//
//  Copyright © 2017 GirAppe Studio. All rights reserved.
//

import Foundation
import CoreLocation

public class Beacon {
    public let identifier: Identifier
    public let proximityUUID: UUID
    public let motionUUID: UUID?
    public let major: Value<Int>
    public let minor: Value<Int>

    var handler: TrackEventHandler?

    init?(identifier: Identifier, proximityUUID: String, motionUUID: String? = nil, major: Value<Int> = .any, minor: Value<Int> = .any) {
        guard let proximityUUID = UUID(uuidString: proximityUUID) else {
            return nil
        }

        let motionUUID = UUID(uuidString: motionUUID)
        self.identifier = identifier
        self.proximityUUID = proximityUUID
        self.motionUUID = motionUUID
        self.major = major
        self.minor = minor
    }

    public func onEvent(_ handler: @escaping TrackEventHandler) {
        self.handler = handler
    }
}

extension Beacon {
    public var isMotion: Bool { return motionUUID != nil }
    var proximityIdentifier: Identifier { return "\(proximityUUID.uuidString).\(identifier)" }
    var motionIdentifier: Identifier { return "\(motionUUID?.uuidString ?? "motion").\(identifier)" }

    internal var proximity: CLBeaconRegion? { return region(uuid: proximityUUID, identifier: proximityIdentifier) }
    internal var motion: CLBeaconRegion? { return region(uuid: motionUUID, identifier: motionIdentifier) }

    public convenience init?(identifier: Identifier, proximityUUID: String, motionUUID: String? = nil) {
        self.init(identifier: identifier, proximityUUID: proximityUUID, motionUUID: motionUUID, major: .any, minor: .any)
    }

    public convenience init?(identifier: Identifier, proximityUUID: String, major: Int, motionUUID: String? = nil) {
        self.init(identifier: identifier, proximityUUID: proximityUUID, motionUUID: motionUUID, major: .some(major), minor: .any)
    }

    public convenience init?(identifier: Identifier, proximityUUID: String, major: Int, minor: Int, motionUUID: String? = nil) {
        self.init(identifier: identifier, proximityUUID: proximityUUID, motionUUID: motionUUID, major: .some(major), minor: .some(minor))
    }
}

extension Beacon: Equatable {
    public static func == (lhs: Beacon, rhs: Beacon) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public static func == (lhs: Beacon, rhs: CLBeacon) -> Bool {
        let proximity = lhs.proximityUUID == rhs.proximityUUID
        let motion = lhs.motionUUID == rhs.proximityUUID
        let majorMatches = lhs.major == rhs.major.intValue
        let minorMatches = lhs.minor == rhs.minor.intValue
        return (proximity || motion) && majorMatches && minorMatches
    }

    public func matches(proximity identifier: Identifier) -> Bool {
        return self.proximityIdentifier == identifier
    }

    public func matches(motion identifier: Identifier) -> Bool {
        return self.motionIdentifier == identifier
    }
}

fileprivate extension Beacon {
    func region(uuid: UUID?, identifier: Identifier) -> CLBeaconRegion? {
        guard let uuid = uuid else { return nil }

        switch (major, minor) {
            case let (.some(major), .any): return CLBeaconRegion(proximityUUID: uuid, major: UInt16(major), identifier: identifier)
            case let (.some(major), .some(minor)): return CLBeaconRegion(proximityUUID: uuid, major: UInt16(major), minor: UInt16(minor), identifier: identifier)
            default: return CLBeaconRegion(proximityUUID: uuid, identifier: identifier)
        }
    }
}

fileprivate extension UUID {
    init?(uuidString: String?) {
        guard let uuidString = uuidString else { return nil }
        guard let uuid = UUID(uuidString: uuidString) else { return nil }
        self = uuid
    }
}

extension CLBeacon {
    var knownProximity: Proximity? {
        return accuracy >= 0 ? Proximity(accuracy) : nil
    }
    var proximityOrder: Proximity {
        return accuracy >= 0 ? Proximity(accuracy) : Proximity.infinity
    }
}
