//
//  ThMeterTable.swift
//  VoiceMemo
//
//  Created by Joon on 02/05/2017.
//  Copyright © 2017 Joon. All rights reserved.
//

import UIKit
import Foundation

let Min_DB = -60.0
let Table_Size = 300.0

class ThMeterTable {
    
    private var scaleFactor: Float = 0.0
    private var meterTable = [Float]()
    
    init() {
        let dbResolution = Min_DB / (Table_Size - 1)
        
//        meterTable = Array<Float>(repeatElement(0.0, count: Int(Table_Size)))
        scaleFactor = Float(1.0 / dbResolution)
        let minAmp = dbToAmp(dB: Float(Min_DB))
        let ampRange = 1.0 - minAmp
        let invAmpRange = 1.0 / ampRange
        
        for i in 0..<Int(Table_Size) {
            let decibels = Float(Double(i) * dbResolution)
            let amp = dbToAmp(dB: decibels)
            let adjAmp = (amp - minAmp) * invAmpRange
            print(" --- table \(adjAmp)")
            meterTable.append(adjAmp)
        }
        
    }
    
    func dbToAmp(dB: Float) -> Float {
        return pow(10.0, 0.05 * dB)
    }
    
    func valueForPower(power: Float) -> Float {
        if power < Float(Min_DB) {
            return 0.0
        } else if power >= 0.0 {
            return 1.0
        } else {
            let index = Int(power * scaleFactor)
            return meterTable[index]
        }
    }
}
