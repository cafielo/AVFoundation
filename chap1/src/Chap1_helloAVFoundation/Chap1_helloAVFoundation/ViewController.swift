//
//  ViewController.swift
//  Chap1_helloAVFoundation
//
//  Created by Joon on 20/04/2017.
//  Copyright © 2017 Joon. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "Hello world")
        synthesizer.speak(utterance)
    }

    


}

