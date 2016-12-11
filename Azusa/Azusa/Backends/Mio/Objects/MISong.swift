//
//  MISong.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/8/16.
//

import Foundation
import AppKit

class MISong: AZSong {
    // MARK: - Properties
    
    /// The MPD URI of this song
    var uri : String = "";
    
    /// The MPD ID of this song
    var id : Int = 0;
    
    var artist : AZArtist = AZArtist();
    
    var album : AZAlbum = AZAlbum();
    
    var albumArtist : String = "";
    
    var title : String = "";
    
    var track : Int = 0;
    
    var genre : AZGenre = AZGenre();
    
    var year : Int = 0;
    
    var composer : String = "";
    
    var performer : String = "";
    
    var disc : Int = 0;
    
    var discCount : Int = 0;
    
    var duration : Int = 0;
    
    var position : Int = 0;
    
    var description: String {
        return "MISong<\(self.id) - \(self.uri)>: \(self.displayTitle) by \(self.displayArtist)(\(AZMusicUtilities.secondsToDisplayTime(self.duration))), in \(self.displayAlbum)";
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
        return self.artist.displayName;
    }
    
    /// Returns the display album for this song
    var displayAlbum : String {
        return self.album.displayName;
    }
    
    var coverImage : NSImage {
        return #imageLiteral(resourceName: "AZDefaultCover");
    };
    
    static var empty : AZSong {
        let song : MISong = MISong();
        
        song.artist = AZArtist();
        song.title = "Song Not Found";
        
        return song;
    };
}
