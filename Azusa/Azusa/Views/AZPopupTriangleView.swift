//
//  AZPopupTriangleView.swift
//  Azusa
//
//  Created by Ushio on 1/16/17.
//

import Cocoa

/// A view for replicating the arrow of a `NSPopup`
class AZPopupTriangleView: NSView {
    
    /// The color for the background of this popup triangle
    @IBInspectable var backgroundColor : NSColor = NSColor(white: 0.9, alpha: 1);
    
    /// The color for the stroke of this popup triangle
    @IBInspectable var strokeColor : NSColor = NSColor(white: 0.8, alpha: 1);

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect);
        
        // Draw the triangle with background color and stroke
        let backgroundPath : NSBezierPath = NSBezierPath();
        
        backgroundPath.move(to: NSPoint(x: 0, y: 0));
        backgroundPath.line(to: NSPoint(x: 12, y: 13));
        backgroundPath.line(to: NSPoint(x: 13, y: 13));
        backgroundPath.line(to: NSPoint(x: 25, y: 0));
        backgroundPath.close();
        
        backgroundColor.setFill();
        backgroundPath.fill();
        
        strokeColor.setStroke();
        backgroundPath.stroke();
        
        // Draw the line that will break off the bottom of the triangle
        let bottomLine : NSBezierPath = NSBezierPath();
        
        bottomLine.move(to: NSPoint(x: 2, y: 0));
        bottomLine.line(to: NSPoint(x: 23, y: 0));
        self.strokeColor.set();
        bottomLine.lineWidth = 2;
        backgroundColor.setStroke();
        bottomLine.stroke();
    }
}
