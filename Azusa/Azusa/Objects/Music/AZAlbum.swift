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
    var genre : String = "";
    
    /// The year this album was released
    var year : Int = -1;
    
    /// All the songs in this album
    var songs : [AZSong] = [];
    
    var description : String {
        return "AZAlbum: \(self.name) by \(self.artist.name)(\(self.genre)), \(self.songs.count) songs, released \(year)"
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(name : String, artist : AZArtist, genre : String, year : Int) {
        self.name = name;
        self.artist = artist;
        self.genre = genre;
        self.year = year;
        self.songs = [];
    }
    
    init(name : String, artist : AZArtist) {
        self.name = name;
        self.artist = artist;
        self.genre = "";
        self.year = -1;
        self.songs = [];
    }
    
    init(name : String) {
        self.name = name;
        self.artist = AZArtist();
        self.genre = "";
        self.year = -1;
        self.songs = [];
    }
    
    init() {
        self.name = "";
        self.artist = AZArtist();
        self.genre = "";
        self.year = -1;
        self.songs = [];
    }
}
