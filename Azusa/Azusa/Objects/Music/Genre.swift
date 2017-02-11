//
//  Genre.swift
//  Azusa
//
//  Created by Ushio on 2/11/17.
//

import Foundation

/// The object to represent a music genre
struct Genre: Equatable, CustomStringConvertible {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var name : String = "";
    
    var displayName : String {
        return ((self.name != "") ? self.name : "Unknown Genre");
    }
    
    var description : String {
        return "Genre: \(self.displayName)"
    }
    
    
    // MARK: - Methods
    
    static func ==(lhs : Genre, rhs : Genre) -> Bool {
        return lhs.name == rhs.name;
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(name : String) {
        self.name = name;
    }
    
    init() {
        self.name = "";
    }
}
