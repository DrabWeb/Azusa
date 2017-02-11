//
//  RoundDarkEdgedImageView.swift
//  Azusa
//
//  Created by Ushio on 2/11/17.
//

import Cocoa

class RoundDarkEdgedImageView: NSImageView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect);
        
        self.layer?.cornerRadius = 5;
        self.layer?.masksToBounds = true;
        self.layer?.backgroundColor = NSColor.white.cgColor;
        
        let strokePath : NSBezierPath = NSBezierPath(roundedRect: self.bounds, xRadius: 5, yRadius: 5);
        NSColor(white: 0, alpha: 0.25).setStroke();
        strokePath.stroke();
    }
}
