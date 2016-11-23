//
//  MISong.swift
//  Azusa
//
//  Created by Ushio on 11/22/16.
//

import Foundation

/// Represents a song in MPD
class MISong {
    
    /// Variables
    
    /// The path to the file of this song(relative to the MPD folder)
    var file : String = "";
    
    /// The date this song's file was last modified
    var lastModified : NSDate = NSDate(timeIntervalSince1970: TimeInterval(0));
    
    /// The artist of this song
    var artist : String = "";
    
    /// The album of this song
    var album : String = "";
    
    /// The title of this song
    var title : String = "";
    
    /// The track number of this song
    var track : Int = -1;
    
    /// The genre of this song
    var genre : String = "";
    
    /// The year this track was released
    var year : Int = -1;
    
    /// The disc number this song is on
    var disc : Int = -1;
    
    /// The total count of discs for the album this song is on
    var discCount : Int = -1;
    
    /// The artist of this album
    var albumArtist : String = "";
    
    /// The length of this song in seconds
    var length : Int = -1;
    
    /// This song's position on the playlist(if it is in the current playlist)
    var position : Int = -1;
    
    /// The ID of this song
    var id : Int = -1;
    
    /// The debug description for this song
    var description : String {
        return "\(self): \(self.title) by \(self.artist)(\(self.length) seconds long), in album \(self.album)";
    }
    
    
    /// Init
    
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
                    break;
                
                case "Artist:":
                    self.artist = content;
                    break;
                
                case "Album:":
                    self.album = content;
                    break;
                
                case "Title:":
                    self.title = content;
                    break;
                
                case "Track:":
                    self.track = Int(NSString(string: content).intValue);
                    break;
                
                case "Genre:":
                    self.genre = content;
                    break;
                
                case "Date:":
                    self.year = Int(NSString(string: content).intValue);
                    break;
                
                case "Disc:":
                    break;
                
                case "AlbumArtist:":
                    self.albumArtist = content;
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