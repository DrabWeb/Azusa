//
//  AZVolumeSlider.swift
//  Azusa
//
//  Created by Ushio on 1/8/17.
//

import Cocoa

/// Custom `NSSliderCell` for the volume slider in a music player toolbar
class AZVolumeSliderCell: NSSliderCell {
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        /// The color to use for the background of the slider
        var backgroundColor : NSColor = NSColor(white: CGFloat(171.0 / 256.0), alpha: 1);
        
        /// The color to use for the active part of the slider
        var activeColor : NSColor = NSColor(white: CGFloat(103.0 / 256.0), alpha: 1);
        
        // Update the colors if the dark theme is active
        if(self.controlView?.window?.appearance == NSAppearance(named: NSAppearanceNameVibrantDark)) {
            backgroundColor = NSColor(white: CGFloat(61.0 / 256.0), alpha: 1);
            activeColor = NSColor(white: CGFloat(136.0 / 256.0), alpha: 1);
        }
        
        /// The base rect for the slider
        var rect = aRect;
        
        // Modify the origin to center the slider
        rect.origin.y += 1;
        
        // Set the slider height
        rect.size.height = CGFloat(3);
        
        /// The radius for the corners of the bar
        let radius : CGFloat = 2.5;
        
        /// The value to use for determining how much to fill
        let value : CGFloat = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue));
        
        /// The final width for the filled slider section
        let finalWidth : CGFloat = CGFloat(value * (self.controlView!.frame.size.width - 8));
        
        /// The rect for the filled section of the bar
        var leftRect : NSRect = rect;
        
        // Set `leftRect`'s width
        leftRect.size.width = finalWidth;
        
        /// The bezier path for the background of the bar
        let backgroundPath : NSBezierPath = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius);
        
        // Set the fill color
        backgroundColor.setFill();
        
        // Fill in the background of the bar
        backgroundPath.fill();
        
        /// The path for the active part of the slider
        let activePath : NSBezierPath = NSBezierPath(roundedRect: leftRect, xRadius: radius, yRadius: radius);
        
        // Set the fill color
        activeColor.setFill();
        
        // Fill the active part of the bar
        activePath.fill();
    }
}
