//
//  Artwork.swift
//  Yui
//
//  Created by Ushio on 2/12/17.
//

import Cocoa

// MARK: - ArtworkSize
public enum ArtworkSize : Int {
    case thumb = 48
    case small = 192
    case large = 512
    case original = 0
}

// MARK: - ArtworkCache
public class ArtworkCache {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public class var global : ArtworkCache {
        return _global;
    }
    
    // MARK: Private Properties
    
    private let basePath : String = "\(NSHomeDirectory())/Library/Application Support/Azusa/ArtworkCache"
    private static let _global : ArtworkCache = ArtworkCache();
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    /// Creates the cover databases for the given `Song`s
    ///
    /// - Parameter songs: The songs to create cover databases for
    /// - Parameter callback: The closure to perform when a cover database is created for a `Song` in `songs`, passed the index of the last cached and the count of all the songs to cache
    public func addArt(of songs : [Song], callback : ((Int, Int) -> Void)?, completion : ((Int) -> Void)?) {
        Logger.log("ArtworkCache: Caching artwork of \(songs.count) song\(songs.count == 1 ? "" : "s")");
        
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            for (index, song) in songs.enumerated() {
                autoreleasepool {
                    self.saveArtwork(of: song);
                }
                
                DispatchQueue.main.async {
                    callback?(index, songs.count);
                }
                
                if index == (songs.count - 1) {
                    Logger.log("ArtworkCache: Finished caching artwork");
                    completion?(songs.count);
                }
            }
        }
    }
    
    /// Gets the artwork of the given `Song`s in the given `ArtworkSize`
    ///
    /// - Parameters:
    ///   - song: The song to get the artwork of
    ///   - size: The size of artwork to get
    ///   - completionHandler: The closure to call upon loading completion, passed the loaded cover
    public func getArt(of song : Song, withSize size : ArtworkSize, completion completionHandler : @escaping ((NSImage?) -> Void)) {
        var artwork : NSImage? = nil;
        
        func complete() {
            DispatchQueue.main.async {
                completionHandler(artwork);
            }
        }
        
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            autoreleasepool {
                switch size {
                    case .large, .small, .thumb:
                        // Get the art from file and if it doesn't already exist add it then create the cache and then add it
                        let path = "\(self.basePath(for: song))/\(self.filename(for: size))";
                        if FileManager.default.fileExists(atPath: path) {
                            artwork = NSImage(contentsOfFile: path);
                            complete();
                        }
                        else {
                            self.addArt(of: [song], callback: nil, completion: { _ in
                                artwork = NSImage(contentsOfFile: path);
                                complete();
                            });
                        }
                        break;
                    
                    case .original:
                        artwork = song.artwork;
                        complete();
                }
            }
        }
    }
    
    /// Deletes all the artwork in the cache
    public func clear() {
        do {
            try FileManager.default.removeItem(atPath: basePath);
        }
        catch let error {
            Logger.logError("ArtworkCache: Error deleting cache, \(error)");
        }
    }
    
    // MARK: Private Methods
    
    /// Gets the directory for artwork caching of the given song
    ///
    /// - Parameter song: The song to get the artwork cache directory of
    /// - Returns: The directory for artwork caching of the given song
    private func basePath(for song : Song) -> String {
        if song.album.name != "" {
            return basePath + "/" + song.displayArtist.replacingOccurrences(of: "/", with: "") + "/" + song.displayAlbum.replacingOccurrences(of: "/", with: "");
        }
        else {
            return basePath + "/" + song.displayArtist.replacingOccurrences(of: "/", with: "") + "/" + song.displayTitle.replacingOccurrences(of: "/", with: "");
        }
    }
    
    /// Gets the artwork cache filename for the given size
    ///
    /// - Parameter size: The size to get the name of
    /// - Returns: The name of the artwork cache file
    private func filename(for size : ArtworkSize) -> String {
        switch size {
            case .thumb:
                return "cover.png";
            
            case .small:
                return "cover_192.png";
            
            case .large:
                return "cover_512.png";
            
            default:
                return "";
        }
    }
    
    /// Saves the artwork of the given song in large, small and thumb sizes to the song's artwork cache directory
    ///
    /// - Parameters:
    ///   - song: The song to cache the artwork of
    ///   - recreate: By default already cached covers will be skipped, setting this to `true` forces it to recreate
    private func saveArtwork(of song : Song, recreate : Bool = false) {
        let directory = basePath(for: song);
        
        //
        // Stores `artwork` in large, small and thumb sizes to the song's artwork caching directory
        // By default doesn't recreate the cache, but will if `recreate` is true
        // Artwork is resized on every pass so the order has to be from largest to smallest, this is so the full cover isn't reloaded over and over
        //
        if var artwork = song.artwork {
            func save(size : ArtworkSize) {
                let name = "/\(filename(for: size))";
                
                if !FileManager.default.fileExists(atPath: directory + name) || recreate {
                    do {
                        try FileManager.default.createDirectory(at: URL(fileURLWithPath: directory), withIntermediateDirectories: true, attributes: [:]);
                        artwork = artwork.resizedTo(fit: size.rawValue);
                        artwork.save(to: directory + name, as: NSBitmapImageFileType.PNG);
                    }
                    catch let error {
                        Logger.logError("ArtworkCache: Error creating artwork cache for \(song), \(error)");
                    }
                }
            }
            
            save(size: .large);
            save(size: .small);
            save(size: .thumb);
        }
    }
    
    // MARK: - Init / Deinit
    
    public init() {
        do {
            try FileManager.default.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil);
        }
        catch let error {
            Logger.logError("ArtworkCache: Error creating artwork cache folder, \(error)");
        }
    }
}
