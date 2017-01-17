//
//  AZCoverDatabase.swift
//  Azusa
//
//  Created by Ushio on 12/12/16.
//

import Foundation
import AppKit

/// The global cover database for Azusa, used so covers of the same album aren't loading multiple times from disk
class AZCoverDatabase {
    
    /// The global AZCoverDatabase object
    static let global : AZCoverDatabase = AZCoverDatabase();
    
    
    // MARK: - Thumbnails
    
    /// The `NSCache` object for thumbnails in this cover database
    private let thumbnailCache : NSCache = NSCache<NSString, NSImage>();
    
    /// All the names of the thumbnails that have been requested by a `AZSong.getThumbnailImage` call
    private var requestedThumbnailNames : [String] = [];
    
    /// All the `Azusa.AZCoverDatabase.ThumbnailAdded` notification listeners from `get(thumbnail:completionHandler:)`
    private var thumbnailNotificationObservers : [(name : String, observer : NSObjectProtocol)] = [];
    
    /// Adds the given thumbnail to this database
    ///
    /// - Parameters:
    ///   - thumbnail: The thumbnail to add(resized to fit `250x250`)
    ///   - name: The identifier for the thumbnail
    func add(thumbnail : NSImage, name : String) {
        // If `name` isn't blank(we don't want to cache those)...
        if(name != "") {
            // Add the given thumbnail to `thumbnailCache`
            thumbnailCache.setObject(thumbnail, forKey: NSString(string: name));
            
            // Post the notification that the thumbnail was added, with the thumbnail
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Azusa.AZCoverDatabase.ThumbnailAdded-\(name)"), object: thumbnail);
            
            // Remove all the notification observers from `get` under `name`
            thumbnailNotificationObservers = thumbnailNotificationObservers.enumerated().filter { $0.element.name == name }.map { $0.element };
        }
    }
    
    /// Gets the thumbnail for the given name
    ///
    /// - Parameters:
    ///   - thumbnailName: The name of the thumbnail to get
    ///   - completionHandler: The completion handler for when the thumbnail is loaded, passed the thumbnail
    func get(thumbnail thumbnailName : String, completionHandler : @escaping ((NSImage) -> ())) {
        DispatchQueue(label: "Azusa.Covers").async {
            /// The loaded thumbnail from `thumbnailCache`
            var thumbnailImage : NSImage? = self.thumbnailCache.object(forKey: NSString(string: thumbnailName));
            
            // If the thumbnail already requested and `thumbnailImage` is nil...
            if(self.thumbnailWasRequested(for: thumbnailName) && thumbnailImage == nil) {
                // Listen for when the thumbnail loads for `thumbnailName`
                self.thumbnailNotificationObservers.append((thumbnailName, NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "Azusa.AZCoverDatabase.ThumbnailAdded-\(thumbnailName)"), object: nil, queue: nil) { notification in
                    // Call the completion handler with the image from `notification`
                    DispatchQueue.main.async {
                        completionHandler((notification.object as? NSImage) ?? #imageLiteral(resourceName: "AZDefaultCover"));
                    }
                }));
            }
            else {
                // Call the completion handler with `thumbnailImage`
                DispatchQueue.main.async {
                    completionHandler(thumbnailImage ?? #imageLiteral(resourceName: "AZDefaultCover"));
                    
                    thumbnailImage = nil;
                }
            }
        }
    }
    
    /// Adds the given name to the array of requested thumbnail names
    ///
    /// - Parameter name: The name to list
    func addThumbnailNameToRequested(name : String) {
        if(!self.requestedThumbnailNames.contains(name)) {
            self.requestedThumbnailNames.append(name);
        }
    }
    
    /// Was a thumbnail already requested under the given name?
    ///
    /// - Parameter name: The name to check under
    /// - Returns: If the thumbnail was already requested for the given name
    func thumbnailWasRequested(for name : String) -> Bool {
        return requestedThumbnailNames.contains(name);
    }
    
    
    // MARK: - Covers
    
    /// The `NSCache` object for covers in this cover database
    private let coverCache : NSCache = NSCache<NSString, NSImage>();
    
    /// All the names of the covers that have been requested by a `AZSong.getCoverImage` call
    private var requestedCoverNames : [String] = [];
    
    /// All the `Azusa.AZCoverDatabase.CoverAdded` notification listeners from `get(cover:completionHandler:)`
    private var coverNotificationObservers : [(name : String, observer : NSObjectProtocol)] = [];
    
    /// Adds the given cover to this database
    ///
    /// - Parameters:
    ///   - cover: The cover to add
    ///   - name: The identifier for the cover
    func add(cover : NSImage, name : String) {
        // If `name` isn't blank(we don't want to cache those)...
        if(name != "") {
            // Add the given thumbnail to `thumbnailCache`
            coverCache.setObject(cover, forKey: NSString(string: name));
            
            // Post the notification that the thumbnail was added, with the thumbnail
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Azusa.AZCoverDatabase.CoverAdded-\(name)"), object: cover);
            
            // Remove all the notification observers from `get` under `name`
            coverNotificationObservers = coverNotificationObservers.enumerated().filter { $0.element.name == name }.map { $0.element };
        }
    }
    
    /// Gets the cover for the given name
    ///
    /// - Parameters:
    ///   - coverName: The name of the cover to get
    ///   - completionHandler: The completion handler for when the cover is loaded, passed the cover
    func get(cover coverName : String, completionHandler : @escaping ((NSImage) -> ())) {
        DispatchQueue(label: "Azusa.Covers").async {
            /// The loaded cover from `coverCache`
            var coverImage : NSImage? = self.coverCache.object(forKey: NSString(string: coverName));
            
            // If the cover already requested and `coverImage` is nil...
            if(self.coverWasRequested(for: coverName) && coverImage == nil) {
                // Listen for when the thumbnail loads for `thumbnailName`
                self.coverNotificationObservers.append((coverName, NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "Azusa.AZCoverDatabase.CoverAdded-\(coverName)"), object: nil, queue: nil) { notification in
                    // Call the completion handler with the image from `notification`
                    DispatchQueue.main.async {
                        completionHandler((notification.object as? NSImage) ?? #imageLiteral(resourceName: "AZDefaultCover"));
                    }
                }));
            }
            else {
                // Call the completion handler with `coverImage`
                DispatchQueue.main.async {
                    completionHandler(coverImage ?? #imageLiteral(resourceName: "AZDefaultCover"));
                    
                    coverImage = nil;
                }
            }
        }
    }
    
    /// Adds the given name to the array of requested cover names
    ///
    /// - Parameter name: The name to list
    func addCoverNameToRequested(name : String) {
        if(!self.requestedCoverNames.contains(name)) {
            self.requestedCoverNames.append(name);
        }
    }
    
    /// Was a cpver already requested under the given name?
    ///
    /// - Parameter name: The name to check under
    /// - Returns: If the cover was already requested for the given name
    func coverWasRequested(for name : String) -> Bool {
        return requestedCoverNames.contains(name);
    }
}
