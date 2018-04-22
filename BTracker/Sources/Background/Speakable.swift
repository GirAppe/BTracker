//
//  Speakable.swift
//  BTracker
//
//  Created by Andrzej Michnia on 22.04.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import AVFoundation

public protocol Speakable {
    var speakText: String { get }
    var utterance: AVSpeechUtterance { get }
    var rate: Float { get }
    var voice: AVSpeechSynthesisVoice? { get }
}

extension Speakable {
    public var utterance: AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: speakText)
        utterance.rate = rate
        utterance.voice = voice
        return utterance
    }
    public var rate: Float { return 0.5 }
    public var voice: AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(language: "en-EN")
    }
}

extension String: Speakable {
    public var speakText: String { return self }
}

extension Array: Speakable where Element: Speakable {
    public var speakText: String {
        return map { $0.speakText }.joined(separator: " ")
    }
}
