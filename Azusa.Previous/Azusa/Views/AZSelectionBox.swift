//
//  AZSelectionBox.swift
//  Azusa
//
//  Created by Ushio on 1/27/17.
//

import Cocoa

class AZSelectionBox: NSView {
    
    override func awakeFromNib() {
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay;
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect);
        
        wantsLayer = true;
        layer?.backgroundColor = NSColor.selectedMenuItemColor.cgColor;
        layer?.cornerRadius = 5;
    }
}
