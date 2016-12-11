//
//  AZAlbum.swift
//  Azusa
//
//  Created by Ushio on 12/8/16.
//

import Foundation

/// The object to represent an album in the user's music collection
class AZAlbum: CustomStringConvertible {
    
    // MARK: - Properties
    
    /// The name of this album
    var name : String = "";
    
    /// The artist of this album
    var artist : AZArtist = AZArtist();
    
    /// The genre of this album
    var genre : AZGenre = AZGenre();
    
    /// The year this album was released
    var year : Int = -1;
    
    /// All the songs in this album
    var songs : [AZSong] = [];
    
    /// The user readable version of this album's name
    var displayName : String {
        return ((self.name != "") ? self.name : "Unknown Album");
    }
    
    var description : String {
        return "AZAlbum: \(self.displayName) by \(self.artist.displayName)(\(self.genre.displayName)), \(self.songs.count) songs, released \(year)"
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(name : String, artist : AZArtist, genre : AZGenre, year : Int) {
        self.name = name;
        self.artist = artist;
        self.genre = genre;
        self.year = year;
        self.songs = [];
    }
    
    init(name : String, artist : AZArtist) {
        self.name = name;
        self.artist = artist;
        self.genre = AZGenre();
        self.year = -1;
        self.songs = [];
    }
    
    init(name : String) {
        self.name = name;
        self.artist = AZArtist();
        self.genre = AZGenre();
        self.year = -1;
        self.songs = [];
    }
    
    init() {
        self.name = "";
        self.artist = AZArtist();
        self.genre = AZGenre();
        self.year = -1;
        self.songs = [];
    }
}
