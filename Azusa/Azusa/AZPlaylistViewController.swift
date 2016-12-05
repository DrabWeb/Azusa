//
//  AZPlaylistViewController.swift
//  Azusa
//
//  Created by Ushio on 11/27/16.
//

import Cocoa

class AZPlaylistViewController: NSViewController {

    /// The label to show how many songs are in the current playlist
    @IBOutlet weak var playlistSongCountLabel: NSTextField!
    
    /// The current playlist items being displayed in this playlist view
    var currentPlaylistItems : [MISong] {
        return _currentPlaylistItems;
    }
    
    /// The actual current playlist items
    private var _currentPlaylistItems : [MISong] = [];
    
    /// The current song position relative to _currentPlaylistItems
    var currentSongPosition : Int = -1;
    
    /// The table view for displaying playlist items
    @IBOutlet weak var playlistTableView: AZPlaylistTableView!
    
    /// The scroll view for playlistTableView
    @IBOutlet weak var playlistTableViewScrollView: NSScrollView!
    
    /// The last set cell primary action handler from displayPlaylist
    var lastSetPrimaryActionHandler : ((MISong) -> ())? = nil;
    
    /// The last set cell right click handler from displayPlaylist
    var lastSetRightClickHandler : ((MISong, NSEvent) -> ())? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func keyDown(with event: NSEvent) {
        // If the user hit enter...
        if(event.keyCode == 36 || event.keyCode == 76) {
            /// The currently selected row in the playlist table view, default to the selected row, and if there is none -1
            let row : Int = (playlistTableView.selectedRow >= 0) ? playlistTableView.selectedRow : -1;
            
            // If there was a selected row...
            if(row != -1) {
                /// The AZPlaylistTableCellView at the selected row
                let cellView : AZPlaylistTableCellView = (playlistTableView.rowView(atRow: row, makeIfNecessary: false)!.subviews[0] as! AZPlaylistTableCellView);
                
                // Perform the cell's primary action handler
                cellView.performPrimaryActionHandler(keepScrollPosition: true);
            }
        }
        // If the user hit another key...
        else {
            // Let the superclass handle key down
            super.keyDown(with: event);
        }
    }
    
    /// Should the next call of displayPlaylist maintain it's scroll position?
    var restoreScrollOnPlaylistDisplay : Bool = false;
    
    /// Displays the given array of MISongs, with the given double click and right click handlers, and the passed current song position is used for modifying the style based on current song position
    func displayPlaylist(playlist : [MISong], currentSongPosition : Int = 0, primaryActionHandler : ((MISong) -> ())? = nil, rightClickHandler : ((MISong, NSEvent) -> ())? = nil) {
        AZLogger.log("AZPlaylistViewController: Displaying playlist with songs \(playlist)(current song is #\(currentSongPosition))");
        
        // Store the current scroll point if we said to restore it
        if(restoreScrollOnPlaylistDisplay) {
            storePlaylistScrollPosition();
        }
        
        // Set the current playlist items
        self._currentPlaylistItems = playlist;
        
        // Set the current song position
        self.currentSongPosition = currentSongPosition;
        
        // Set lastSetPrimaryActionHandler and lastSetRightClickHandler
        self.lastSetPrimaryActionHandler = primaryActionHandler;
        self.lastSetRightClickHandler = rightClickHandler;
        
        // Update the song count label
        playlistSongCountLabel.stringValue = "#\(currentSongPosition + ((playlist.isEmpty) ? 0 : 1))/\(playlist.count)";
        
        // Reload the playlist table view
        playlistTableView.reloadData();
        
        // Restore the current scroll point if we said to restore it, and if not scroll to the current song
        if(restoreScrollOnPlaylistDisplay) {
            restorePlaylistScrollPosition();
            
            // Set restoreScrollOnPlaylistDisplay to false since we have now restored the scroll position
            restoreScrollOnPlaylistDisplay = false;
        }
        else {
            /// The amount of rows to pad the scroll row to visible call
            let scrollToPadding : Int = 4;
            
            // Scroll to the current song with the set padding
            self.playlistTableView.scrollRowToVisible(((currentSongPosition + scrollToPadding) >= (playlist.count - 1)) ? (playlist.count - 1) : (currentSongPosition + scrollToPadding));
        }
        
        // Select the current song and make the table view the first responder
        self.playlistTableView.selectRowIndexes(NSIndexSet(index: currentSongPosition) as IndexSet, byExtendingSelection: false);
        self.view.window?.makeFirstResponder(self.playlistTableView);
    }
    
    /// The last stored scroll point from storePlaylistScrollPosition
    private var storedPlaylistScrollPoint : NSPoint = NSPoint.zero;
    
    /// Stores the current scroll position of playlistTableViewScrollView in storedPlaylistScrollPoint
    func storePlaylistScrollPosition() {
        // Store the scroll point for the playlist
        self.storedPlaylistScrollPoint = self.playlistTableViewScrollView.contentView.bounds.origin;
    }
    
    /// Scrolls playlistTableViewScrollView to storedPlaylistScrollPoint
    func restorePlaylistScrollPosition() {
        // Restore the scroll position
        self.playlistTableViewScrollView.contentView.scroll(to: storedPlaylistScrollPoint);
    }
}

extension AZPlaylistViewController: NSTableViewDataSource {
        
    func numberOfRows(in tableView: NSTableView) -> Int {
        // Return the amount of items in the current playlist items
        return self.currentPlaylistItems.count;
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.currentPlaylistItems[row];
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view for the cell we want to modify
        let cellView: NSTableCellView = tableView.make(withIdentifier: tableColumn!.identifier, owner: nil) as! NSTableCellView;
        
        // If this is the main column...
        if(tableColumn!.identifier == "Main Column") {
            /// cellView as a AZPlaylistTableCellView
            let playlistItemCellView : AZPlaylistTableCellView = cellView as! AZPlaylistTableCellView;
            
            /// The data for this cell
            let cellData : MISong = currentPlaylistItems[row];
            
            // Update the song's relative position
            cellData.relativePosition =  cellData.position - self.currentSongPosition;
            
            // Set the cell's right and primary action handlers
            playlistItemCellView.rightClickHandler = self.lastSetRightClickHandler;
            playlistItemCellView.primaryActionHandler = self.lastSetPrimaryActionHandler;
            
            // Set the cell's playlist view controller
            playlistItemCellView.playlistViewController = self;
            
            // Display the cell data in the cell
            playlistItemCellView.display(song: cellData);
            
            // Return the modified cell view
            return cellView;
        }
        
        // Return the unmodified cell view, we dont need to do anything
        return cellView;
    }
}

extension AZPlaylistViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AZPlaylistTableRowView();
    }
}
