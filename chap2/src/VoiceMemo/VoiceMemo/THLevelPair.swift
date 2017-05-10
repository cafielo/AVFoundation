//
//  THLevelPair.swift
//  VoiceMemo
//
//  Created by Joon on 03/05/2017.
//  Copyright © 2017 Joon. All rights reserved.
//

import UIKit

class THLevelPair: NSObject {
    var level: Float
    var peakLevel: Float
    
    init(level:Float, peakLevel:Float) {
        self.level = level
        self.peakLevel = peakLevel
        super.init()
    }
}
