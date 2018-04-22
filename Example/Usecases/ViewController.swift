//
//  ViewController.swift
//  BTracker
//
//  Created by git on 05/29/2017.
//  Copyright (c) 2017 git. All rights reserved.
//

import UIKit
import BTracker

class Walking: Trackable {
    var identifier: Identifier
    var trackedBy: TrackType = TrackType.movement(type: .walking)

    func matches(any identifier: Identifier) -> Bool {
        return false
    }

    var handler: (TrackEvent) -> Void

    init(handler: @escaping (TrackEvent) -> Void) {
        self.handler = handler
        self.identifier = UUID().uuidString
    }

    func deliver(event: TrackEvent) {
        handler(event)
    }
}

class Standing: Trackable {
    var identifier: Identifier
    var trackedBy: TrackType = TrackType.movement(type: .stationary)

    func matches(any identifier: Identifier) -> Bool {
        return false
    }

    var handler: (TrackEvent) -> Void

    init(handler: @escaping (TrackEvent) -> Void) {
        self.handler = handler
        self.identifier = UUID().uuidString
    }

    func deliver(event: TrackEvent) {
        handler(event)
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var stationaryLabel: UILabel!
    @IBOutlet weak var walkingLabel: UILabel!

    let manager = TrackingManager()
    let voiceover = Voiceover()
    fileprivate let background = Background()

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.start()

        let standing = Standing() { state in
            switch state {
            case .motionDidStart:
                self.voiceover.speak("Standing")
            case .motionDidEnd:
                self.voiceover.speak("Not standing")
            default:
                break
            }
        }

        let walking = Walking() { state in
            switch state {
                case .motionDidStart:
                    self.voiceover.speak("Walking")
                case .motionDidEnd:
                    self.voiceover.speak("Not walking")
                default:
                    break
            }
        }

        manager.track(standing)
        manager.track(walking)

//        let virtual = Beacon(identifier: "simulated", proximityUUID: "8492E75F-4FD6-469D-B132-043FE94921D8")!
//        let ice = Beacon(identifier: "ice", proximityUUID: "B9407F30-F5F8-466E-AFF9-25556B57FE6A", major: 33, minor: 33, motionUUID: "39407F30-F5F8-466E-AFF9-25556B57FE6A")!
//        let blueberry = Beacon(identifier: "blueberry", proximityUUID: "B9407F30-F5F8-466E-AFF9-25556B57FE6A", major: 1, minor: 1)!
//
//        virtual.onEvent { event in
//            switch event {
//            case .regionDidEnter:
//                send("SIM Region did enter")
//            case .regionDidExit:
//                send("SIM Region did exit")
//            case .motionDidStart:
//                send("SIM Motion did start")
//            case .motionDidEnd:
//                send("SIM Motion did end")
//            case .proximityDidChange(let proximity):
//                if let proximity = proximity {
//                    print("SIM Proximity changed: \(proximity)")
//                } else {
//                    print("SIM Proximity changed: unknown")
//                }
//            }
//        }
//
//        ice.onEvent { event in
//            switch event {
//            case .regionDidEnter:
//                send("ICE Region did enter")
//            case .regionDidExit:
//                send("ICE Region did exit")
//            case .motionDidStart:
//                send("ICE Motion did start")
//            case .motionDidEnd:
//                send("ICE Motion did end")
//            case .proximityDidChange(let proximity):
//                if let proximity = proximity {
//                    print("ICE Proximity changed: \(proximity)")
//                } else {
//                    print("ICE Proximity changed: unknown")
//                }
//            }
//        }
//
//        blueberry.onEvent { event in
//            switch event {
//            case .regionDidEnter:
//                send("BLUEBERRY Region did enter")
//            case .regionDidExit:
//                send("BLUEBERRY Region did exit")
//            case .motionDidStart:
//                send("BLUEBERRY Motion did start")
//            case .motionDidEnd:
//                send("BLUEBERRY Motion did end")
//            case .proximityDidChange(let proximity):
//                if let proximity = proximity {
//                    print("BLUEBERRY Proximity changed: \(proximity)")
//                } else {
//                    print("BLUEBERRY Proximity changed: unknown")
//                }
//            }
//        }
//
//        manager.track(blueberry)
    }

    @IBAction func toggleBackground(_ sender: UISwitch) {
        if sender.isOn {
            background.start()
            background.every(30) {
                self.voiceover.speak("active")
            }
        } else {
            background.stop()
        }
    }
}

func send(_ info: String) {
    print(info)
    let local = UILocalNotification()
    local.alertTitle = info
    UIApplication.shared.scheduleLocalNotification(local)
}
