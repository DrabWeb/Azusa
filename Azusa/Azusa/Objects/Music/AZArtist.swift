//
//  AZArtist.swift
//  Azusa
//
//  Created by Ushio on 12/8/16.
//

import Foundation

/// The object to represent an artist in the user's music collection
class AZArtist: CustomStringConvertible {
    
    // MARK: - Properties
    
    /// The name of this artist
    var name : String = "";
    
    /// The albums made by this artist
    var albums : [AZAlbum] = [];
    
    var description : String {
        return "AZArtist: \(self.name), \(self.albums.count) albums"
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
