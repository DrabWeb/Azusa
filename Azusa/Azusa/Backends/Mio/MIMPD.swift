//
//  MIMPD.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/7/16.
//

import Foundation
import MPD

/// Basics for using libmpdclient easily in swift
class MIMPD {
    // MARK: - Properties
    
    /// The connection to MPD for this object(`mpd_connection`)
    var connection: OpaquePointer? = nil;
    
    /// Is this MPD object connected to a server?
    var connected : Bool = false;
    
    /// The default amount of seconds to timeout connections
    var connectionTimeout : Int = 30;
    
    /// The address of the MPD server this object should connect to
    var serverAddress : String = "127.0.0.1";
    
    /// The port of the MPD server this object should connect to
    var serverPort : Int = 6600;
    
    
    // MARK: - Functions
    
    /// Connects to the server this object was set up to connect to, using `serverAddress` and `serverPort`
    ///
    /// - Returns: Returns if the connection was successful
    func connect() -> Bool {
        // Run connect with `serverAddress` and `serverPort`, and return the output
        return self.connect(address: self.serverAddress, port: self.serverPort);
    }
    
    /// Connects to the server at the given address and port
    ///
    /// - Parameters:
    ///   - address: The address of the server(e.g. `127.0.0.1`)
    ///   - port: The port of the server(e.g. `6600`)
    /// - Returns: If the connection was successful
    func connect(address : String, port : Int) -> Bool {
        AZLogger.log("MIMPD: Connecting to \(address):\(port)...");
        
        // Open the connection
        self.connection = mpd_connection_new(address, UInt32(port), UInt32(self.connectionTimeout * 1000));
        
        // If we tried to connect to the server and it wasn't successful...
        if(mpd_connection_get_error(self.connection) != MPD_ERROR_SUCCESS) {
            AZLogger.log("MIMPD: Error connecting to server at \(address):\(port), \(self.errorMessageFor(connection: self.connection!))");
            
            // Remove the connection
            self.connection = nil;
            
            // Return that the connection was unsuccessful
            return false;
        }
        
        AZLogger.log("MIMPD: Connected to \(address):\(port)");
        
        // Say that this object is connected
        self.connected = true;
        
        // Return that the connection was successful
        return true;
    }
    
    /// Disconnects from MPD(if it's connected)
    func disconnect() {
        // If `connection` is set...
        if(self.connection != nil) {
            // Free `connection`
            mpd_connection_free(self.connection);
            
            // Remove `connection`
            self.connection = nil;
        }
        
        // Say we are no longer connected
        self.connected = false;
    }
    
    func getStats() -> MIMPDStats {
        // If `connection isn't nil`...
        if(self.connection != nil) {
            /// The stats object for `connection`
            let statsObject = mpd_run_stats(self.connection!);
            
            // If `statsObject` is nil...
            if(statsObject == nil) {
                AZLogger.log(self.errorMessageFor(connection: self.connection!));
                
                // Return an empty stats object
                return MIMPDStats();
            }
            
            /// The number of distinct album names in MPD's database, or 0 if unknown
            let albumCount : Int = Int(mpd_stats_get_number_of_albums(statsObject));
            
            /// The number of distinct artists in MPD's database, or 0 if unknown
            let artistCount : Int = Int(mpd_stats_get_number_of_artists(statsObject));
            
            /// The total number of song files in MPD's database, or 0 if unknown
            let songCount : Int = Int(mpd_stats_get_number_of_songs(statsObject));
            
            /// The accumulated duration of all songs in the database, or 0 if unknown
            let databasePlayTime : Int = Int(mpd_stats_get_db_play_time(statsObject));
            
            /// The uptime of MPD in seconds, or 0 if unknown
            let mpdUptime : Int = Int(mpd_stats_get_uptime(statsObject));
            
            /// The accumulated time MPD was playing music since the process was started, or 0 if unknown
            let mpdPlayTime : Int = Int(mpd_stats_get_play_time(statsObject));
            
            /// The UNIX time stamp of the last database update, or 0 if unknown
            let lastMpdDatabaseUpdate : Int = Int(mpd_stats_get_db_update_time(statsObject));
            
            // Return an MIMPDStats object with the retrieved values
            return MIMPDStats(albumCount: albumCount,
                               artistCount: artistCount,
                               songCount: songCount,
                               databasePlayTime: databasePlayTime,
                               mpdUptime: mpdUptime,
                               mpdPlayTime: mpdPlayTime,
                               lastMpdDatabaseUpdate: NSDate(timeIntervalSince1970: TimeInterval(lastMpdDatabaseUpdate)));
        }
        // If `connection is nil`...
        else {
            AZLogger.log("MIMPD: Cannot retrieve stats, connection does not exist(run connect first)");
            
            // Return an empty stats object
            return MIMPDStats();
        }
    }
    
    
    // MARK: - Utilities
    
    /// Returns the error message for the given MPD connection
    ///
    /// - Parameter connection: The `mpd_connection` to get the error from
    /// - Returns: The error message, defaults to `"No Error Message"`
    func errorMessageFor(connection: OpaquePointer) -> String {
        /// The MPD error from `connection`
        let error = mpd_connection_get_error_message(connection);
        
        // If `error` isn't nil...
        if(error != nil) {
            /// The data of the error message
            let messageData : Data = Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: error!), count: Int(strlen(error!)), deallocator: .none);
            
            // If the string from `messageData` isn't nil...
            if let message = String(data: messageData, encoding: .utf8) {
                // Return the string from `messageData`
                return message;
            }
        }
        
        // Default to returning a "No Error Message" message
        return "No Error Message";
    }
    
    
    // MARK: - Initialization and deinitialization
    
    deinit {
        // Deinitialize this MPD object
        self.disconnect();
    }
}


// MARK: - Objects

/// Represents the stats of an MPD server
class MIMPDStats {
    
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
    
    var debugDescription : String {
        return "\(self.albumCount) albums, " +
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
