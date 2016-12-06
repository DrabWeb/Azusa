//
//  AZSong.swift
//  Azusa
//
//  Created by Ushio on 12/5/16.
//

import Foundation

protocol AZSong {
    
    var title : String { get set };
    
    var artist : String { get set };
    
    func log();
}

class MGSong : AZSong {
    
    var title : String = "Unknown song";
    
    var artist : String = "Unknown Artist";
    
    func log() {
        print("Mugi Song: \(self.title) by \(self.artist)");
    }
}

class YUSong : AZSong {
    var title : String = "Unknown song";
    
    var artist : String = "Unknown Artist";
    
    func log() {
        print("Yui Song: \(self.title) by \(self.artist)");
    }
}
