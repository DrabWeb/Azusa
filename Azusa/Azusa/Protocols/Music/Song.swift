//
//  Song.swift
//  Azusa
//
//  Created by Ushio on 2/11/17.
//

import Cocoa

/// The protocol for a song used by azusa
protocol Song: CustomStringConvertible {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    /// The artist of this song
    var artist : Artist { get set };
    
    /// The album this song is in(if any)
    var album : Album { get set };
    
    /// The artist of the album this song is in(if any)
    var albumArtist : Artist { get set };
    
    /// The title of this song
    var title : String { get set };
    
    /// The track number of this song
    var track : Int { get set };
    
    /// The genre of this song
    var genre : Genre { get set };
    
    /// The year this track was released
    var year : Int { get set };
    
    /// The artist who composed this song
    var composer : String { get set };
    
    /// The artist who performed this song
    var performer : String { get set };
    
    /// The disc number for this song if it's in a multi-disc album
    var disc : Int { get set };
    
    /// The total count of discs for the album this song is on(if it's in a multi-disc album)
    var discCount : Int { get set };
    
    /// The duration of this song in seconds
    var duration : Int { get set };
    
    /// This song's position in the queue(if it's in the queue)
    var position : Int { get set };
    
    /// Returns the display title for this song
    var displayTitle : String { get };
    
    /// Returns the display artist for this song
    var displayArtist : String { get };
    
    /// Returns the display album for this song
    var displayAlbum : String { get };
    
    // TODO: Probably make this do a completion handler again for web based sources
    // But also maybe not because ArtworkCache should be doing the async stuff here
    /// The full artwork of this song(should only be used by `ArtworkCache` so it can build it's cache)
    // TODO: Make a new default cover
    var artwork : NSImage? { get };
    
    /// Returns an empty song(used for displaying that there is no song)
    static var empty : Song { get };
    
    /// Returns if this song is `empty`
    ///
    /// - Returns: If this song is equal to `empty`
    var isEmpty : Bool { get };
}

// MARK: - Methods

func ==(lhs: Song, rhs: Song) -> Bool {
    return (lhs.title == rhs.title) && (lhs.album.name == rhs.album.name) && (lhs.artist.name == rhs.artist.name);
}

func !=(lhs: Song, rhs: Song) -> Bool {
    return !(lhs == rhs);
}
