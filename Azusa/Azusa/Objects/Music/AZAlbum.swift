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
    
    /// The artists of this album
    var artists : [AZArtist] {
        var noDuplicateArtists : [AZArtist] = [];
        
        self.songs.map { $0.artist }.forEach { artist in
            if(!noDuplicateArtists.contains(artist)) {
                noDuplicateArtists.append(artist);
            }
        }
        
        return noDuplicateArtists;
    };
    
    /// The duration in seconds for all the songs in this album
    var duration : Int {
        var length : Int = 0;
        
        self.songs.forEach {
            length += $0.duration;
        }
        
        return length;
    }
    
    /// The genres of this album
    var genres : [AZGenre] {
        var noDuplicateGenres : [AZGenre] = [];
        
        self.songs.map { $0.genre }.forEach { genre in
            if(!noDuplicateGenres.contains(genre)) {
                noDuplicateGenres.append(genre);
            }
        }
        
        return noDuplicateGenres;
    };
    
    /// The year this album was released
    var year : Int {
        var releaseYear : Int = -1;
        
        self.songs.forEach {
            releaseYear = $0.year;
        }
        
        return releaseYear;
    };
    
    /// All the songs in this album
    var songs : [AZSong] = [];
    
    /// The user readable version of this album's name
    var displayName : String {
        return ((self.name != "") ? self.name : "Unknown Album");
    }
    
    /// Gets the user readable version of this album's artist(s)
    ///
    /// - Parameter shorten: If there are multiple artists, should the string be shortened to "Various Artists"?
    /// - Returns: The user readable version of this album's artist(s)
    func displayArtists(shorten : Bool) -> String {
        let artists : [AZArtist] = self.artists;
        
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
    
    /// The user readable version of this album's genres
    var displayGenres : String {
        var displayGenreString : String = "";
        
        let albumGenres : [AZGenre] = self.genres;
        
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
    
    /// The user readable version of this album's release year
    var displayYear : String {
        let year : Int = self.year;
        
        return (year == -1 || year == 0) ? "Unknown Year" : "\(year)";
    }
    
    /// Gets the thumbnail image for this album
    ///
    /// - Parameter completionHandler: The completion handler for when the thumbnail image is loaded, passed the thumbnail
    func getThumbnailImage(_ completionHandler: @escaping ((NSImage) -> ())) {
        // Return the thumbnail image of the first song if there is one
        if(self.songs.count > 0) {
            self.songs[0].getThumbnailImage({ thumbnail in
                completionHandler(thumbnail);
            });
        }
        // Default to the default cover if there are no songs
        else {
            completionHandler(#imageLiteral(resourceName: "AZDefaultCover"));
        }
    }
    
    /// Gets the cover image for this album
    ///
    /// - Parameter completionHandler: The completion handler for when the cover image is loaded, passed the cover
    func getCoverImage(_ completionHandler: @escaping ((NSImage) -> ())) {
        // Return the cover image of the first song if there is one
        if(self.songs.count > 0) {
            self.songs[0].getCoverImage({ cover in
                completionHandler(cover);
            });
        }
        // Default to the default cover if there are no songs
        else {
            completionHandler(#imageLiteral(resourceName: "AZDefaultCover"));
        }
    }
    
    var description : String {
        return "AZAlbum: \(self.displayName) by \(self.artists)(\(self.genres)), \(self.songs.count) songs, released in \(year)"
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(name : String, songs : [AZSong]) {
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
