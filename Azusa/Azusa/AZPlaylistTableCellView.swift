//
//  AZPlaylistTableCellView.swift
//  Azusa
//
//  Created by Ushio on 11/27/16.
//

import Cocoa

class AZPlaylistTableCellView: NSTableCellView {
    
    /// The label for the position of this song in the playlist
    @IBOutlet weak var songPositionLabel: NSTextField!
    
    /// The label for the title of this song
    @IBOutlet weak var songTitleLabel: NSTextField!
    
    /// The label for the artist of this song
    @IBOutlet weak var songArtistLabel: NSTextField!
    
    /// The label for the length of this song
    @IBOutlet weak var songLengthLabel: NSTextField!
    
    /// The song this cell represents
    var representedSong : MISong? = nil;
    
    /// The handler for when this cell is double clicked or enter is hit whole it's selected, passed the song from the cell that was clicked
    var primaryActionHandler : ((MISong) -> ())? = nil;
    
    /// The handler for when this cell is right clicked, passed the song and event from the cell that was clicked
    var rightClickHandler : ((MISong, NSEvent) -> ())? = nil;
    
    /// The playlist view controller for the view this cell is in(optional)
    var playlistViewController : AZPlaylistViewController? = nil;
    
    override func mouseDown(with event: NSEvent) {
        if(event.clickCount >= 2) {
            // Perform the primary action handler
            self.performPrimaryActionHandler(keepScrollPosition: true);
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        // Call the right click handler
        self.rightClickHandler?(self.representedSong!, event);
    }
    
    /// Performs primaryActionHandler, if keepScrollPosition is true it will restore the playlist's scroll position after the primary action handler is called
    func performPrimaryActionHandler(keepScrollPosition : Bool) {
        if(self.representedSong != nil) {
            if(keepScrollPosition) {
                // Tell the playlist view controller to store the playlist's scroll position(if it isn't nil)
                self.playlistViewController?.restoreScrollOnPlaylistDisplay = true;
            }
            
            // Call the primary action handler
            self.primaryActionHandler?(self.representedSong!);
        }
    }
    
    /// Displays the data from a given MISong in this cell
    func display(song : MISong) {
        // Set representedSong
        self.representedSong = song;
        
        // Update the labels
        songPositionLabel.stringValue = "\(song.relativePosition)";
        songTitleLabel.stringValue = song.displayTitle;
        songArtistLabel.stringValue = "by \(song.displayArtist)";
        songLengthLabel.stringValue = MIUtilities.secondsToDisplayTime(song.length);
        
        // Update the alpha value based on if the song is behind the current song
        self.alphaValue = (song.relativePosition >= 0) ? 1 : 0.5;
    }
}
