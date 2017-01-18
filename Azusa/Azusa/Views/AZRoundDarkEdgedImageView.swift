//
//  AZRoundDarkEdgedImageView.swift
//  Azusa
//
//  Created by Ushio on 1/10/17.
//

import Cocoa

class AZRoundDarkEdgedImageView: NSImageView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect);
        
        // Make the corners round
        self.layer?.cornerRadius = 5;
        self.layer?.masksToBounds = true;
        
        // Set the background color
        self.layer?.backgroundColor = NSColor.white.cgColor;
        
        /// The path for the dark edge stroke
        let strokePath : NSBezierPath = NSBezierPath(roundedRect: self.bounds, xRadius: 5, yRadius: 5);
        
        // Draw the stroke
        NSColor(white: 0, alpha: 0.25).setStroke();
        strokePath.stroke();
    }
}
