//
//  ProgressSliderCell.swift
//  Azusa
//
//  Created by Ushio on 2/11/17.
//

import Cocoa

class ProgressSliderCell: NSSliderCell {

    override func drawKnob(_ knobRect: NSRect) {
        // No knob
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        let slider : NSSlider = self.controlView as! NSSlider;
        let bounds : NSRect = super.barRect(flipped: flipped);
        let percentage : Double = slider.doubleValue / (slider.maxValue - slider.minValue);
        let position : CGFloat = CGFloat(percentage) * bounds.width;
        let rect : NSRect = super.knobRect(flipped: flipped);
        
        return NSRect(x: position + 2, y: rect.origin.y + 5, width: 2, height: 8);
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        let rect : NSRect = super.barRect(flipped: flipped);
        return NSRect(x: 0, y: rect.origin.y, width: rect.width + rect.origin.x * 2, height: rect.height);
    }
}
