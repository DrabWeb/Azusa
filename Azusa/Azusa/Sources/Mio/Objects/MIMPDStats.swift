//
//  MIMPDStats.swift
//  Azusa.Mio
//
//  Created by Ushio on 2/11/17.
//

import Foundation

/// Represents the stats of an MPD server
class MIMPDStats: CustomStringConvertible {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var albumCount : Int = 0;
    var artistCount : Int = 0;
    var songCount : Int = 0;
    var databasePlayTime : Int = 0;
    var mpdUptime : Int = 0;
    var mpdPlayTime : Int = 0;
    var lastMpdDatabaseUpdate : NSDate = NSDate();
    
    var description : String {
        return "MIMPDStats: \(self.albumCount) albums, " +
            "\(self.artistCount) artists, " +
            "\(songCount) songs, " +
            "database play time: \(MusicUtilities.displayTime(from: self.databasePlayTime)), " +
            "MPD uptime: \(MusicUtilities.displayTime(from: self.mpdUptime)), " +
            "MPD play time: \(MusicUtilities.displayTime(from: mpdPlayTime)), " +
            "last database update was \(self.lastMpdDatabaseUpdate)";
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(albumCount : Int, artistCount : Int, songCount : Int, databasePlayTime : Int, mpdUptime : Int, mpdPlayTime : Int, lastMpdDatabaseUpdate : NSDate) {
        self.albumCount = albumCount;
        self.artistCount = artistCount;
        self.songCount = songCount;
        self.databasePlayTime = databasePlayTime;
        self.mpdUptime = mpdUptime;
        self.mpdPlayTime = mpdPlayTime;
        self.lastMpdDatabaseUpdate = lastMpdDatabaseUpdate;
    }
    
    init() {
        self.albumCount = 0;
        self.artistCount = 0;
        self.songCount = 0;
        self.databasePlayTime = 0;
        self.mpdUptime = 0;
        self.mpdPlayTime = 0;
        self.lastMpdDatabaseUpdate = NSDate();
    }
}
