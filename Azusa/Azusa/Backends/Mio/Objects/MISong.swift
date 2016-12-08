//
//  MISong.swift
//  Azusa
//
//  Created by Ushio on 12/8/16.
//

import Foundation
import AppKit

class MISong : AZSong {
    // MARK: - Properties
    
    /// The MPD URI of this song
    var uri : String = "";
    
    /// The MPD ID of this song
    var id : Int = 0;
    
    var artist : String = "";
    
    var album : String = "";
    
    var albumArtist : String = "";
    
    var title : String = "";
    
    var track : Int = 0;
    
    var genre : String = "";
    
    var year : Int = 0;
    
    var composer : String = "";
    
    var performer : String = "";
    
    var disc : Int = 0;
    
    var discCount : Int = 0;
    
    var duration : Int = 0;
    
    var position : Int = 0;
    
    /// The debug description for this song
    var debugDescription : String {
        return "\(self): \(self.displayTitle) by \(self.displayArtist)(\(AZMusicUtilities.secondsToDisplayTime(self.duration))), in \(self.displayAlbum)";
    }
    
    var displayTitle : String {
        // If the title is set...
        if(self.title != "") {
            // Return the title
            return title;
        }
        // If the title isn't set...
        else {
            // If the URI is set...
            if(self.uri != "") {
                // Return the filename without extension and path
                return NSString(string: NSString(string: self.uri).lastPathComponent).deletingPathExtension;
            }
            // If the URI isn't set...
            else {
                // Return a string saying we don't know the song title
                return "Unknown Title";
            }
        }
    }
    
    var displayArtist : String {
        // If artist is set...
        if(artist != "") {
            // Return artist
            return artist;
        }
        // If artist isn't set...
        else {
            // Return a string saying we don't know the artist
            return "Unknown Artist";
        }
    }
    
    /// Returns the display album for this song
    var displayAlbum : String {
        // If the album is set...
        if(album != "") {
            // Return album
            return album;
        }
        // If the album isn't set...
        else {
            // Return a string saying we don't know the album
            return "Unknown Album";
        }
    }
    
    var coverImage : NSImage {
        return #imageLiteral(resourceName: "AZDefaultCover");
    };
    
    static var empty : AZSong {
        let song : MISong = MISong();
        
        song.artist = "Unknown Artist";
        song.title = "Song Not Found";
        
        return song;
    };
}
