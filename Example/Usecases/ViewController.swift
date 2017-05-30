//
//  ViewController.swift
//  BTracker
//
//  Created by git on 05/29/2017.
//  Copyright (c) 2017 git. All rights reserved.
//

import UIKit
import BTracker

class ViewController: UIViewController {
    let manager = TrackingManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.start()

        let beacon = Beacon(identifier: "ice", proximityUUID: "B9407F30-F5F8-466E-AFF9-25556B57FE6A", major: 33, minor: 33, motionUUID: "39407F30-F5F8-466E-AFF9-25556B57FE6A")!
        let beacon2 = Beacon(identifier: "blueberry", proximityUUID: "B9407F30-F5F8-466E-AFF9-25556B57FE6A", major: 1, minor: 1)!
        manager.track(beacon).onEvent { event in
            switch event {
                case .regionDidEnter:
                    print("ICE Region did enter")
                case .regionDidExit:
                    print("ICE Region did exit")
                case .motionDidStart:
                    print("ICE Motion did start")
                case .motionDidEnd:
                    print("ICE Motion did end")
                case .proximityDidChange(let proximity):
                    if let proximity = proximity {
                        print("ICE Proximity changed: \(proximity)")
                    } else {
                        print("ICE Proximity changed: unknown")
                    }
            }
        }

        manager.track(beacon2).onEvent { event in
            switch event {
                case .regionDidEnter:
                    print("BLUEBERRY Region did enter")
                case .regionDidExit:
                    print("BLUEBERRY Region did exit")
                case .motionDidStart:
                    print("BLUEBERRY Motion did start")
                case .motionDidEnd:
                    print("BLUEBERRY Motion did end")
                case .proximityDidChange(let proximity):
                    if let proximity = proximity {
                        print("BLUEBERRY Proximity changed: \(proximity)")
                    } else {
                        print("BLUEBERRY Proximity changed: unknown")
                    }
            }
        }
    }
}

