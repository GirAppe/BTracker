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

        guard let beacon = Beacon(identifier: "ice", proximityUUID: "B9407F30-F5F8-466E-AFF9-25556B57FE6A", motionUUID: "39407F30-F5F8-466E-AFF9-25556B57FE6A") else {
            assertionFailure("Invalid becaon Ids!!!")
            return
        }

        manager.track(beacon).onEvent { event in
            switch event {
                case .regionDidEnter:
                    print("Region did enter")
                case .regionDidExit:
                    print("Region did exit")
                case .motionDidStart:
                    print("Motion did start")
                case .motionDidEnd:
                    print("Motion did end")
                case .proximityDidChange(let proximity):
                    if let proximity = proximity {
                        print("Proximity changed: \(proximity)")
                    } else {
                        print("Proximity changed: unknown")
                    }
            }
        }
    }
}

