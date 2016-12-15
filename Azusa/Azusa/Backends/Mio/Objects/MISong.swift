//
//  MISong.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/8/16.
//

import Foundation
import AppKit
import AVFoundation

class MISong: AZSong {
    // MARK: - Properties
    
    /// The MPD URI of this song
    var uri : String = "";
    
    /// The path to the file of this song
    var file : String = "";
    
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
    
    var displayAlbum : String {
        return self.album.displayName;
    }
    
    func getCoverImage(_ completionHandler: @escaping ((NSImage) -> ())) {
        // Try to load the cover image from the database
        AZCoverDatabase.global.get(thumbnail: self.album.name, completionHandler: { databaseCoverImage in
            // If the cover was already in the database...
            if(databaseCoverImage != nil) {
                DispatchQueue.main.async {
                    // Call the completion handler with `databaseCoverImage`
                    completionHandler(databaseCoverImage!);
                }
            }
            // If the cover wasn't in the database...
            else {
                DispatchQueue(label: "Azusa.Covers").async {
                    /// The cover to return
                    var cover : NSImage = #imageLiteral(resourceName: "AZDefaultCover");
                    
                    /// The URL for this song's file
                    let fileUrl : URL? = URL(fileURLWithPath: self.file);
                    
                    // If 'fileUrl' isn't nil...
                    if(fileUrl != nil) {
                        /// The AVFoundation asset for this song
                        let songAsset : AVURLAsset = AVURLAsset(url: fileUrl!);
                        
                        /// The metadata items for this song(initially ID3)
                        var songMetadata : [AVMetadataItem] = songAsset.metadata(forFormat: AVMetadataFormatID3Metadata) as Array<AVMetadataItem>;
                        
                        // If the metadata is empty...
                        if(songMetadata.isEmpty) {
                            // Load the iTunes metadata
                            songMetadata = songAsset.metadata(forFormat: AVMetadataFormatiTunesMetadata) as Array<AVMetadataItem>;
                        }
                        
                        /// For every tag in this song's metadata...
                        for currentTag : AVMetadataItem in songMetadata {
                            // If the current tag is the artwork tag...
                            if(currentTag.commonKey == "artwork") {
                                // If the current tag's data isnt nil...
                                if(currentTag.dataValue != nil) {
                                    /// The image from this tag
                                    let tagImage : NSImage? = NSImage(data: currentTag.dataValue!);
                                    
                                    // If tagImage isnt nil...
                                    if(tagImage != nil) {
                                        // Set the cover image to tagImage
                                        cover = tagImage!;
                                    }
                                }
                            }
                        }
                        
                        // If the cover *still* isn't set...
                        if(cover == #imageLiteral(resourceName: "AZDefaultCover")) {
                            /// The path to the folder this song is in
                            let songFolderPath : String = self.file.replacingOccurrences(of: NSString(string: self.file).lastPathComponent, with: "");
                            
                            // Try to load a `cover.jpg` file
                            if(FileManager.default.fileExists(atPath: songFolderPath + "cover.jpg")) {
                                if let coverFileImage = NSImage(byReferencingFile: songFolderPath + "cover.jpg") {
                                    cover = coverFileImage;
                                }
                            }
                        }
                    }
                    
                    // Add the thumbnail to the database
                    AZCoverDatabase.global.add(thumbnail: cover, name: self.album.name);
                    
                    // Return `cover`
                    DispatchQueue.main.async {
                        completionHandler(cover);
                    }
                }
            }
        });
    }
    
    static var empty : AZSong {
        let song : MISong = MISong();
        
        song.artist = AZArtist();
        song.title = "Song Not Found";
        
        return song;
    };
}
