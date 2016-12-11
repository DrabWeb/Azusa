//
//  AZGenre.swift
//  Azusa
//
//  Created by Ushio on 12/8/16.
//

import Foundation

/// The object to represent a music genre
class AZGenre: CustomStringConvertible {
    
    // MARK: - Properties
    
    /// The name of this genre
    var name : String = "";
    
    /// The albums in this genre(used for caching)
    var albums : [AZAlbum] = [];
    
    /// The user readable version of this genre's name
    var displayName : String {
        return ((self.name != "") ? self.name : "Unknown Genre");
    }
    
    var description : String {
        return "AZGenre: \(self.displayName), \(self.albums.count) albums"
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(name : String, albums : [AZAlbum]) {
        self.name = name;
        self.albums = albums;
    }
    
    init(name : String) {
        self.name = name;
        self.albums = [];
    }
    
    init() {
        self.name = "";
        self.albums = [];
    }
}
