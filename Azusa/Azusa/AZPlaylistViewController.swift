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
    
    /// The table view for displaying playlist items
    @IBOutlet weak var playlistTableView: NSTableView!
    
    /// The scroll view for playlistTableView
    @IBOutlet weak var playlistTableViewScrollView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    /// Displays the given array of MISongs
    func displayPlaylist(playlist : [MISong]) {
        MILogger.log("AZPlaylistViewController: Displaying playlist with songs \(playlist)");
        
        // Set the current playlist items
        self._currentPlaylistItems = playlist;
        
        // Update the song count label
        playlistSongCountLabel.stringValue = "\(playlist.count) songs";
        
        // Reload the playlist table view
        playlistTableView.reloadData();
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
