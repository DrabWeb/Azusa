//
//  AZColoredView.swift
//  Azusa
//
//  Created by Ushio on 11/23/16.
//

import Cocoa

class AZColoredView: NSView {

    /// The color for the background of this view
    @IBInspectable var backgroundColor : NSColor = NSColor.black;
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        // Set the background color
        self.layer?.backgroundColor = backgroundColor.cgColor;
    }
}
