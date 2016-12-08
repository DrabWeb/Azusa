//
//  MIMPDStats.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/7/16.
//

import Foundation

/// Represents the stats of an MPD server
class MIMPDStats: CustomStringConvertible {
    
    // MARK: - Properties
    
    /// The number of distinct album names in MPD's database, or 0 if unknown
    var albumCount : Int = 0;
    
    /// The number of distinct artists in MPD's database, or 0 if unknown
    var artistCount : Int = 0;
    
    /// The total number of song files in MPD's database, or 0 if unknown
    var songCount : Int = 0;
    
    /// The accumulated duration of all songs in the database, or 0 if unknown
    var databasePlayTime : Int = 0;
    
    /// The uptime of MPD in seconds, or 0 if unknown
    var mpdUptime : Int = 0;
    
    /// The accumulated time MPD was playing music since the process was started, or 0 if unknown
    var mpdPlayTime : Int = 0;
    
    /// The date of the last database update, or 0 if unknown
    var lastMpdDatabaseUpdate : NSDate = NSDate();
    
    var description : String {
        return "MIMPDStats: \(self.albumCount) albums, " +
            "\(self.artistCount) artists, " +
            "\(songCount) songs, " +
            "database play time: \(AZMusicUtilities.secondsToDisplayTime(self.databasePlayTime)), " +
            "MPD uptime: \(AZMusicUtilities.secondsToDisplayTime(self.mpdUptime)), " +
            "MPD play time: \(AZMusicUtilities.secondsToDisplayTime(mpdPlayTime)), " +
        "last database update was \(self.lastMpdDatabaseUpdate)";
    }
    
    
    // MARK: - Initialization and deinitialization
    
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
