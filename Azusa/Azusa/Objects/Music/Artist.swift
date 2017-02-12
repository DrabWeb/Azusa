//
//  Artist.swift
//  Azusa
//
//  Created by Ushio on 2/11/17.
//

import Foundation

/// The object to represent an artist in the user's music collection
class Artist: Equatable, CustomStringConvertible {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var name : String = "";
    
    var albums : [Album] = [];
    
    var displayName : String {
        return ((self.name != "") ? self.name : "Unknown Artist");
    }
    
    var description : String {
        return "AZArtist: \(self.displayName), \(self.albums.count) albums"
    }
    
    
    // MARK: - Methods
    
    static func ==(lhs : Artist, rhs : Artist) -> Bool {
        return lhs.name == rhs.name;
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(name : String, albums : [Album]) {
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
