//
//  Artist.swift
//  Yui
//
//  Created by Ushio on 2/11/17.
//

import Foundation

/// The object to represent an artist in the user's music collection
public class Artist: Equatable, CustomStringConvertible {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public var name : String = "";
    
    public var albums : [Album] = [];
    
    public var displayName : String {
        return ((self.name != "") ? self.name : "Unknown Artist");
    }
    
    public var description : String {
        return "AZArtist: \(self.displayName), \(self.albums.count) albums"
    }
    
    
    // MARK: - Methods
    
    public static func ==(lhs : Artist, rhs : Artist) -> Bool {
        return lhs.name == rhs.name;
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    public init(name : String, albums : [Album]) {
        self.name = name;
        self.albums = albums;
    }
    
    public init(name : String) {
        self.name = name;
        self.albums = [];
    }
    
    public init() {
        self.name = "";
        self.albums = [];
    }
}
