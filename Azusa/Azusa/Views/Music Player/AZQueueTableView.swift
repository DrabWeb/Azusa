//
//  AZQueueTableView.swift
//  Azusa
//
//  Created by Ushio on 12/12/16.
//

import Cocoa

/// The `NSTableView` subclass for queue views
class AZQueueTableView: NSTableView {
    
    // MARK: - Variables
    
    /// The closure to call when the user either double clicks or presses enter on this table view, normally plays the clicked track
    ///
    /// Passed this table view, the selected cells and the event
    var primaryHandler : ((AZQueueTableView, [AZQueueTableCellView], NSEvent) -> ())? = nil;
    
    /// The closure to call when the user either right clicks on this table view, normally shows a context menu
    ///
    /// Passed this table view, the selected cells and the event
    var secondaryHandler : ((AZQueueTableView, [AZQueueTableCellView], NSEvent) -> ())? = nil;
    
    /// The closure to call when the user selects songs and presses backspace/delete, should remove the selected songs from the queue
    ///
    /// Passed this table view, the selected cells and the event
    var removeHandler : ((AZQueueTableView, [AZQueueTableCellView], NSEvent) -> ())? = nil;
    
    
    // MARK: - Functions

    override func rightMouseDown(with event: NSEvent) {
        // Call `secondaryHandler`
        self.secondaryHandler?(self, self.getSelectedCells(), event);
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event);
        
        /// The index of the row that was clicked
        let row : Int = self.row(at: self.convert(event.locationInWindow, from: nil));
        
        // If the user double clicked...
        if(event.clickCount >= 2) {
            // If `row` is valid...
            if(row != -1) {
                // Only select the clicked row
                self.selectRowIndexes(IndexSet([row]), byExtendingSelection: false);
            }
            
            // Call `primaryHandler`
            self.primaryHandler?(self, self.getSelectedCells(), event);
        }
    }
    
    override func keyDown(with event: NSEvent) {
        // Switch on the keycode and act accordingly
        switch(event.keyCode) {
            // Enter
            case 36, 76:
                // Make sure if there are multiple selection to only select the first one
                self.selectRowIndexes(IndexSet([self.selectedRowIndexes.first ?? -1]), byExtendingSelection: false);
                
                self.primaryHandler?(self, self.getSelectedCells(), event);
                break;
            
            // Backspace/delete
            case 51, 117:
                self.removeHandler?(self, self.getSelectedCells(), event);
                break;
            
            default:
                super.keyDown(with: event);
                break;
        }
    }
    
    /// Gets all the selected `AZQueueTableCellView`s in this table view and returns them
    ///
    /// - Returns: All the `AZQueueTableCellView`s selected in this table view
    func getSelectedCells() -> [AZQueueTableCellView] {
        /// The cells to return
        var cells : [AZQueueTableCellView] = [];
        
        // For every selected row index...
        for(_, currentRowIndex) in self.selectedRowIndexes.enumerated() {
            // Add the `AZQueueTableCellView` of this row to `cells`
            cells.append((self.rowView(atRow: currentRowIndex, makeIfNecessary: false)!.view(atColumn: 0) as! AZQueueTableCellView));
        }
        
        // Return `cells`
        return cells;
    }
}
