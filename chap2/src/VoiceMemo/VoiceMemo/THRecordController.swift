//
//  THRecordController.swift
//  VoiceMemo
//
//  Created by Joon on 03/05/2017.
//  Copyright © 2017 Joon. All rights reserved.
//

import UIKit
import AVFoundation

protocol THRecorderContollerDelegate {
    func interruptionBegan()
}

class THRecordController: NSObject {
    typealias RecordStopCompletion = (Bool) -> Void
    typealias RecordSaveCompletion = (Bool, Any) -> Void
    
    var formattedCurrentTime: String {
        let time = UInt(recorder?.currentTime ?? 0)
        let hours = time / 3600
        let min = (time / 60) % 60
        let sec = time % 60
//        print(" -- recorder.curTime:\(recorder?.currentTime)")
        return String(format: "%02d:%02d:%02d", hours, min, sec)
    }
    
    var delegate: THRecorderContollerDelegate?
    
    var player: AVAudioPlayer?
    var recorder: AVAudioRecorder?
    var stopCompletion: RecordStopCompletion?
    var meterTable: ThMeterTable
    
    override init() {

        let tmpDir = NSTemporaryDirectory()
        let fileURL = URL(fileURLWithPath: tmpDir).appendingPathComponent("memo.caf")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleIMA4,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitDepthHintKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            
        } catch let error as NSError {
           print("-- Err:\(error.localizedDescription)")
        }
        meterTable = ThMeterTable()
        super.init()
        
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true
        let result = recorder?.prepareToRecord()
        meterTable = ThMeterTable()
    }
    
    // record method
    func record() -> Bool {
        return recorder?.record() ?? false
    }
    
    func pause() {
        recorder?.pause()
    }
    
    func stop(completion: @escaping RecordStopCompletion) {
        stopCompletion = completion
        recorder?.stop()
    }
    
    func save(name: String, completion: RecordSaveCompletion) {
        let timestamp = Date.timeIntervalSinceReferenceDate
        let fileName = "\(name)-\(timestamp).m4a"
        
        let docsDir = URL(fileURLWithPath: documentsDirectory())
        let destURL = docsDir.appendingPathComponent(fileName)
        
        guard let srcURL = recorder?.url else {
            print("--FAIL: no srcURL")
            completion(false, "fail")
            return
        }
        
        do {
            try FileManager.default.copyItem(at: srcURL, to: destURL)
            completion(true, THMemo(title: name, url: destURL))
            print("--Success: Save memo ")
        } catch let error as NSError {
            print("--FAIL:  copy item ")
            completion(false, error)
        }
    }
    
    func documentsDirectory() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return path
    }

    func levels() -> THLevelPair? {
        recorder?.updateMeters()
        guard let avgPower = recorder?.averagePower(forChannel: 0), let peakPower = recorder?.peakPower(forChannel: 0) else {
            return nil
        }
        let linearLevel = meterTable.valueForPower(power: avgPower)
        let linearPeak = meterTable.valueForPower(power: peakPower)
        return THLevelPair(level: linearLevel, peakLevel: linearPeak)
    }
    
    // player method
    func playbackMemo(memo: THMemo) -> Bool {
        player?.stop()
        do {
            player = try AVAudioPlayer(contentsOf: memo.url)
            player?.play()
        } catch {
            return false
        }
        return true
    }
}

extension THRecordController: AVAudioRecorderDelegate {
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        delegate?.interruptionBegan()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        stopCompletion?(flag)
    }    
}
