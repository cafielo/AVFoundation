//
//  THPlayerController.swift
//  Chap2_AudioLooper
//
//  Created by Joon on 21/04/2017.
//  Copyright © 2017 Joon. All rights reserved.
//



import UIKit
import AVFoundation

protocol THPlayerControllerDelegate: NSObjectProtocol {
    func playbackStopped()
    func playbackBegan()
}

class THPlayerController: NSObject {
    
    var players: [AVAudioPlayer] = []
    var isPlaying: Bool = false
    var delegate: THPlayerControllerDelegate?
    
    func playerForFile(name: String) -> AVAudioPlayer? {
        guard let fileURL = Bundle.main.url(forResource: name, withExtension: "caf") else {
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.numberOfLoops = -1
            player.enableRate = true
            player.prepareToPlay()
            return player
        } catch let error as NSError {
            print(" -- error creating audioplayer:\(error.localizedDescription)")
            return nil
        }
    }
    
    override init() {
        super.init()
        
        let guitarPlayer = playerForFile(name: "guitar")
        let bassPlayer = playerForFile(name: "bass")
        let drumsPlayer = playerForFile(name: "drums")
        guitarPlayer?.delegate = self
        players = [guitarPlayer!, bassPlayer!, drumsPlayer!]
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(notification:)), name: Notification.Name.AVAudioSessionRouteChange, object: AVAudioSession.sharedInstance())
        
    }
    
    func play() {
        guard isPlaying == false else { return }
        if let firstPlayer = players.first {
            let delayTime = firstPlayer.deviceCurrentTime + 0.01
            players.forEach { $0.play(atTime: delayTime) }
            isPlaying = true
        }
    }
    
    func stop() {
        guard isPlaying else { return }
        players.forEach {
            $0.stop()
            $0.currentTime = 0
        }
        isPlaying = false
    }
    
    func adjustRate(rate: Float) {
        players.forEach { $0.rate = rate }
    }
    
    func adjustPan(pan: Float, playerIndex: Int) {
        guard playerIndex < players.count else { return }
        players[playerIndex].pan = pan
    }
    
    func adjustVolume(volume: Float, playerIndex: Int) {
        guard playerIndex < players.count else { return }
        players[playerIndex].volume = volume
    }
}

extension THPlayerController: AVAudioPlayerDelegate {
    
}

// MARK: handling Interruption
extension THPlayerController {
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        stop()
        delegate?.playbackStopped()
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer, option: UInt) {
        if option == AVAudioSessionInterruptionOptions.shouldResume.rawValue {
            play()
            delegate?.playbackBegan()
        }
    }
    
    func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt, reason == AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue {
            let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
            let previousOutput = previousRoute?.outputs.first
            if let portType = previousOutput?.portType, portType == AVAudioSessionPortHeadphones {
                stop()
                delegate?.playbackStopped()
            }
        }
    }
}
