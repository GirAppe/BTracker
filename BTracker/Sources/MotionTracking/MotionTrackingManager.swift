//
// Copyright (c) 2017 CocoaPods. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

class MotionTrackingManager: NSObject {
    fileprivate var motion: CMMotionActivityManager
    fileprivate var activity: CMMotionActivity?
    fileprivate let background = Background()

    fileprivate let operationQueue = OperationQueue() // OperationQueue.main

    fileprivate var tracked: [Identifier: MotionObject] = [:]

    override init() {
        self.motion = CMMotionActivityManager()

        super.init()
    }

    func start() {
        motion.startActivityUpdates(to: operationQueue) { activity in
            self.activity = activity
            self.updateMotionProxies()
        }
    }

    func updateMotionProxies() {
        guard let activity = self.activity else { return }

        tracked.values.forEach { object in
            if activity.applies(to: object.type) {
                object.state = .recognized
            } else {
                object.state = .notRecognized
            }
        }
    }
}

// MARK: - AnyTrackingManager
extension MotionTrackingManager: AnyTrackingManager {
    func track(_ item: Trackable) {
        guard let type: MovementType = {
            switch item.trackedBy {
            case let .movement(type:type): return type
            default: return nil
            }
        }() else { return }

        let motion = MotionObject(type: type)
        motion.set() { [weak item, weak self] state in
            guard item != nil else {
                self?.remove(motion)
                return
            }

            switch state {
                case .recognized: item?.deliver(event: .motionDidStart)
                case .notRecognized: item?.deliver(event: .motionDidEnd)
                default: break
            }
        }

        tracked[item.identifier] = motion
        updateMotionProxies()
    }

    func stop(tracking item: Trackable) {
        tracked.removeValue(forKey: item.identifier)
    }

    private func remove(_ object: MotionObject) {
        guard let index = tracked.index(where: { $0.1 === object }) else { return }
        tracked.remove(at: index)
    }
}
