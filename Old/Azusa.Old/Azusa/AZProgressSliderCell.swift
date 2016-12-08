//
//  AZProgressSliderCell.swift
//  Azusa
//
//  Created by Ushio on 11/23/16.
//

import Cocoa

class AZProgressSliderCell: NSSliderCell {
    
    /// The color for the background of the slider
    @IBInspectable var backgroundColor : NSColor = NSColor.gray;
    
    /// The color for the progressed part of the slider
    @IBInspectable var progressColor : NSColor = NSColor.blue;
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        /// The rect for the slider bar
        var rect = NSRect(x: aRect.origin.x, y: aRect.origin.y + 1, width: aRect.width, height: aRect.height);
        
        // Set the height of the slider bar
        rect.size.height = CGFloat(3);
        
        /// The corner radius of the sliderbar
        let barCornerRadius = CGFloat(1.5);
        
        /// The current value of the slider
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue));
        
        /// The width for the progressed part of the slider
        let finalWidth = CGFloat(value * (self.controlView!.frame.size.width - 5.5));
        
        // Setup the progressed part's rect
        var leftRect = rect;
        leftRect.size.width = finalWidth;
        leftRect.origin = CGPoint(x: leftRect.origin.x - 1, y: leftRect.origin.y);
        
        /// The bezier path for the background of the slider
        let background = NSBezierPath(roundedRect: rect, xRadius: barCornerRadius, yRadius: barCornerRadius);
        
        // Set the background color to the set background color
        self.backgroundColor.setFill();
        background.fill();
        
        /// The bezier path for the progressed part of the slider
        let progressed = NSBezierPath(roundedRect: leftRect, xRadius: barCornerRadius, yRadius: barCornerRadius)
        
        // Set the background color to the set progress color
        self.progressColor.setFill()
        progressed.fill();
    }
    
    override func drawKnob() {
        // Disable the knob
    }
}
