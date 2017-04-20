//
//  ViewController.swift
//  Chap1_HelloAVF
//
//  Created by Joon on 20/04/2017.
//  Copyright © 2017 Joon. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var speechController = THSpeechController()
    var speechStrings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 20, 0)
        speechController.synthesizer.delegate = self
        speechController.beginConversation()
    }
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return speechStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.row % 2 == 0 ? "YouCell" : "AVFCell"

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! THBubbleCell
        cell.messageLabel.text = speechStrings[indexPath.row]
        
        return cell
    }
}

extension ViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        speechStrings.append(utterance.speechString)
        tableView.reloadData()
        let indexPath = IndexPath(row: speechStrings.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

