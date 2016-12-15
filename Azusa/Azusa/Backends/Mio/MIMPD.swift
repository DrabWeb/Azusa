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
    private var connection: OpaquePointer? = nil;
    
    /// The connection to MPD for idle events for this object(`mpd_connection`)
    private var idleConnection: OpaquePointer? = nil;
    
    /// The event subscriber for this MPD server
    var eventSubscriber : AZEventSubscriber = AZEventSubscriber();
    
    /// Is this MPD object connected to a server?
    var connected : Bool = false;
    
    /// The default amount of seconds to timeout connections
    private var connectionTimeout : Int = 30;
    
    /// The address of the MPD server this object should connect to
    var serverAddress : String = "127.0.0.1";
    
    /// The port of the MPD server this object should connect to
    var serverPort : Int = 6600;
    
    /// The music directory for this MPD server(used for getting cover art), trailing slash
    var musicDirectory : String = "\(NSHomeDirectory())/Music/";
    
    
    // MARK: - Functions
    
    // MARK: - Connection
    
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
        
        // Open the connections
        self.connection = mpd_connection_new(address, UInt32(port), UInt32(self.connectionTimeout * 1000));
        self.idleConnection = mpd_connection_new(address, UInt32(port), UInt32(self.connectionTimeout * 1000));
        
        // If we tried to connect to the server and it wasn't successful...
        if(mpd_connection_get_error(self.connection) != MPD_ERROR_SUCCESS) {
            AZLogger.log("MIMPD: Error connecting to server at \(address):\(port), \(self.currentErrorMessage())");
            
            // Remove the connection
            self.connection = nil;
            
            // Return that the connection was unsuccessful
            return false;
        }
        
        // If we tried to connect to the server and it wasn't successful...
        if(mpd_connection_get_error(self.idleConnection) != MPD_ERROR_SUCCESS) {
            AZLogger.log("MIMPD: Error connecting to idle server at \(address):\(port), \(self.currentErrorMessage())");
            
            // Remove the connection
            self.idleConnection = nil;
            
            // Return that the connection was unsuccessful
            return false;
        }
        
        AZLogger.log("MIMPD: Connected to \(address):\(port)");
        
        AZLogger.log("MIMPD: Starting event idle thread");
        
        // Start the idle loop on a background queue
        DispatchQueue.global(qos: .background).async {
            self.idleLoop();
        }
        
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
    
    
    // MARK: - Idle Events
    
    /// The while loop for catching idle events from MPD
    func idleLoop() {
        // While `idleConnection` isn't nil...
        while(self.idleConnection != nil) {
            /// The current event from MPD
            let currentEvent : mpd_idle = mpd_run_idle(self.idleConnection!);
            
            // Switch on `currentEvent` and emit the appropriate event
            switch(currentEvent) {
                case MPD_IDLE_UPDATE:
                    self.eventSubscriber.emit(event: .database);
                    break;
                
                case MPD_IDLE_OPTIONS:
                    self.eventSubscriber.emit(event: .options);
                    break;
                
                case MPD_IDLE_PLAYER:
                    self.eventSubscriber.emit(event: .player);
                    break;
                
                case MPD_IDLE_QUEUE:
                    self.eventSubscriber.emit(event: .queue);
                    break;
                
                case MPD_IDLE_MIXER:
                    self.eventSubscriber.emit(event: .volume);
                    break;
                
                default:
                    // For some reason idle "12" is called when the playlist is cleared, not `MPD_IDLE_QUEUE`, so this is the handler for that
                    if(currentEvent.rawValue == UInt32(12)) {
                        self.eventSubscriber.emit(event: .queue);
                    }
                    
                    break;
            }
        }
    }
 
    
    // MARK: - Player
    
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
            status!.playingState = self.playingStateFrom(mpdState: mpd_status_get_state(mpdStatus));
            status!.currentSongPosition = Int(mpd_status_get_song_pos(mpdStatus));
            status!.nextSongPosition = Int(mpd_status_get_next_song_pos(mpdStatus));
            status!.timeElapsed = Int(mpd_status_get_elapsed_time(mpdStatus));
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot retrieve status, connection does not exist(run connect first)");
        }
        
        // Return the player status object
        return status;
    }
    
    /// Sets if this MPD server is paused
    ///
    /// - Parameter pause: The pause state to set(`true` for play, `false` for pause)
    /// - Returns: If the operation was successful
    func setPaused(_ pause : Bool) -> Bool {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Setting paused to \(pause)");
            
            // If there is a current song...
            if let currentSong = mpd_run_current_song(self.connection!) {
                // If the player is stopped...
                if(self.playingStateFrom(mpdState: mpd_status_get_state(mpd_run_status(self.connection!))) == .stopped) {
                    // Start playing the current song
                    return self.seek(to: 0, trackPosition: Int(mpd_song_get_pos(currentSong)));
                }
            }
            // If there isn't a current song...
            else {
                // Play the first song in the queue
                return self.seek(to: 0, trackPosition: 0);
            }
            
            // Say the operation was successful
            return true;
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot set paused, connection does not exist(run connect first)");
            
            // Say the operation was unsuccessful
            return false;
        }
    }
    
    /// Toggles pause for this MPD server
    ///
    /// - Returns: If the operation was successful and the paused state that was set
    func togglePaused() -> (Bool, Bool) {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Toggling pause");
            
            // If there is a current song...
            if let currentSong = mpd_run_current_song(self.connection!) {
                // If the player is stopped...
                if(self.playingStateFrom(mpdState: mpd_status_get_state(mpd_run_status(self.connection!))) == .stopped) {
                    // Start playing the current song
                    return (self.seek(to: 0, trackPosition: Int(mpd_song_get_pos(currentSong))), true);
                }
                
                // Run the toggle pause command and if it fails...
                if(!mpd_run_toggle_pause(self.connection!)) {
                    AZLogger.log("MIMPD: Error toggling pause, \(self.currentErrorMessage())");
                    
                    // Say the operation was unsuccessful
                    return (false, false);
                }
            }
            // If there isn't a current song...
            else {
                // Play the first song in the queue
                return (self.seek(to: 0, trackPosition: 0), true);
            }
            
            // Say the operation was successful, and also get and return the paused state
            return (true, (self.playingStateFrom(mpdState: mpd_status_get_state(mpd_run_status(self.connection!))) == .playing));
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot toggle pause, connection does not exist(run connect first)");
            
            // Say the operation was unsuccessful
            return (false, false);
        }
    }
    
    /// Skips to the previous song
    ///
    /// - Returns: If the operation was successful
    func skipPrevious() -> Bool {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Skipping to the previous song");
            
            // Run the previous command and if it fails...
            if(!mpd_run_previous(self.connection!)) {
                AZLogger.log("MIMPD: Error skipping to the next song, \(self.currentErrorMessage())");
                
                // Say the operation was unsuccessful
                return false;
            }
            
            // Say the operation was successful
            return true;
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot skip to previous song, connection does not exist(run connect first)");
            
            // Say the operation was unsuccessful
            return false;
        }
    }
    
    /// Skips to the next song
    ///
    /// - Returns: If the operation was successful
    func skipNext() -> Bool {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Skipping to the next song");
            
            // Run the previous command and if it fails...
            if(!mpd_run_next(self.connection!)) {
                AZLogger.log("MIMPD: Error skipping to the next song, \(self.currentErrorMessage())");
                
                // Say the operation was unsuccessful
                return false;
            }
            
            // Say the operation was successful
            return true;
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot skip to next song, connection does not exist(run connect first)");
            
            // Say the operation was unsuccessful
            return false;
        }
    }
    
    /// Sets the volume to the given value
    ///
    /// - Parameter to: The value to set the volume to
    /// - Returns: If the operation was successful
    func setVolume(to : Int) -> Bool {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Setting volume to \(to)");
            
            // Run the volume command and if it fails...
            if(!mpd_run_set_volume(self.connection!, UInt32(to))) {
                AZLogger.log("MIMPD: Error setting volume, \(self.currentErrorMessage())");
                
                // Say the operation was unsuccessful
                return false;
            }
            
            // Say the operation was successful
            return true;
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot set volume, connection does not exist(run connect first)");
            
            // Say the operation was unsuccessful
            return false;
        }
    }
    
    /// Returns the elapsed time and duration of the current song in seconds
    ///
    /// - Returns: If the connection was successful and the elapsed time in seconds for the current song
    func getElapsed() -> (Bool, Int) {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Getting elapsed time", level: .full);
            
            // Return that the operation was successful and the elapsed time into the current song
            return (true, Int(mpd_status_get_elapsed_time(mpd_run_status(self.connection!))));
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot retrieve elapsed/duration, connection does not exist(run connect first)");
            
            // Say the operation was unsuccessful
            return (false, 0);
        }
    }
    
    /// Seeks to the given position in seconds in the song at the given queue position
    ///
    /// - Parameter to: The time in seconds to seek to
    /// - Parameter trackPosition: The position of the track in
    /// - Returns: If the operation was successful
    func seek(to : Int, trackPosition : Int) -> Bool {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Seeking to \(AZMusicUtilities.secondsToDisplayTime(to)) in #\(trackPosition)");
            
            // Run the seek command and if it fails...
            if(!mpd_run_seek_pos(self.connection!, UInt32(trackPosition), UInt32(to))) {
                AZLogger.log("MIMPD: Error seeking to \(AZMusicUtilities.secondsToDisplayTime(to)) in #\(trackPosition), \(self.currentErrorMessage())");
                
                // Say the operation was unsuccessful
                return false;
            }
            
            // Say the operation was successful
            return true;
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot seek to \(AZMusicUtilities.secondsToDisplayTime(to)) in #\(trackPosition), connection does not exist(run connect first)");
            
            // Say the operation was unsuccessful
            return false;
        }
    }
    
    /// Seeks to the given position in seconds in the current song
    ///
    /// - Parameter to: The time in seconds to seek to
    /// - Returns: If the operation was successful
    func seek(to : Int) -> Bool {
        // Run `seekTo` with `seconds` and the position of the current song in the queue
        return self.seek(to: to, trackPosition: Int(mpd_status_get_song_pos(mpd_run_status(self.connection!))));
    }
    
    /// Seeks to and plays song at the given index in the queue
    ///
    /// - Parameter at: The position of the song in the queue to play
    /// - Returns: If the operation was successful
    func playSongInQueue(at : Int) -> Bool {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Playing #\(at) in queue");
            
            // Play the song in the queue at `at`, and if it fails...
            if(!mpd_run_play_pos(self.connection, UInt32(at))) {
                AZLogger.log("MIMPD: Error playing #\(at) in queue, \(self.currentErrorMessage())");
                
                // Say the operation was unsuccessful
                return false;
            }
            
            // Say the operation was successful
            return true;
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot play #\(at) in queue, connection does not exist(run connect first)");
            
            // Say the operation was unsuccessful
            return false;
        }
    }
    
    
    // MARK: - Queue
    
    /// Gets all the songs in the current queue and returns them
    ///
    /// - Returns: All the `MISong`s in the current queue
    func getCurrentQueue() -> [MISong] {
        /// The current queue, returned at the end
        var currentQueue : [MISong] = [];
        
        // If the connection isn't nil...
        if(connection != nil) {
            /// The length of the currentQueue
            let currentQueueLength : Int = Int(mpd_status_get_queue_length(mpd_run_status(self.connection!)));
            
            // Send the `"playlistinfo"` command
            mpd_send_list_queue_meta(self.connection!);
            
            // If the queue has at least one song in it...
            if(currentQueueLength > 0) {
                // For every song index in the current queue...
                for _ in 0...(currentQueueLength - 1) {
                    /// The next song from MPD
                    let song = mpd_recv_song(self.connection!);
                    
                    // If the song isn't nil...
                    if(song != nil) {
                        // Add `song` as an `MISong` to `currentQueue`
                        currentQueue.append(self.songFrom(mpdSong: song!));
                    }
                }
            }
            
            // Finish the `"playlistinfo"` command
            mpd_response_finish(self.connection!);
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot retrieve current queue, connection does not exist(run connect first)");
        }
        
        // Return `currentQueue`
        return currentQueue;
    }
    
    /// Gets the current playing song and returns it as an `MISong`(nil if there is none)
    ///
    /// - Returns: The current playing song as an `MISong`(nil if there is none)
    func getCurrentSong() -> MISong? {
        // If the connection isn't nil...
        if(connection != nil) {
            /// The MPD song object for the current song
            let currentSongObject = mpd_run_current_song(self.connection!);
            
            // If `currentSongObject` isn't nil...
            if(currentSongObject != nil) {
                // Return the `MISong` from `currentSongObject`
                return self.songFrom(mpdSong: currentSongObject!);
            }
            // If `currentSongObject` is nil...
            else {
                // Return nil
                return nil;
            }
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot retrieve current song, connection does not exist(run connect first)");
            
            // Return nil
            return nil;
        }
    }
    
    /// Gets the position of the current song in the queue and returns it
    ///
    /// - Returns: The position of the current playing song in the queue, defaults to -1
    func getCurrentSongPosition() -> Int {
        /// The position of the current song in the queue, returned at the end
        var position : Int = -1;
        
        // If the connection isn't nil...
        if(connection != nil) {
            // Get the current song from MPD, and if it's not nil...
            if let currentSong = mpd_run_current_song(self.connection!) {
                // Set `position` to the position of `currentSong` in the queue
                position = Int(mpd_song_get_pos(currentSong));
            }
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot retrieve current song position, connection does not exist(run connect first)");
        }
        
        // Return `position`
        return position;
    }
    
    /// Adds the given array of `MISong`'s to the queue
    ///
    /// - Parameters:
    ///   - songs: The `MISong`s to add to the queue
    ///   - at: The position to insert the songs at(optional)
    /// - Returns: If the operation was successful
    func addToQueue(songs : [MISong], at : Int = -1) -> Bool {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Adding \(songs) to queue at \(((at == -1) ? "end" : "\(at)"))");
            
            /// Was the queue add successful?
            var successful : Bool = true;
            
            // Start the command list for adding song to the queue
            mpd_command_list_begin(self.connection!, true);
            
            // For every song in `songs`(reversed if `at` was set so it stays in the proper order)
            for(_, currentSong) in ((at > -1) ? songs.reversed() : songs).enumerated() {
                // If `at` was set...
                if(at != -1) {
                    // Send the add to queue command, and if it fails...
                    if(!mpd_send_add_id_to(self.connection!, currentSong.uri, UInt32(at))) {
                        AZLogger.log("MIMPD: Error queueing song, \(self.currentErrorMessage())");
                        
                        // Say the operation was unsuccessful
                        successful = false;
                    }
                }
                // If `at` wasn't set...
                else {
                    // Send the add to queue command, and if it fails...
                    if(!mpd_send_add_id(self.connection!, currentSong.uri)) {
                        AZLogger.log("MIMPD: Error queueing song, \(self.currentErrorMessage())");
                        
                        // Say the operation was unsuccessful
                        successful = false;
                    }
                }
            }
            
            // Run the queue add command list
            mpd_command_list_end(self.connection!);
            
            // Run the actual queue add commands, and set `successful` to if it was successful
            successful = mpd_response_finish(self.connection!);
            
            // Return if the queue add was successful
            return successful;
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot add song to queue, connection does not exist(run connect first)");
            
            // Say the operation was unsuccessful
            return false;
        }
    }
    
    /// Removes the given `MISong`s from the current queue
    ///
    /// - Parameter songs: The array of `MISong`s to remove from the queue
    /// - Returns: If the operation was successful
    func removeFromQueue(songs : [MISong]) -> Bool {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Removing \(songs) from the queue");
            
            /// Was the queue add successful?
            var successful : Bool = true;
            
            // Start the command list for deleting songs from the queue
            mpd_command_list_begin(self.connection!, true);
            
            // For every song in `songs`...
            for(_, currentSong) in songs.enumerated() {
                // Send the delete from queue command, and if it fails...
                if(!mpd_send_delete_id(self.connection!, UInt32(currentSong.id))) {
                    AZLogger.log("MIMPD: Error removing song from queue, \(self.currentErrorMessage())");
                    
                    // Say that the queue remove was unsuccessful
                    successful = false;
                }
            }
            
            // Run the queue send delete command list
            mpd_command_list_end(self.connection!);
            
            // Run the actual queue delete commands, and set `successful` to if it was successful
            successful = mpd_response_finish(self.connection!);
            
            // Return if the queue add was successful
            return successful;
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot remove from queue, connection does not exist(run connect first)");
            
            // Say the operation was unsuccessful
            return false;
        }
    }
    
    
    // MARK: - Database
    
    /// Gets the stats of this MPD server
    ///
    /// - Returns: An `MIMPDStats` object that has the current stats of this MPD server
    func getStats() -> MIMPDStats? {
        // If `connection isn't nil`...
        if(self.connection != nil) {
            /// The stats object for `connection`
            let statsObject = mpd_run_stats(self.connection!);
            
            // If `statsObject` is nil...
            if(statsObject == nil) {
                AZLogger.log(self.currentErrorMessage());
                
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
            
            // Return nil
            return nil;
        }
    }
    
    /// Gets all the artists in the MPD database
    ///
    /// - Returns: An array of `AZArtist`s containing all the artists in the MPD database(only the name is set)
    func getAllArtists() -> [AZArtist] {
        /// All the artists in the database, returned at the end
        var artists : [AZArtist] = [];
        
        // If the connection isn't nil...
        if(connection != nil) {
            // For every artist in the user's database...
            for(_, currentArtistName) in self.getAllValues(of: MPD_TAG_ARTIST).enumerated() {
                // Append the current artist name as an `AZArtist` to `artists`
                artists.append(AZArtist(name: currentArtistName));
            }
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot retrieve artists, connection does not exist(run connect first)");
        }
        
        // Return `artists`
        return artists;
    }
    
    /// Gets all the albums in the MPD database
    ///
    /// - Returns: An array of `AZAlbum`s containing all the albums in the MPD database(only the name is set)
    func getAllAlbums() -> [AZAlbum] {
        /// All the albums in the database, returned at the end
        var albums : [AZAlbum] = [];
        
        // If the connection isn't nil...
        if(connection != nil) {
            // For every album in the user's database...
            for(_, currentAlbumName) in self.getAllValues(of: MPD_TAG_ALBUM).enumerated() {
                // Append the current album name as an `AZAlbum` to `albums`
                albums.append(AZAlbum(name: currentAlbumName));
            }
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot retrieve albums, connection does not exist(run connect first)");
        }
        
        // Return `albums`
        return albums;
    }
    
    /// Gets all the genres in the MPD database
    ///
    /// - Returns: An array of `AZGenre`s containing all the genres in the MPD database(only the name is set)
    func getAllGenres() -> [AZGenre] {
        /// All the genres in the database, returned at the end
        var genres : [AZGenre] = [];
        
        // If the connection isn't nil...
        if(connection != nil) {
            // For every genre in the user's database...
            for(_, currentGenreName) in self.getAllValues(of: MPD_TAG_GENRE).enumerated() {
                // Append the current genre name as an `AZGenre` to `genres`
                genres.append(AZGenre(name: currentGenreName));
            }
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot retrieve genres, connection does not exist(run connect first)");
        }
        
        // Return `genres`
        return genres;
    }
    
    /// Gets all the albums for the given artist, also stores the albums in `artist.albums`
    ///
    /// - Parameter artist: The `AZArtist` to get the albums of
    /// - Returns: All the `AZAlbum`s for the given `AZArtist`
    func getAllAlbumsForArtist(artist : AZArtist) -> [AZAlbum] {
        /// The albums to return
        var albums : [AZAlbum] = [];
        
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Getting all albums for \(artist)");
            
            // Create the search, and if it fails...
            if(!mpd_search_db_tags(self.connection!, MPD_TAG_ALBUM)) {
                AZLogger.log("MIMPD: Error setting search, \(self.currentErrorMessage())");
                
                // Return an empty array
                return [];
            }
            
            // Add tag constraint, and if it fails...
            if(!mpd_search_add_tag_constraint(self.connection!, MPD_OPERATOR_DEFAULT, MPD_TAG_ARTIST, artist.name)) {
                AZLogger.log("MIMPD: Error adding search constraint, \(self.currentErrorMessage())");
                
                // Return an empty array
                return [];
            }
            
            // Commit the search, and if it fails...
            if(!mpd_search_commit(self.connection!)) {
                AZLogger.log("MIMPD: Error committing search, \(self.currentErrorMessage())");
                
                // Return an empty array
                return [];
            }
            
            /// The key value pair for the results from MPD
            var resultsKeyValuePair = mpd_recv_pair_tag(self.connection!, MPD_TAG_ALBUM);
            
            // While `resultsKeyValuePair` isn't nil...
            while(resultsKeyValuePair != nil) {
                // Add the current album to `albums`, but only the name for now
                albums.append(AZAlbum(name: String(cString: resultsKeyValuePair!.pointee.value)));
                
                // Free the read tag key value pair from memory
                mpd_return_pair(self.connection!, resultsKeyValuePair);
                
                // Read the next key value pair from the server
                resultsKeyValuePair = mpd_recv_pair_tag(self.connection!, MPD_TAG_ALBUM);
            }
            
            if(mpd_connection_get_error(self.connection!) != MPD_ERROR_SUCCESS || !mpd_response_finish(self.connection)) {
                AZLogger.log(self.currentErrorMessage());
            }
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot get albums for artist, connection does not exist(run connect first)");
        }
        
        // Store `albums` in the artist object's `albums` value
        artist.albums = albums;
        
        // For every album in the fetched albums...
        for(_, currentAlbum) in artist.albums.enumerated() {
            // Search for all the songs of this album
            currentAlbum.songs = self.getAllSongsForAlbum(album: currentAlbum);
            
            // Update the album values to match
            currentAlbum.artist = artist;
            currentAlbum.genre = currentAlbum.songs.first?.genre ?? AZGenre();
            currentAlbum.year = currentAlbum.songs.first?.year ?? -1;
        }
        
        // Return `artist.albums`
        return artist.albums;
    }
    
    /// Gets all the songs for the given album
    ///
    /// - Parameter album: The `AZAlbum` to get the songs of
    /// - Returns: All the `MISong`s for the given `AZAlbum`
    func getAllSongsForAlbum(album : AZAlbum) -> [MISong] {
        /// The songs to return
        var songs : [MISong] = [];
        
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Getting all songs for album \(album)");
            
            // Set `songs` to all the songs that have an album tag equal to the `album`'s name
            songs = self.searchForSongs(album.name, within: MPD_TAG_ALBUM, exact: true);
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot get songs for album, connection does not exist(run connect first)");
        }
        
        // Return `songs`
        return songs;
    }
    
    /// Searches for songs in the database with the given paramaters
    ///
    /// - Parameters:
    ///   - query: The string to search for
    ///   - tags: THe tags to limit the query to, `MPD_TAG_UNKNOWN` is used to denote an any search
    ///   - exact: Should the search use exact matching?
    /// - Returns: The results of the search as an array of `MISong`s
    func searchForSongs(_ query : String, within tag : mpd_tag_type, exact : Bool) -> [MISong] {
        /// All the results of the search
        var results : [MISong] = [];
        
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Searching for songs with query \"\(query)\" within tag \(((tag == MPD_TAG_UNKNOWN) ? "Any" : String(cString: mpd_tag_name(tag)))), exact: \(exact)");
            
            // Create the search, and if it fails...
            if(!mpd_search_db_songs(self.connection!, exact)) {
                AZLogger.log("MIMPD: Error setting search, \(self.currentErrorMessage())");
                
                // Return an empty array
                return [];
            }
            
            // If the search tag is `MPD_TAG_UNKNOWN`(meaning we want to do an any search)...
            if(tag == MPD_TAG_UNKNOWN) {
                // Add a new any search constraint, and if it fails...
                if(!mpd_search_add_any_tag_constraint(self.connection!, MPD_OPERATOR_DEFAULT, query)) {
                    AZLogger.log("MIMPD: Error adding search constraint, \(self.currentErrorMessage())");
                    
                    // Return an empty array
                    return [];
                }
            }
            // If the search tag is not `MPD_TAG_UNKNOWN`...
            else {
                // Add a new search constraint for `tag`, and if it fails...
                if(!mpd_search_add_tag_constraint(self.connection!, MPD_OPERATOR_DEFAULT, tag, query)) {
                    AZLogger.log("MIMPD: Error adding search constraint, \(self.currentErrorMessage())");
                    
                    // Return an empty array
                    return [];
                }
            }
            
            // Commit the search, and if it fails...
            if(!mpd_search_commit(self.connection!)) {
                AZLogger.log("MIMPD: Error committing search, \(self.currentErrorMessage())");
                
                // Return an empty array
                return [];
            }
            
            /// The key value pair for the results from MPD, with name "file" so only search request key value pairs are retrieved
            var resultsKeyValuePair = mpd_recv_pair_named(self.connection!, "file");
            
            // While `resultsKeyValuePair` isn't nil...
            while(resultsKeyValuePair != nil) {
                /// Append the `MISong` from `resultsKeyValuePair` to `results`
                results.append(self.songFrom(mpdSong: mpd_song_begin(resultsKeyValuePair)));
                
                // Free the read tag key value pair from memory
                mpd_return_pair(self.connection!, resultsKeyValuePair);
                
                // Read the next key value pair from the server
                resultsKeyValuePair = mpd_recv_pair_named(self.connection!, "file");
            }
            
            if(mpd_connection_get_error(self.connection!) != MPD_ERROR_SUCCESS || !mpd_response_finish(self.connection)) {
                AZLogger.log(self.currentErrorMessage());
            }
        }
        // If the connection is nil...
        else {
            AZLogger.log("MIMPD: Cannot search for songs, connection does not exist(run connect first)");
        }
        
        // Return the results
        return results;
    }
    
    
    // MARK: - Utilities
    
    /// Returns an `MISong` from the given `mpd_song`
    ///
    /// - Parameter mpdSong: The MPD song to get the `MISong` of
    /// - Returns: The `MISong` of `mpdSong`
    private func songFrom(mpdSong: OpaquePointer) -> MISong {
        /// The song to return
        let returnSong : MISong = MISong();
        
        // Load all the values
        
        /// The URI object of `mpdSong`
        let uriObject = mpd_song_get_uri(mpdSong);
        
        // If `uriObject` isn't nil...
        if(uriObject != nil) {
            /// The data of `uriObject`
            let uriData = Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: uriObject!), count: Int(strlen(uriObject)), deallocator: .none);
            
            // Set `returnSong`'s URI to the string from `uriData`
            returnSong.uri = String(data: uriData, encoding: .utf8) ?? "";
        }
        
        returnSong.id = Int(mpd_song_get_id(mpdSong));
        returnSong.artist = AZArtist(name: self.tagFrom(mpdSong, tag: MPD_TAG_ARTIST) ?? "");
        returnSong.album = AZAlbum(name: self.tagFrom(mpdSong, tag: MPD_TAG_ALBUM) ?? "");
        returnSong.albumArtist = self.tagFrom(mpdSong, tag: MPD_TAG_ALBUM_ARTIST) ?? "";
        returnSong.title = self.tagFrom(mpdSong, tag: MPD_TAG_TITLE) ?? "";
        returnSong.track = Int(NSString(string: self.tagFrom(mpdSong, tag: MPD_TAG_TRACK) ?? "").intValue);
        returnSong.genre = AZGenre(name: self.tagFrom(mpdSong, tag: MPD_TAG_GENRE) ?? "");
        returnSong.year = Int(NSString(string: self.tagFrom(mpdSong, tag: MPD_TAG_DATE) ?? "").intValue);
        returnSong.composer = self.tagFrom(mpdSong, tag: MPD_TAG_COMPOSER) ?? "";
        returnSong.performer = self.tagFrom(mpdSong, tag: MPD_TAG_PERFORMER) ?? "";
        
        returnSong.file = self.musicDirectory + returnSong.uri;
        
        /// The string from the output of the disc metadata, either blank or "#/#"
        let discString = self.tagFrom(mpdSong, tag: MPD_TAG_DISC) ?? "";
        
        if(discString != "" && discString.contains("/")) {
            returnSong.disc = Int(NSString(string: discString.components(separatedBy: "/").first!).intValue);
            returnSong.discCount = Int(NSString(string: discString.components(separatedBy: "/").last!).intValue);
        }
        
        returnSong.duration = Int(mpd_song_get_duration(mpdSong));
        returnSong.position = Int(mpd_song_get_pos(mpdSong));
        
        // Return the song
        return returnSong;
    }
    
    /// Gets the value of the given tag for the given `mpd_song`
    ///
    /// - Parameters:
    ///   - mpdSong: The song to get the tag value from
    ///   - tag: The tag to get the value of
    /// - Returns: The string value of the `tag` tag from `mpdSong`, nil if the tag was nil
    private func tagFrom(_ mpdSong : OpaquePointer, tag : mpd_tag_type) -> String? {
        /// The MPD tag object of `tag` from `mpdSong`
        let tagObject = mpd_song_get_tag(mpdSong, tag, 0);
        
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
    
    /// Returns the `AZPlayingState` from the given `mpd_state`
    ///
    /// - Parameter state: The `mpd_state` to get the `AZPlayingState` of
    /// - Returns: The `AZPlayingState` of `state`
    private func playingStateFrom(mpdState : mpd_state) -> AZPlayingState {
        // Switch and return the appropriate value
        switch(mpdState) {
            case MPD_STATE_PLAY:
                return .playing;
            
            case MPD_STATE_PAUSE:
                return .paused;
            
            case MPD_STATE_STOP, MPD_STATE_UNKNOWN:
                return .stopped;
            
            default:
                return .stopped;
        }
    }
    
    /// Returns all the values of the given tag type in the user's database
    ///
    /// - Parameter tag: The `mpd_tag_type` to get the values of
    /// - Returns: The string of all the values of `tag`
    private func getAllValues(of tag : mpd_tag_type) -> [String] {
        /// All the string values to return
        var values : [String] = [];
        
        // If retrieving all the values for `tag` is unsuccessful...
        if(!mpd_search_db_tags(self.connection!, tag) || !mpd_search_commit(self.connection!)) {
            AZLogger.log("MIMPD: Error retrieving all values for tag \"\(tag)\", \(self.currentErrorMessage())");
            
            // Return an empty array
            return [];
        }
        
        /// The key value pair for the values of `tag`
        var tagKeyValuePair = mpd_recv_pair_tag(self.connection!, tag);
        
        // While `tagKeyValuePair` isn't nil...
        while(tagKeyValuePair != nil) {
            /// The data for the string value of the current tag value
            let stringData : Data = Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: (tagKeyValuePair?.pointee.value)!), count: Int(strlen(tagKeyValuePair?.pointee.value)), deallocator: .none);
            
            // If the string from `stringData` isn't nil...
            if let string = String(data: stringData, encoding: .utf8) {
                // Add the value to `values`
                values.append(string);
            }
            
            // Free the read tag key value pair from memory
            mpd_return_pair(self.connection!, tagKeyValuePair);
            
            // Read the next key value pair from the server
            tagKeyValuePair = mpd_recv_pair_tag(self.connection!, tag);
        }
        
        // Return `values`
        return values;
    }
    
    /// Returns the current error message
    ///
    /// - Returns: The current error message
    private func currentErrorMessage() -> String {
        // If the connection isn't nil...
        if(connection != nil) {
            // Return the current error
            return self.errorMessageFor(connection: self.connection!);
        }
        
        // Default to returning a "No Error Message" message
        return "No Error Message";
    }
    
    /// Returns the error message for the given MPD connection
    ///
    /// - Parameter connection: The `mpd_connection` to get the error from
    /// - Returns: The error message, defaults to `"No Error Message"`
    private func errorMessageFor(connection: OpaquePointer) -> String {
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
    
    
    // MARK: - Initialization and Deinitialization
    
    init(address : String, port : Int, musicDirectory : String) {
        self.serverAddress = address;
        self.serverPort = port;
        self.musicDirectory = musicDirectory;
    }
    
    deinit {
        // Deinitialize this MPD object
        self.disconnect();
    }
}
