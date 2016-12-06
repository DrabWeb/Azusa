//
//  MISong.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/5/16.
//

import Foundation
import AppKit

/// An object to represent a song in Mio
class MISong : AZSong {
    /// The artist of this song
    var artist : String = "";
    
    /// The album of this song
    var album : String = "";
    
    /// The artist of the album this song is in(if any)
    var albumArtist : String = "";
    
    /// The title of this song
    var title : String = "";
    
    /// The track number of this song
    var track : Int = -1;
    
    /// The genre of this song
    var genre : String = "";
    
    /// The year this track was released
    var year : Int = -1;
    
    /// The artist who composed this song
    var composer : String = "";
    
    /// The artist who performed this song
    var performer : String = "";
    
    /// A human-readable comment about the song
    var comment : String = "";
    
    /// The disc number for this song if it's in a multi-disc album
    var disc : Int = -1;
    
    /// The total count of discs for the album this song is on(if it's in a multi-disc album)
    var discCount : Int = -1;
    
    /// The length of this song in seconds
    var length : Int = -1;
    
    /// This song's position in the queue(if it's in the queue)
    var position : Int = -1;
    
    /// Returns the display title for this song
    var displayTitle : String {
        return "";
    };
    
    /// Returns the display artist for this song
    var displayArtist : String {
        return "";
    };
    
    /// Returns the display album for this song
    var displayAlbum : String {
        return "";
    };
    
    /// Returns the album
    var coverImage : NSImage {
        return #imageLiteral(resourceName: "AZDefaultCover");
    };
    
    /// Returns an empty song(used for displaying that there is no song)
    static var empty : AZSong {
        return MISong();
    };
}
