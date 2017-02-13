//
//  MISong.swift
//  Azusa.Mio
//
//  Created by Ushio on 2/11/17.
//

import Foundation
import AppKit
import AVFoundation

class MISong: Song {
    // MARK: - Properties
    
    // MARK: Public Properties
    
    /// The MPD URI of this song
    var uri : String = "";
    
    /// The path to the file of this song
    var file : String = "";
    
    /// The MPD ID of this song
    var id : Int = -1;
    
    var artist : Artist = Artist();
    var album : Album = Album();
    var albumArtist : Artist = Artist();
    var title : String = "";
    var track : Int = 0;
    var genre : Genre = Genre();
    var year : Int = 0;
    var composer : String = "";
    var performer : String = "";
    var disc : Int = 0;
    var discCount : Int = 0;
    var duration : Int = 0;
    var position : Int = 0;
    
    var description: String {
        return "MISong<\(id) - \(uri)>: \(displayTitle) by \(displayArtist)(\(MusicUtilities.displayTime(from: duration))), in \(displayAlbum)";
    }
    
    var displayTitle : String {
        // If the title is set...
        if(title != "") {
            // Return the title
            return title;
        }
        // If the title isn't set...
        else {
            // If the URI is set...
            if(uri != "") {
                // Return the filename without extension and path
                return NSString(string: NSString(string: uri).lastPathComponent).deletingPathExtension;
            }
            // If the URI isn't set...
            else {
                // Return a string saying we don't know the song title
                return "Unknown Title";
            }
        }
    }
    
    var displayArtist : String {
        return artist.displayName;
    }
    
    var displayAlbum : String {
        return album.displayName;
    }
    
    var artwork : NSImage? {
        var artwork : NSImage? = nil;
        let fileUrl = URL(fileURLWithPath: self.file);
        let songFolderPath : String = self.file.replacingOccurrences(of: NSString(string: self.file).lastPathComponent, with: "");
        
        // Method 1
        // Check for an image in this song's folder
        do {
            if(FileManager.default.fileExists(atPath: songFolderPath)) {
                for(_, currentFile) in (try FileManager.default.contentsOfDirectory(atPath: songFolderPath)).enumerated() {
                    if(["png", "jpg", "jpeg"].contains(NSString(string: currentFile).pathExtension)) {
                        if let artworkFileImage = NSImage(byReferencingFile: songFolderPath + currentFile) {
                            artwork = artworkFileImage;
                        }
                    }
                }
            }
        }
        catch let error {
            Logger.log("MISong: Error getting artwork from file, \(error.localizedDescription)");
        }
        
        // Method 2
        // Check for art in the ID3/iTunes metadata
        if(artwork == nil) {
            let songAsset : AVURLAsset = AVURLAsset(url: fileUrl);
            var songMetadata : [AVMetadataItem] = songAsset.metadata(forFormat: AVMetadataFormatID3Metadata) as Array<AVMetadataItem>;
            
            if(songMetadata.isEmpty) {
                songMetadata = songAsset.metadata(forFormat: AVMetadataFormatiTunesMetadata) as Array<AVMetadataItem>;
            }
            
            for currentTag : AVMetadataItem in songMetadata {
                if(currentTag.commonKey == "artwork") {
                    if(currentTag.dataValue != nil) {
                        if let tagImage = NSImage(data: currentTag.dataValue!) {
                            artwork = tagImage;
                        }
                    }
                }
            }
        }
        
        return artwork;
    }
    
    static var empty : Song {
        let song : MISong = MISong();
        song.title = "Song Not Found";
        
        return song;
    }
    
    var isEmpty : Bool {
        return self == MISong.empty;
    }
}
