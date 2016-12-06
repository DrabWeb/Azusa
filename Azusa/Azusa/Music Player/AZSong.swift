//
//  AZSong.swift
//  Azusa
//
//  Created by Ushio on 12/5/16.
//

import Foundation
import AppKit

/// The protocol for a song used by Azusa
protocol AZSong {
    /// The artist of this song
    var artist : String { get set };
    
    /// The album of this song
    var album : String { get set };
    
    /// The artist of the album this song is in(if any)
    var albumArtist : String { get set };
    
    /// The title of this song
    var title : String { get set };
    
    /// The track number of this song
    var track : Int { get set };
    
    /// The genre of this song
    var genre : String { get set };
    
    /// The year this track was released
    var year : Int { get set };
    
    /// The artist who composed this song
    var composer : String { get set };
    
    /// The artist who performed this song
    var performer : String { get set };
    
    /// A human-readable comment about the song
    var comment : String { get set };
    
    /// The disc number for this song if it's in a multi-disc album
    var disc : Int { get set };
    
    /// The total count of discs for the album this song is on(if it's in a multi-disc album)
    var discCount : Int { get set };
    
    /// The length of this song in seconds
    var length : Int { get set };
    
    /// This song's position in the queue(if it's in the queue)
    var position : Int { get set };
    
    /// Returns the display title for this song
    var displayTitle : String { get };
    
    /// Returns the display artist for this song
    var displayArtist : String { get };
    
    /// Returns the display album for this song
    var displayAlbum : String { get };
    
    /// Returns the album
    var coverImage : NSImage { get };
    
    /// Returns an empty song(used for displaying that there is no song)
    static var empty : AZSong { get };
}
