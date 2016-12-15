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
    public static var global : AZCoverDatabase = AZCoverDatabase();
    
    /// All the thumbnails in this database
    private var thumbnails : [String : NSImage] = [:];
    
    
    // MARK: - Functions
    
    /// Adds the given thumbnail to this database
    ///
    /// - Parameters:
    ///   - thumbnail: The thumbnail to add(resized to fit `300x300`)
    ///   - album: The name for the album this cover is for
    func add(thumbnail : NSImage, name : String) {
        // If `name` isn't blank...
        if(name != "") {
            // Add the given thumbnail to `thumbnails`
            self.thumbnails[name] = thumbnail.resizedTo(fit: 300);
        }
    }
    
    /// Gets the cover thumbnail for the given name
    ///
    /// - Parameters:
    ///   - thumbnailName: The name of the thumbnail to get
    ///   - completionHandler: The completion handler for when the thumbnail is loaded, passed the cover(nil if there was no thumbnail under `name`)
    func get(thumbnail thumbnailName : String, completionHandler : @escaping ((NSImage?) -> ())) {
        DispatchQueue(label: "Azusa.Covers").async {
            /// The loaded thumbnail from `thumbnails`
            let thumbnailImage : NSImage? = self.thumbnails[thumbnailName];
            
            // Call the completion handler with `thumbnailImage`
            DispatchQueue.main.async {
                completionHandler(thumbnailImage);
            }
        }
    }
}
