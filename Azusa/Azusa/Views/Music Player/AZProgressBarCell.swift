//
//  AZProgressBarCell.swift
//  Azusa
//
//  Created by Ushio on 12/11/16.
//

import Foundation
import AppKit

/// The custom `NSSliderCell` for music progress bars
class AZProgressBarCell: NSSliderCell {
    
    // MARK: - Properties
    
    /// The color for the background of the slider
    @IBInspectable var backgroundColor : NSColor = NSColor.gray;
    
    /// The color for the progressed part of the slider
    @IBInspectable var progressColor : NSColor = NSColor.blue;
    
    /// The color of the knob
    @IBInspectable var knobColor : NSColor = NSColor.black;
    
    
    // MARK: - Functions
    
    override func drawKnob(_ knobRect: NSRect) {
        /// The rect for the knob
        let rect : NSRect = NSRect(x: round(knobRect.origin.x), y: knobRect.origin.y, width: knobRect.width, height: 8);
        
        /// The path to draw the knob with
        let path : NSBezierPath = NSBezierPath(rect: rect);
        
        // Draw the knob
        knobColor.setFill();
        path.fill();
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        /// The slider for this cell
        let slider : NSSlider = self.controlView as! NSSlider;
        
        /// The bounds of this slider
        let bounds : NSRect = super.barRect(flipped: flipped);
        
        // How much of the progress bar is filled
        let percentage : Double = slider.doubleValue / (slider.maxValue - slider.minValue);
        
        /// The position of the knob
        let position : CGFloat = CGFloat(percentage) * bounds.width;
        
        /// The rect for the knob
        let rect : NSRect = super.knobRect(flipped: flipped);
        
        // Return the knob rect
        return NSMakeRect(position + 2, rect.origin.y + 5, 2, 8);
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        /// The bar rect from NSSlider
        let rect : NSRect = super.barRect(flipped: flipped);
        
        /// Return the bar rect
        return NSRect(x: 0, y: rect.origin.y, width: rect.width + rect.origin.x * 2, height: rect.height);
    }
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        /// The current position of the knob
        let knobPosition : CGFloat = round(knobRect(flipped: flipped).origin.x);
        
        /// The rect for the slider body
        let rect : NSRect = NSRect(x: rect.origin.x + 2, y: rect.origin.y + 1, width: rect.width - 2, height: rect.height);
        
        /// The path for the slider body
        let path = NSBezierPath(rect: rect);
        
        // Draw the progressed section
        NSGraphicsContext.saveGraphicsState();
        
        // Add the clip for the progressed section
        NSBezierPath(rect: NSRect(x: rect.origin.x, y: rect.origin.y, width: knobPosition, height: rect.height)).addClip();
        
        // Draw the progressed section
        progressColor.setFill();
        path.fill();
        NSGraphicsContext.restoreGraphicsState();
        
        // Draw the background
        NSGraphicsContext.saveGraphicsState();
        
        /// Add the clip for the background
        NSBezierPath(rect: NSRect(x: rect.origin.x + knobPosition, y: rect.origin.y, width: rect.width - knobPosition, height: rect.height)).setClip();
        
        // Draw the background
        backgroundColor.setFill()
        path.fill()
        NSGraphicsContext.restoreGraphicsState()
    }
}
