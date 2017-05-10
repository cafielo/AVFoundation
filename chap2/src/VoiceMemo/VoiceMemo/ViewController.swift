//
//  ViewController.swift
//  VoiceMemo
//
//  Created by Joon on 02/05/2017.
//  Copyright © 2017 Joon. All rights reserved.
//

import UIKit

let Cancel_Button = 0
let OK_Button = 1
let Memo_Cell = "memoCell"
let Memos_Archive = "memos.archive"

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var levelMeterView: THLevelMeterView!
    
    var memos: [THMemo] = []
    var levelTimer: CADisplayLink?
    var timer: Timer?
    var controller: THRecordController = THRecordController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller.delegate = self
        stopButton.isEnabled = false
        
        recordButton.setImage(UIImage(named: "record"), for: .normal)
        recordButton.setImage(UIImage(named: "pause"), for: .selected)
        stopButton.setImage(UIImage(named: "stop"), for: .normal)
        
        
        do {
            let data = try Data(contentsOf: archiveURL)
            if let memoDatas = NSKeyedUnarchiver.unarchiveObject(with: data) as? [THMemo] {
                memos.append(contentsOf: memoDatas)
            }
        } catch let error as NSError {
            print(" cant get data from archive err:\(error.localizedDescription)")
            memos = []
        }
    }
    
    // MARK: Archiving
//    var archiveURL: URL {
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let url = URL(fileURLWithPath: path)
//        return url.appendingPathComponent(Memos_Archive)
//    }
    
    var archiveURL: URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = (paths.first ?? "") as NSString
        let archivePath = docsDir.appendingPathComponent(Memos_Archive)
        return URL(fileURLWithPath: archivePath)
    }
    
    func saveMemos() {
        let fileData = NSKeyedArchiver.archivedData(withRootObject: memos)
        do {
            try fileData.write(to: archiveURL)
        } catch {
            print(" cant write file")
        }
    }

    // MARK: Recorder Control
    
    @IBAction func record(_ sender: UIButton) {
        stopButton.isEnabled = true
        if sender.isSelected == false {
            startMeterTimer()
            startTimer()
            controller.record()
            print(" record start...")
        } else {
            stopMeterTimer()
            stopTimer()
            controller.pause()
            print(" record pause...")
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        stopMeterTimer()
        recordButton.isSelected = false
        stopButton.isEnabled = false
        controller.stop(completion: { result in
            let delayInSeconds = 0.01
            let when = DispatchTime.now() + delayInSeconds
            DispatchQueue.main.asyncAfter(deadline: when, execute: { 
                self.showSaveDialog()
            })
        })
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateTimeDisplay), userInfo: nil, repeats: true)
//        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateTimeDisplay() {
        timeLabel.text = controller.formattedCurrentTime
    }
    
    func showSaveDialog() {
        let alert = UIAlertController(title: "save recording", message: "please provide a name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "My Recording"
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel,handler: nil)
        let okAction = UIAlertAction(title: "ok", style: .default) { (action) in
            let fileName = alert.textFields?.first?.text ?? "test"
            
            self.controller.save(name: fileName, completion: { (success, object) in
                
                if success {
                    if object is THMemo {
                        let memo = object as! THMemo
                        self.memos.append(memo)
                        self.saveMemos()
                        self.tableView.reloadData()
                        print("file save complete")
                    }
                } else {
                    print("error saving file")
                }
            })
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    // MARK: Level Metering
    func startMeterTimer () {
        levelTimer?.invalidate()
        levelTimer = CADisplayLink(target: self, selector: #selector(updateMeter))
        levelTimer?.frameInterval = 5
        levelTimer?.add(to: .current, forMode: .commonModes)
    }
    
    func stopMeterTimer () {
        levelTimer?.invalidate()
        levelTimer = nil
        levelMeterView.resetLevelMeter()
    }
    
    func updateMeter () {
        let levels = controller.levels()
        levelMeterView.level = CGFloat(levels?.level ?? 0)
        levelMeterView.peakLevel = CGFloat(levels?.peakLevel ?? 0)
        levelMeterView.setNeedsDisplay()
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("memo :\(memos.count)")
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Memo_Cell, for: indexPath) as! THMemoCell
        let memo = memos[indexPath.row]
        cell.titleLabel.text = memo.title
        cell.dateLabel.text = memo.dateString
        cell.timeLabel.text = memo.timeString
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memo = memos[indexPath.row]
        controller.playbackMemo(memo: memo)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let memo = memos[indexPath.row]
            memo.deleteMemo()
            memos.remove(at: indexPath.row)
            saveMemos()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}


extension ViewController: THRecorderContollerDelegate {
    func interruptionBegan() {
        recordButton.isSelected = false
        stopMeterTimer()
        stopTimer()
    }
}
