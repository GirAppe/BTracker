//
// Copyright (c) 2017 CocoaPods. All rights reserved.
//

import Foundation

class MotionObject {
    enum State {
        case unknown
        case recognized
        case notRecognized
    }

    let type: MovementType
    var state: State = .unknown {
        didSet { self.handler?(state) }
    }
    var handler: ((State) -> Void)?

    init(type: MovementType) {
        self.type = type
    }

    func set(handler: ((State) -> Void)?) {
        self.handler = handler
    }
}
