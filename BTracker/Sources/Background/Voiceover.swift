//
//  Voiceover.swift
//  BTracker
//
//  Created by Andrzej Michnia on 22.04.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import AVFoundation

//sourcery: AutoMockable
public protocol VoiceoverType {
    func speak(_ speakable: Speakable)
}

public class Voiceover {
    private let synthesizer: AVSpeechSynthesizer

    public init() {
        synthesizer = AVSpeechSynthesizer()
    }

    public func speak(_ speakable: Speakable) {
        synthesizer.speak(speakable.utterance)
    }
}
