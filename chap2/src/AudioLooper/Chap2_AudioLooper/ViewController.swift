//
//  ViewController.swift
//  Chap2_AudioLooper
//
//  Created by Joon on 21/04/2017.
//  Copyright © 2017 Joon. All rights reserved.
//


import UIKit
import AVFoundation


class THMainViewController: UIViewController {
    
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var rateKnob: THGreenControlKnob!
    @IBOutlet var panKnobs: [THOrangeControlKnob]!
    @IBOutlet var volumeKnobs: [THOrangeControlKnob]!
    
    let controller = THPlayerController()
    
    @IBOutlet weak var playButton: THPlayButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controller.delegate = self
        self.rateKnob.minimumValue = 0.5
        self.rateKnob.maximumValue = 1.5
        self.rateKnob.value = 1.0
        self.rateKnob.defaultValue = 1.0
        
        
        // Panning L = -1, C = 0, R = 1
        for knob in panKnobs {
            knob.minimumValue = -1.0
            knob.maximumValue = 1.0
            knob.value = 0.0
            knob.defaultValue = 0.0
        }
        
        // Volume Ranges from 0..1
        for knob in self.volumeKnobs {
            knob.minimumValue = 0.0
            knob.maximumValue = 1.0
            knob.value = 1.0
            knob.defaultValue = 1.0
        }
    }
    
    
    @IBAction func play(_ sender: UIButton) {
        if controller.isPlaying == false {
            controller.play()
            playLabel.text = "stop"
        } else {
            controller.stop()
            playLabel.text = "play"
        }
        playButton.isSelected = !playButton.isSelected
    }
    
    @IBAction func adjustRate(_ sender: THControlKnob) {
        controller.adjustRate(rate: sender.value)
    }
    
    
    @IBAction func adjustPan(_ sender: THControlKnob) {
        
        controller.adjustPan(pan: sender.value, playerIndex: sender.tag)
    }
    
    
    @IBAction func adjustVolume(_ sender: THControlKnob) {
        controller.adjustVolume(volume: sender.value, playerIndex: sender.tag)
    }
    
}

extension THMainViewController: THPlayerControllerDelegate {
    func playbackStopped() {
        playButton.isSelected = false
        playLabel.text = "Play"
    }
    
    func playbackBegan() {
        playButton.isSelected = true
        playLabel.text = "Stop"
    }
}
