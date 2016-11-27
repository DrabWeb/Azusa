//
//  AZPlaylistTableRowView.swift
//  Azusa
//
//  Created by Ushio on 11/27/16.
//

import Cocoa

class AZPlaylistTableRowView: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        // If selection highlighting is enabled on this row's table view...
        if(self.selectionHighlightStyle != .none) {
            // Set the selection color
            NSColor(calibratedWhite: 0.11, alpha: 1).setFill();
            
            // Fill in this row with the selection color
            NSBezierPath(rect: self.bounds).fill();
        }
    }
}
