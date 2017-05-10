//
//  THLevelMeterColorThreshold.swift
//  VoiceMemo
//
//  Created by Joon on 03/05/2017.
//  Copyright © 2017 Joon. All rights reserved.
//

import UIKit

class THLevelMeterColorThreshold {
    
    var maxValue: CGFloat
    var color: UIColor
    var name: String
    
    init(maxValue: CGFloat, color: UIColor, name: String) {
        self.maxValue = maxValue
        self.color = color
        self.name = name
    }
    
    var description: String {
        return name
    }
}
