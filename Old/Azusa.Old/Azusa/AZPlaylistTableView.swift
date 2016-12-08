//
//  AZPlaylistTableView.swift
//  Azusa
//
//  Created by Ushio on 11/28/16.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class AZPlaylistTableView: NSTableView {
    override func rightMouseDown(with event: NSEvent) {
        /// The index of the row that was clicked
        let row : Int = self.row(at: self.convert(event.locationInWindow, from: nil));
        
        // Select the row the mouse is over
        self.selectRowIndexes(NSIndexSet(index: row) as IndexSet, byExtendingSelection: false);
        
        // If the playlist has any items selected...
        if(self.selectedRow != -1) {
            // Pass on the right click event
            ((self.rowView(atRow: row, makeIfNecessary: false)!.subviews[0]) as! AZPlaylistTableCellView).rightMouseDown(with: event);
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event);
        
        /// The index of the row that was clicked
        let row : Int = self.row(at: self.convert(event.locationInWindow, from: nil));
        
        if(row != -1) {
            // Pass on the mouse down event
            (self.rowView(atRow: row, makeIfNecessary: false)!.subviews[0] as! AZPlaylistTableCellView).mouseDown(with: event);
        }
    }
}
