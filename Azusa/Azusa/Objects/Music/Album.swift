//
//  Album.swift
//  Azusa
//
//  Created by Ushio on 2/11/17.
//

import Foundation

/// The object to represent an album in the user's music collection
struct Album: CustomStringConvertible {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var name : String = "";
    
    var songs : [Song] = [];
    
    var artists : [Artist] {
        var noDuplicateArtists : [Artist] = [];
        
        self.songs.map { $0.artist }.forEach { artist in
            if(!noDuplicateArtists.contains(artist)) {
                noDuplicateArtists.append(artist);
            }
        }
        
        return noDuplicateArtists;
    }
    
    var duration : Int {
        var length : Int = 0;
        
        self.songs.forEach { song in
            length += song.duration;
        }
        
        return length;
    }
    
    var genres : [Genre] {
        var noDuplicateGenres : [Genre] = [];
        
        self.songs.map { $0.genre }.forEach { genre in
            if(!noDuplicateGenres.contains(genre)) {
                noDuplicateGenres.append(genre);
            }
        }
        
        return noDuplicateGenres;
    };
    
    var year : Int {
        var releaseYear : Int = -1;
        
        self.songs.forEach {
            releaseYear = $0.year;
        }
        
        return releaseYear;
    };
    
    var displayName : String {
        return ((self.name != "") ? self.name : "Unknown Album");
    }
    
    /// Gets the user readable version of this album's artist(s)
    ///
    /// - Parameter shorten: If there are multiple artists, should the string be shortened to "Various Artists"?
    /// - Returns: The user readable version of this album's artist(s)
    func displayArtists(shorten : Bool) -> String {
        let artists : [Artist] = self.artists;
        
        //
        // "Various Artists"
        // "Kuricorder Quartet"
        // "Heart of Air, Kow Otani"
        // "Unknown Artist"
        //
        
        if(artists.count == 1) {
            return self.artists[0].displayName;
        }
        else if(artists.count > 1) {
            if(shorten) {
                return "Various Artists";
            }
            else {
                var displayArtistsString : String = "";
                
                for(index, artist) in artists.enumerated() {
                    displayArtistsString += "\(artist.displayName)\((index == (artists.count - 1)) ? "" : ", ")";
                }
                
                return displayArtistsString;
            }
        }
        else {
            return "Unknown Artist";
        }
    }
    
    var displayGenres : String {
        var displayGenreString : String = "";
        
        let albumGenres : [Genre] = self.genres;
        
        for(index, genre) in albumGenres.enumerated() {
            if(genre.name != "") {
                displayGenreString += "\(genre.name)\((index == (albumGenres.count - 1)) ? "" : ", ")";
            }
        }
        
        if(displayGenreString == "") {
            displayGenreString = "Unknown Genre";
        }
        
        return displayGenreString;
    }
    
    var displayYear : String {
        let year : Int = self.year;
        
        return (year == -1 || year == 0) ? "Unknown Year" : "\(year)";
    }
    
    var description : String {
        return "Album: \(self.displayName) by \(self.artists)(\(self.genres)), \(self.songs.count) songs, released in \(year)"
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(name : String, songs : [Song]) {
        self.name = name;
        self.songs = songs;
    }
    
    init(name : String) {
        self.name = name;
        self.songs = [];
    }
    
    init() {
        self.name = "";
        self.songs = [];
    }
}
