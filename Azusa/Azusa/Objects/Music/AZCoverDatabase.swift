//
//  AZCoverDatabase.swift
//  Azusa
//
//  Created by Ushio on 12/12/16.
//

import Foundation
import AppKit

/// The global cover database for Azusa, used so covers of the same album aren't loading multiple times from disk
struct AZCoverDatabase {
    
    // MARK: - Variables
    
    public static var global : AZCoverDatabase = AZCoverDatabase();
    
    /// All the covers in this database
    private var covers : [String : NSImage] = [:];
    
    
    // MARK: - Functions
    
    /// Adds the given cover to this database
    ///
    /// - Parameters:
    ///   - cover: The cover to add
    ///   - album: The name for the album this cover is for
    mutating func add(cover : NSImage, name : String) {
        // If `name` isn't blank...
        if(name != "") {
            // Add the given values to `covers`
            self.covers[name] = cover;
        }
    }
    
    
    /// Gets the cover image for the given name
    ///
    /// - Parameters:
    ///   - coverName: The name of the cover to get
    ///   - completionHandler: The completion handler for when the cover is loaded, passed the cover(nil if there was no cover under `name`)
    func get(_ coverName : String, completionHandler : @escaping ((NSImage?) -> ())) {
        DispatchQueue(label: "Azusa.Covers").async {
            /// The loaded cover from `covers`
            let cover : NSImage? = self.covers[coverName];
            
            // Call the completion handler with `cover`
            DispatchQueue.main.async {
                completionHandler(cover);
            }
        }
    }
}
