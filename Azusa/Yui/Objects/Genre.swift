//
//  Genre.swift
//  Yui
//
//  Created by Ushio on 2/11/17.
//

import Foundation

/// The object to represent a music genre
public class Genre: Equatable, CustomStringConvertible {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public var name : String = "";
    
    public var displayName : String {
        return ((self.name != "") ? self.name : "Unknown Genre");
    }
    
    public var description : String {
        return "Genre: \(self.displayName)"
    }
    
    
    // MARK: - Methods
    
    public static func ==(lhs : Genre, rhs : Genre) -> Bool {
        return lhs.name == rhs.name;
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    public init(name : String) {
        self.name = name;
    }
    
    public init() {
        self.name = "";
    }
}
