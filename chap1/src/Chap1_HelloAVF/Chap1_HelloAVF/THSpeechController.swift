//
//  THSpeechController.swift
//  Chap1_HelloAVF
//
//  Created by Joon on 20/04/2017.
//  Copyright © 2017 Joon. All rights reserved.
//

import UIKit
import AVFoundation

class THSpeechController {
    
    var synthesizer: AVSpeechSynthesizer
    var voices: [AVSpeechSynthesisVoice]
    var speechStrings: [String] = ["Hello AV Foundation. How are you?",
                                   "I'm well! Thanks for asking.",
                                   "Are you excited about the book?",
                                   "Very! I have always felt so misunderstood.",
                                   "What's your favorite feature?",
                                   "Oh, they're all my babies.  I couldn't possibly choose.",
                                   "It was great to speak with you!",
                                   "The pleasure was all mine!  Have fun!"]
    
    init() {
        synthesizer = AVSpeechSynthesizer()
        voices = [AVSpeechSynthesisVoice(language: "en-US")!, AVSpeechSynthesisVoice(language: "en-GB")!]
    }
    
//    class func speechController() -> THSpeechController {
//        return THSpeechController()
//    }
    
    func beginConversation() {
        
        for (idx, val) in speechStrings.enumerated() {
            let utterance = AVSpeechUtterance(string: val)
            utterance.voice = voices[idx % 2]
            utterance.rate = 0.5
            utterance.pitchMultiplier = 0.8
            utterance.postUtteranceDelay = 0.1
            synthesizer.speak(utterance)
        }
    }
    
    func buildSpeechStrings() -> [String] {
        return ["Hello AV Foundation. How are you?",
                "I'm well! Thanks for asking.",
                "Are you excited about the book?",
                "Very! I have always felt so misunderstood.",
                "What's your favorite feature?",
                "Oh, they're all my babies.  I couldn't possibly choose.",
                "It was great to speak with you!",
                "The pleasure was all mine!  Have fun!"]
    }
}
