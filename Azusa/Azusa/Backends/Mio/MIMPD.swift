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
    
    /// Gets the stats of this MPD server
    ///
    /// - Returns: An `MIMPDStats` object that has the current stats of this MPD server
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
    
    /// Gets the current player status of this MPD server
    ///
    /// - Returns: An `MIMPDPlayerStatus` object representing the current status of this MPD server(nil if it fails)
    func getPlayerStatus() -> MIMPDPlayerStatus? {
        /// The player status object to return
        var status : MIMPDPlayerStatus? = nil;
        
        // If the connection isn't nil...
        if(connection != nil) {
            // Create `status`
            status = MIMPDPlayerStatus();
            
            // Set the current song
            status!.currentSong = self.getCurrentSong() ?? MISong.empty;
            
            /// The MPD status object from `connection`
            let mpdStatus = mpd_run_status(self.connection!);
            
            // Set all the other status values
            status!.volume = Int(mpd_status_get_volume(mpdStatus));
            status!.randomOn = mpd_status_get_random(mpdStatus);
            status!.repeatOn = mpd_status_get_repeat(mpdStatus);
            status!.singleOn = mpd_status_get_single(mpdStatus);
            status!.consumeOn = mpd_status_get_consume(mpdStatus);
            status!.queueLength = Int(mpd_status_get_queue_length(mpdStatus));
            status!.currentSongPosition = Int(mpd_status_get_song_pos(mpdStatus));
            status!.nextSongPosition = Int(mpd_status_get_next_song_pos(mpdStatus));
            status!.timeElapsed = Int(mpd_status_get_elapsed_time(mpdStatus));
            
            switch(mpd_status_get_state(mpdStatus)) {
            case MPD_STATE_PLAY:
                status!.playingState = .playing;
                break;
                
            case MPD_STATE_PAUSE:
                status!.playingState = .paused;
                break;
                
            case MPD_STATE_STOP, MPD_STATE_UNKNOWN:
                status!.playingState = .stopped;
                break;
                
            default:
                status!.playingState = .stopped;
                break;
            }
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot retrieve status, connection does not exist(run connect first)");
        }
        
        // Return the player status object
        return status;
    }
    
    
    /// Gets the current playing song and returns it as an MISong(nil if there is none)
    ///
    /// - Returns: The current playing song as an MISong(nil if there is none)
    func getCurrentSong() -> MISong? {
        // Return the MISong of the current song
        return self.songFromMpd(song: mpd_run_current_song(self.connection!));
    }
    
    
    // MARK: - Utilities
    
    /// Returns an `MISong` from an MPD song
    ///
    /// - Parameter song: The MPD song to get the `MISong` of
    /// - Returns: The song from `song`
    func songFromMpd(song: OpaquePointer) -> MISong {
        /// The song to return
        let returnSong : MISong = MISong();
        
        // Load all the values
        
        /// The URI object of `song`
        let uriObject = mpd_song_get_uri(song);
        
        // If `uriObject` isn't nil...
        if(uriObject != nil) {
            /// The data of `uriObject`
            let uriData = Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: uriObject!), count: Int(strlen(uriObject)), deallocator: .none);
            
            // Set `returnSong`'s URI to the string from `uriData`
            returnSong.uri = String(data: uriData, encoding: .utf8) ?? "";
        }
        
        returnSong.id = Int(mpd_song_get_id(song));
        returnSong.artist = self.tagFrom(song: song, tag: MPD_TAG_ARTIST) ?? "";
        returnSong.album = self.tagFrom(song: song, tag: MPD_TAG_ALBUM) ?? "";
        returnSong.albumArtist = self.tagFrom(song: song, tag: MPD_TAG_ALBUM_ARTIST) ?? "";
        returnSong.title = self.tagFrom(song: song, tag: MPD_TAG_TITLE) ?? "";
        returnSong.track = Int(NSString(string: self.tagFrom(song: song, tag: MPD_TAG_TRACK) ?? "").intValue);
        returnSong.genre = self.tagFrom(song: song, tag: MPD_TAG_GENRE) ?? "";
        returnSong.year = Int(NSString(string: self.tagFrom(song: song, tag: MPD_TAG_DATE) ?? "").intValue);
        returnSong.composer = self.tagFrom(song: song, tag: MPD_TAG_COMPOSER) ?? "";
        returnSong.performer = self.tagFrom(song: song, tag: MPD_TAG_PERFORMER) ?? "";
        
        /// The string from the output of the disc metadata, either blank or "#/#"
        let discString = self.tagFrom(song: song, tag: MPD_TAG_DISC) ?? "";
        
        if(discString != "" && discString.contains("/")) {
            returnSong.disc = Int(NSString(string: discString.components(separatedBy: "/").first!).intValue);
            returnSong.discCount = Int(NSString(string: discString.components(separatedBy: "/").last!).intValue);

        }
        returnSong.duration = Int(mpd_song_get_duration(song));
        returnSong.position = Int(mpd_song_get_pos(song));
        
        // Return the song
        return returnSong;
    }
    
    /// Gets the value of the given tag for the given MPD song
    ///
    /// - Parameters:
    ///   - song: The song to get the tag value from
    ///   - tag: The tag to get the value of
    /// - Returns: The string value of the given tag from the given song, nil if the tag was nil
    func tagFrom(song : OpaquePointer, tag : mpd_tag_type) -> String? {
        /// The MPD tag object of `tag` from `song`
        let tagObject = mpd_song_get_tag(song, tag, 0);
        
        // If `tagObject` isn't nil...
        if(tagObject != nil) {
            /// The data from `tagObject`
            let tagData = Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: tagObject!), count: Int(strlen(tagObject)), deallocator: .none);
            
            // Return the string from `tagData`
            return String(data: tagData, encoding: .utf8);
        }
        // If `tagObject` is nil...
        else {
            // Return nil
            return nil;
        }
    }
    
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
    
    init(address : String, port : Int) {
        self.serverAddress = address;
        self.serverPort = port;
    }
    
    deinit {
        // Deinitialize this MPD object
        self.disconnect();
    }
}
