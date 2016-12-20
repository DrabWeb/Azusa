//
//  AZSong.swift
//  Azusa
//
//  Created by Ushio on 12/5/16.
//

import Foundation
import AppKit

/// The protocol for a song used by Azusa
protocol AZSong: CustomStringConvertible {
    
    // MARK: - Properties
    
    /// The artist of this song
    var artist : AZArtist { get set };
    
    /// The album this song is in(if any)
    var album : AZAlbum { get set };
    
    /// The artist of the album this song is in(if any)
    var albumArtist : String { get set };
    
    /// The title of this song
    var title : String { get set };
    
    /// The track number of this song
    var track : Int { get set };
    
    /// The genre of this song
    var genre : AZGenre { get set };
    
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
    
    /// Gets the cover image for this song async, and calls the completion handler with it
    ///
    /// - Parameter completionHandler: The completion handler to call when the cover is loaded, passed the `NSImage` of the cover
    func getCoverImage(_ completionHandler : @escaping ((NSImage) -> ()));
    
    /// Returns an empty song(used for displaying that there is no song)
    static var empty : AZSong { get };
    
    /// Returns if this song is `empty`
    ///
    /// - Returns: If this song is equal to `empty`
    func isEmpty() -> Bool;
}

func ==(lhs: AZSong, rhs: AZSong) -> Bool {
    return (lhs.title == rhs.title) && (lhs.album.name == rhs.album.name) && (lhs.artist.name == rhs.artist.name);
}

func !=(lhs: AZSong, rhs: AZSong) -> Bool {
    return !(lhs == rhs);
}
