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
    
    /// Displays the data from a given MISong in this cell
    func display(song : MISong) {
        // Set representedSong
        self.representedSong = song;
        
        // Update the labels
        songPositionLabel.stringValue = "\(song.position)";
        songTitleLabel.stringValue = song.displayTitle;
        songArtistLabel.stringValue = "by \(song.displayArtist)";
        songLengthLabel.stringValue = MIUtilities.secondsToDisplayTime(song.length);
    }
}
