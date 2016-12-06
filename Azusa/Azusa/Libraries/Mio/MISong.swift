//
//  MISong.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/5/16.
//

import Foundation
import AppKit

/// An object to represent a song in Mio
class MISong : AZSong {
    var artist : String = "";
    
    var album : String = "";
    
    var albumArtist : String = "";
    
    var title : String = "";
    
    var track : Int = -1;
    
    var genre : String = "";
    
    var year : Int = -1;
    
    var composer : String = "";
    
    var performer : String = "";
    
    var comment : String = "";
    
    var disc : Int = -1;
    
    var discCount : Int = -1;
    
    var length : Int = -1;
    
    var position : Int = -1;
    
    var displayTitle : String {
        return "";
    };
    
    var displayArtist : String {
        return "";
    };
    
    var displayAlbum : String {
        return "";
    };
    
    var coverImage : NSImage {
        return #imageLiteral(resourceName: "AZDefaultCover");
    };
    
    static var empty : AZSong {
        return MISong();
    };
}
