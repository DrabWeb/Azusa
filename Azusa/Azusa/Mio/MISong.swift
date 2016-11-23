//
//  MISong.swift
//  Azusa
//
//  Created by Ushio on 11/22/16.
//

import Foundation

/// Represents a song in MPD
class MISong: NSObject {
    
    /// Variables
    
    /// The path to the file of this song(relative to the MPD folder)
    var file : String = "";
    
    /// The date this song's file was last modified
    var lastModified : NSDate = NSDate(timeIntervalSince1970: TimeInterval(0));
    
    /// The artist of this song
    var artist : String = "";
    
    /// Same as artist but for sorting
    var artistSort : String = "";
    
    /// The album of this song
    var album : String = "";
    
    /// Same as album but for sorting
    var albumSort : String = "";
    
    /// The artist of this album
    var albumArtist : String = "";
    
    /// Same as albumArtist but for sorting
    var albumArtistSort : String = "";
    
    /// The title of this song
    var title : String = "";
    
    /// The track number of this song
    var track : Int = -1;
    
    /// From the MPD docs: a name for this song. This is not the song title. The exact meaning of this tag is not well-defined. It is often used by badly configured internet radio stations with broken tags to squeeze both the artist name and the song title in one tag.
    var name : String = "";
    
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
    
    /// This song's position on the playlist(if it is in the current playlist)
    var position : Int = -1;
    
    /// The ID of this song
    var id : Int = -1;
    
    /// The debug description for this song
    override var debugDescription : String {
        return "\(self): \(self.title) by \(self.artist)(\(self.length) seconds long), in album \(self.album)";
    }
    
    
    /// Init
    
    /// Returns an array of MISongs based on the given string(should be a playlistinfo or similar)
    static func from(songList : String) -> [MISong] {
        /// The array of MISongs to return
        var songs : [MISong] = [];
        
        /// 'songList' split at every "file:"
        var songListSplitAtFile : [String] = songList.components(separatedBy: "file:");
        
        // Remove the first item(it's blank)
        songListSplitAtFile.removeFirst();
        
        // For every item in 'songListSplitAtFile'...
        for(_, currentSongListItem) in songListSplitAtFile.enumerated() {
            /// 'currentSongListItem' with "file:" on the front
            let currentSongListItemWithFile : String = "file:" + currentSongListItem;
            
            // Add the MISong for the current item to 'songs'
            songs.append(MISong(string: currentSongListItemWithFile));
        }
        
        // Return the songs
        return songs;
    }
    
    /// Init from a string returned by MPD
    init(string : String) {
        // Example string
        //
        // file: K-On!/K-ON MHB D1/01 Cagayake! GIRLS.mp3
        // Last-Modified: 2015-06-12T17:07:42Z
        // Artist: HO-KAGO TEA TIME/Toyasaki Aki & Hisaka Youko & Satou Satomi & Kotobuki Minako
        // Album: K-ON! MUSIC HISTORY'S BOX CD1
        // Title: Cagayake! GIRLS
        // Track: 1
        // Genre: Anime
        // Date: 2013
        // Disc: 1/15
        // AlbumArtist: HO-KAGO TEA TIME;
        // Time: 250
        // Pos: 0
        // Id: 47
        //
        
        // For every line in the given string...
        for(_, currentLine) in string.components(separatedBy: "\n").enumerated() {
            /// The prefix for this line(e.g. file:, Album:, etc.)
            var prefix : String = "";
            
            /// The content for this line(the line without the prefix)
            var content : String = "";
            
            /// 'currentLine' split at every space
            var currentLineSplitAtSpaces : [String] = currentLine.components(separatedBy: " ");
            
            // Set prefix to the first item in 'currentLineSplitAtSpaces' and remove it from the array
            prefix = currentLineSplitAtSpaces[0];
            currentLineSplitAtSpaces.remove(at: 0);
            
            // For every item in currentLineSplitAtSpaces...
            for(_, currentSplitItem) in currentLineSplitAtSpaces.enumerated() {
                // Append 'currentSplitItem' to content
                content = content + " " + currentSplitItem;
            }
            
            // If 'currentLineSplitAtSpaces' has at least one item...
            if(currentLineSplitAtSpaces.count > 0) {
                // Remove the leading space from content
                content = content.substring(from: content.index(after: content.startIndex));
            }
            
            // Switch and set the appropriate variable based on the prefix
            switch(prefix) {
                case "file:":
                    self.file = content;
                    break;
                
                case "Last-Modified:":
                    // Replace the T with a space and remove the Z in 'content'
                    content = content.replacingOccurrences(of: "T", with: " ");
                    content = content.replacingOccurrences(of: "Z", with: "");
                    
                    /// The date formatter for reading the last modified date
                    let dateFormatter : DateFormatter = DateFormatter();
                    
                    // Setup the date formatter
                    dateFormatter.timeZone = NSTimeZone.default;
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
                    
                    /// The date from 'contents'
                    let date : NSDate? = dateFormatter.date(from: content) as NSDate?;
                    
                    // Set the last modified date
                    self.lastModified = ((date == nil) ? NSDate(timeIntervalSince1970: TimeInterval(0)) : date!);
                    break;
                
                case "Artist:":
                    self.artist = content;
                    break;
                
                case "ArtistSort:":
                    self.artistSort = content;
                    break;
                
                case "Album:":
                    self.album = content;
                    break;
                
                case "AlbumSort:":
                    self.albumSort = content;
                    break;
                
                case "AlbumArtist:":
                    self.albumArtist = content;
                    break;
                
                case "AlbumArtistSort:":
                    self.albumArtistSort = content;
                    break;
                
                case "Title:":
                    self.title = content;
                    break;
                
                case "Track:":
                    self.track = Int(NSString(string: content).intValue);
                    break;
                
                case "Name:":
                    self.name = content;
                    break;
                
                case "Genre:":
                    self.genre = content;
                    break;
                
                case "Date:":
                    self.year = Int(NSString(string: content).intValue);
                    break;
                
                case "Composer:":
                    self.composer = content;
                    break;
                
                case "Performer:":
                    self.performer = content;
                    break;
                
                case "Comment:":
                    self.comment = content;
                    break;
                
                case "Disc:":
                    let contentSplitAtSlash : [String] = content.components(separatedBy: "/");
                    disc = Int(NSString(string: contentSplitAtSlash[0]).intValue);
                    discCount = Int(NSString(string: contentSplitAtSlash[1]).intValue);
                    break;
                
                case "Time:":
                    self.length = Int(NSString(string: content).intValue);
                    break;
                
                case "Pos:":
                    self.position = Int(NSString(string: content).intValue);
                    break;
                
                case "Id:":
                    self.id = Int(NSString(string: content).intValue);
                    break;
            
                default:
                    break;
            }
        }
    }
}
