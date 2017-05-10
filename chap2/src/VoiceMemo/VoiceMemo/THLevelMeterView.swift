//
//  THLevelMeterView.swift
//  VoiceMemo
//
//  Created by Joon on 03/05/2017.
//  Copyright © 2017 Joon. All rights reserved.
//

import UIKit

class THLevelMeterView: UIView {
    
    var level: CGFloat = 0.0
    var peakLevel: CGFloat = 0.0
    
    fileprivate var ledCount: Int = 20
    fileprivate var ledBackgroundColor: UIColor = UIColor.init(white: 0.0, alpha: 0.35)
    fileprivate var ledBorderColor: UIColor = UIColor.black
    fileprivate var colorThresholds: [THLevelMeterColorThreshold] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
//        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = UIColor.clear
        ledCount = 20
        ledBackgroundColor = UIColor.init(white: 0.0, alpha: 0.35)
        ledBorderColor = UIColor.black
        
        let greenColor = UIColor.init(colorLiteralRed: 0.458, green: 1.000, blue: 0.396, alpha: 1.0)
        let yellowColor = UIColor.init(colorLiteralRed: 1.000, green: 0.930, blue: 0.315, alpha: 1.0)
        let redColor = UIColor.init(colorLiteralRed: 1.000, green: 0.325, blue: 0.329, alpha: 1.0)
        
        colorThresholds = [
            THLevelMeterColorThreshold.init(maxValue: 0.5, color: greenColor, name: "green"),
            THLevelMeterColorThreshold.init(maxValue: 0.8, color: yellowColor, name: "yellow"),
            THLevelMeterColorThreshold.init(maxValue: 1.0, color: redColor, name: "red")
        ]
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.translateBy(x: 0, y: self.bounds.height)
        context.rotate(by: -CGFloat.pi/2)
        let bounds = CGRect(x: 0, y: 0, width: self.bounds.height, height: self.bounds.width)
        
        var lightMinValue = 0
        var peakLED = -1
        
        if peakLevel > 0.0 {
            peakLED = Int(peakLevel * CGFloat(ledCount))
            if peakLED >= ledCount {
                peakLED = ledCount - 1
            }
        }
        
        for ledIndex in 0..<ledCount {
            
            var ledColor = colorThresholds[0].color
            let ledMaxValue = ledIndex + 1 / ledCount
            
            
            for index in 0..<colorThresholds.count - 1 {
                let currThreshold = colorThresholds[index]
                let nextThreshold = colorThresholds[index + 1]
                if Int(currThreshold.maxValue) <= ledMaxValue {
                    ledColor = nextThreshold.color
                }
            }
            
            let ledRect = CGRect(x: 0, y: bounds.height * CGFloat(ledIndex / ledCount), width: bounds.width, height: bounds.height / CGFloat(ledCount))
            // Fill background color
            context.setFillColor(ledBackgroundColor.cgColor)
            context.fill(ledRect)
            
            // Draw light
            var lightIntensity: CGFloat = 0
            if ledIndex == peakLED {
                lightIntensity = 1
            } else {
                lightIntensity = clamp(intensity: (level - CGFloat(lightMinValue)) / CGFloat(ledMaxValue - lightMinValue))
            }
            
            var fillColor = UIColor.clear
            if lightIntensity == 1 {
                fillColor = ledColor
            } else if lightIntensity > 0 {
                let color = ledColor.cgColor.copy(alpha: lightIntensity)
                fillColor = UIColor(cgColor: color!)
            }
            
             context.setFillColor(fillColor.cgColor)
            let fillPath = UIBezierPath(roundedRect: ledRect, cornerRadius: 2.0)
            context.addPath(fillPath.cgPath)
            
            // stroke border
            
            context.setStrokeColor(ledBorderColor.cgColor)
            let strokePath = UIBezierPath(roundedRect: ledRect.insetBy(dx: 0.5, dy: 0.5) , cornerRadius: 2.0)
            context.addPath(strokePath.cgPath)
            context.drawPath(using: .fillStroke)
            lightMinValue = ledMaxValue
            
        }
    }
    
    func clamp(intensity: CGFloat) -> CGFloat {
        if intensity < 0 {
            return 0
        } else if intensity >= 1 {
            return 1
        } else {
            return intensity
        }
    }
    
    func resetLevelMeter() {
        level = 0.0
        peakLevel = 0.0
        setNeedsDisplay()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
