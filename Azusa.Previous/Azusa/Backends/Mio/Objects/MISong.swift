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
    var id : Int = -1;
    
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
    
    var coverIdentifier : String {
        if(self.album.name != "") {
            return self.album.name;
        }
        else {
            return self.uri;
        }
    }
    
    /// Was `cancelGetThumbnailImage` called?
    /// Reset after `getThumbnailImage` tries to call it's completion handler
    private var cancelledGetThumbnailImage : Bool = false;
    
    func getThumbnailImage(_ completionHandler: @escaping ((NSImage) -> ())) {
        // If the thumbnail wasn't already requested...
        if(!AZCoverDatabase.global.thumbnailWasRequested(for: self.coverIdentifier)) {
            DispatchQueue(label: "Azusa.Mio.MISong.\(self.uri).Thumbnail").async {
                /// The thumbnail to return
                let thumbnail : NSImage = self.coverImage.resizedTo(fit: 250);
                
                // Add the thumbnail to the database
                AZCoverDatabase.global.add(thumbnail: thumbnail, name: self.coverIdentifier);
                
                // Return `thumbnail`
                DispatchQueue.main.async {
                    // If the `getThumbnailImage` wasn't cancelled...
                    if(!self.cancelledGetThumbnailImage) {
                        // Reset `cancelledGetThumbnailImage`
                        self.cancelledGetThumbnailImage = false;
                        
                        // Call the completion handler with `thumbnail`
                        completionHandler(thumbnail);
                    }
                }
            }
        }
        // If the thumbnail was already requested...
        else {
            // Try to load the thumbnail image from the database
            AZCoverDatabase.global.get(thumbnail: self.coverIdentifier, completionHandler: { databaseThumbnailImage in
                // If the `getThumbnailImage` wasn't cancelled...
                if(!self.cancelledGetThumbnailImage) {
                    // Call the completion handler with `databaseThumbnailImage`
                    completionHandler(databaseThumbnailImage);
                    
                    // Reset `cancelledGetThumbnailImage`
                    self.cancelledGetThumbnailImage = false;
                }
            });
        }
        
        // Add the cover identifier to the requested cover names
        AZCoverDatabase.global.addThumbnailNameToRequested(name: self.coverIdentifier);
    }
    
    func cancelGetThumbnailImage() {
        // Set `cancelledGetThumbnailImage` to `true` to indicate the cancel was called
        cancelledGetThumbnailImage = true;
    }
    
    /// Was `cancelGetCoverImage` called?
    /// Reset after `getCoverImage` tries to call it's completion handler
    private var cancelledGetCoverImage : Bool = false;
    
    func getCoverImage(_ completionHandler: @escaping ((NSImage) -> ())) {
        // If the cover wasn't already requested...
        if(!AZCoverDatabase.global.coverWasRequested(for: self.coverIdentifier)) {
            DispatchQueue(label: "Azusa.Mio.MISong.\(self.uri).Cover").async {
                /// The cover to return
                let cover : NSImage = self.coverImage;
                
                // Add the cover to the database
                AZCoverDatabase.global.add(cover: cover, name: self.coverIdentifier);
                
                // Return `cover`
                DispatchQueue.main.async {
                    // If the `getCoverImage` wasn't cancelled...
                    if(!self.cancelledGetCoverImage) {
                        // Reset `cancelledGetCoverImage`
                        self.cancelledGetCoverImage = false;
                        
                        // Call the completion handler with `cover`
                        completionHandler(cover);
                    }
                }
            }
        }
        // If the cover was already requested...
        else {
            // Try to load the cover image from the database
            AZCoverDatabase.global.get(cover: self.coverIdentifier, completionHandler: { databaseCoverImage in
                // If the `getCoverImage` wasn't cancelled...
                if(!self.cancelledGetCoverImage) {
                    // Call the completion handler with `databaseCoverImage`
                    completionHandler(databaseCoverImage);
                    
                    // Reset `cancelledGetCoverImage`
                    self.cancelledGetCoverImage = false;
                }
            });
        }
        
        // Add the cover identifier to the requested cover names
        AZCoverDatabase.global.addCoverNameToRequested(name: self.coverIdentifier);
    }
    
    func cancelGetCoverImage() {
        // Set `cancelledGetCoverImage` to `true` to indicate the cancel was called
        cancelledGetCoverImage = true;
    }
    
    /// Returns the cover image from disk of this song
    private var coverImage : NSImage {
        /// The cover to return
        var cover : NSImage? = nil;
        
        /// The URL for this song's file
        let fileUrl : URL? = URL(fileURLWithPath: self.file);
        
        // If 'fileUrl' isn't nil...
        if(fileUrl != nil) {
            /// The path to the folder this song is in
            let songFolderPath : String = self.file.replacingOccurrences(of: NSString(string: self.file).lastPathComponent, with: "");
            
            do {
                // If there is a file/directory at `songFolderPath`...
                if(FileManager.default.fileExists(atPath: songFolderPath)) {
                    // For every file in `songFolderPath`...
                    for(_, currentFile) in (try FileManager.default.contentsOfDirectory(atPath: songFolderPath)).enumerated() {
                        // If `currentFile` has a png or jpg extension...
                        if(["png", "jpg", "jpeg"].contains(NSString(string: currentFile).pathExtension)) {
                            // Try to load the image at `currentFile` and set `cover` to it if successful
                            if let coverFileImage = NSImage(byReferencingFile: songFolderPath + currentFile) {
                                cover = coverFileImage;
                            }
                        }
                    }
                }
            }
            catch let error {
                AZLogger.log("MISong: Error getting cover from file, \(error.localizedDescription)");
            }
            
            // If the cover *still* isn't set...
            if(cover == nil) {
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
                            // Get the image from the current tag's data, and if it isn't nil...
                            if let tagImage = NSImage(data: currentTag.dataValue!) {
                                // Set the cover image to `tagImage`
                                cover = tagImage;
                            }
                        }
                    }
                }
            }
        }
        
        // Return `cover`
        return cover ?? #imageLiteral(resourceName: "AZDefaultCover");
    }
    
    static var empty : AZSong {
        let song : MISong = MISong();
        
        song.artist = AZArtist();
        song.title = "Song Not Found";
        
        return song;
    }

    func isEmpty() -> Bool {
        return self == MISong.empty;
    }


    // MARK: - Initialization and Deinitialization

    init() {
        
    }
    
    deinit {
        // Cancel any current cover image requests
        self.cancelGetThumbnailImage();
    }
}
