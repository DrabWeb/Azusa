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
    
    // MARK: - Variables
    
    /// The global AZCoverDatabase object
    static let global : AZCoverDatabase = AZCoverDatabase();
    
    /// The `NSCache` object for thumbnails in this cover database
    private let thumbnailCache : NSCache = NSCache<NSString, NSImage>();
    
    /// All the names of the thumbnails that have been requested by a `AZSong.getCoverImage` call
    private var requestedThumbnailNames : [String] = [];
    
    /// All the `Azusa.AZCoverDatabase.CoverAdded` notification listeners from `get(thumbnail:completionHandler:)`
    private var getThumbnailNotificationObservers : [(name : String, observer : NSObjectProtocol)] = [];
    
    
    // MARK: - Functions
    
    /// Adds the given thumbnail to this database
    ///
    /// - Parameters:
    ///   - thumbnail: The thumbnail to add(resized to fit `300x300`)
    ///   - album: The name for the album this cover is for
    func add(thumbnail : NSImage, name : String) {
        // If `name` isn't blank and `thumbnail` isn't the default cover(we don't want to cache those)...
        if(name != "" && thumbnail != #imageLiteral(resourceName: "AZDefaultCover")) {
            // Add the given thumbnail to `thumbnailCache`
            thumbnailCache.setObject(thumbnail, forKey: NSString(string: name));
            
            // Post the notification that the thumbnail was added, with the thumbnail
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Azusa.AZCoverDatabase.ThumbnailAdded-\(name)"), object: thumbnail);
            
            // Remove all the notification observers from `get` under `name`
            getThumbnailNotificationObservers = getThumbnailNotificationObservers.enumerated().filter { $0.element.name == name }.map { $0.element };
        }
    }
    
    /// Gets the cover thumbnail for the given name
    ///
    /// - Parameters:
    ///   - thumbnailName: The name of the thumbnail to get
    ///   - completionHandler: The completion handler for when the thumbnail is loaded, passed the cover(nil if there was no thumbnail under `name`)
    func get(thumbnail thumbnailName : String, completionHandler : @escaping ((NSImage) -> ())) {
        DispatchQueue(label: "Azusa.Covers").async {
            /// The loaded thumbnail from `thumbnails`
            var thumbnailImage : NSImage? = self.thumbnailCache.object(forKey: NSString(string: thumbnailName));
            
            // If the cover thumbnail already requested and `thumbnailImage` is nil...
            if(self.thumbnailWasRequested(for: thumbnailName) && thumbnailImage == nil) {
                // Listen for when the thumbnail loads for `thumbnailName`
                self.getThumbnailNotificationObservers.append((thumbnailName, NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "Azusa.AZCoverDatabase.ThumbnailAdded-\(thumbnailName)"), object: nil, queue: nil) { notification in
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
    func addNameToRequested(name : String) {
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
}
