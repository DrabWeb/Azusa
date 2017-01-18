//
//  MIMPD.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/7/16.
//

import Foundation
import MPD

/// The different errors that `MIMPD` can throw
///
/// - Success
/// - disconnected: The `MIMPD` object is not connected to any servers
/// - outOfMemory: Out of memory
/// - argument: A function was called with an uncrecognized or invalid argument
/// - state: A function was called which is not available in the current state of libmpdclient
/// - timeout: Timeout trying to talk to MPD
/// - system: System error
/// - resolver: Unknown host
/// - malformed: Malformed response received from MPD
/// - connectionClosed: Connection closed by MPD
/// - serverError: The server has returned an error code, which can be queried with `mpd_connection_get_server_error()`
/// - other: An error not handled by Mio
enum MIMPDError: Error {
    case success
    case disconnected
    case outOfMemory
    case argument
    case state
    case timeout
    case system
    case resolver
    case malformed
    case connectionClosed
    case serverError
    case other
}

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
            self.idle();
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
    private func idle() {
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
    /// - Returns: An `MIMPDPlayerStatus` object representing the current status of this MPD server
    /// - Throws: An `MIMPDError`
    func getPlayerStatus() throws -> MIMPDPlayerStatus {
        // If the connection isn't nil...
        if(connection != nil) {
            /// The `MIMPDPlayerStatus` object to return
            let playerStatusObject : MIMPDPlayerStatus = MIMPDPlayerStatus();
            
            do {
                // Get the current `mpd_status` from MPD, and if it isn't nil...
                if let mpdStatus = mpd_run_status(self.connection!) {
                    // Set the current song
                    playerStatusObject.currentSong = try self.getCurrentSong() ?? MISong.empty;
                    
                    // Set all the other status values
                    playerStatusObject.volume = Int(mpd_status_get_volume(mpdStatus));
                    playerStatusObject.randomOn = mpd_status_get_random(mpdStatus);
                    playerStatusObject.repeatOn = mpd_status_get_repeat(mpdStatus);
                    playerStatusObject.singleOn = mpd_status_get_single(mpdStatus);
                    playerStatusObject.consumeOn = mpd_status_get_consume(mpdStatus);
                    playerStatusObject.queueLength = Int(mpd_status_get_queue_length(mpdStatus));
                    playerStatusObject.playingState = self.playingStateFrom(mpdState: mpd_status_get_state(mpdStatus));
                    playerStatusObject.currentSongPosition = Int(mpd_status_get_song_pos(mpdStatus));
                    playerStatusObject.nextSongPosition = Int(mpd_status_get_next_song_pos(mpdStatus));
                    playerStatusObject.timeElapsed = Int(mpd_status_get_elapsed_time(mpdStatus));
                    
                    // Free `mpdStatus` from memory
                    mpd_status_free(mpdStatus);
                    
                    // Return `playerStatusObject`
                    return playerStatusObject;
                }
                // If the MPD status is nil...
                else {
                    // Throw the current error
                    throw self.currentError();
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets the current `AZPlayingState` of this MPD server
    ///
    /// - Returns: The current `AZPlayingState`
    /// - Throws: An `MIMPDError`
    func getPlayingState() throws -> AZPlayingState {
        // If the connection isn't nil...
        if(connection != nil) {
            // Get the current status from MPD, and if it isn't nil...
            if let mpdStatus = mpd_run_status(self.connection!) {
                /// The `AZPlayingState` of `mpdStatus`
                let playingState : AZPlayingState = self.playingStateFrom(mpdState: mpd_status_get_state(mpdStatus));
                
                // Free `mpdStatus` from memory
                mpd_status_free(mpdStatus);
                
                // Return `playingState`
                return playingState;
            }
                // If the MPD status is nil...
            else {
                // Throw the current error
                throw self.currentError();
            }
        }
            // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Sets if this MPD server is paused
    ///
    /// - Parameter pause: The pause state to set(`true` for play, `false` for pause)
    /// - Throws: An `MIMPDError`
    func setPaused(_ pause : Bool) throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: \((pause == true) ? "Pausing" : "Playing")");
            
            do {
                // If there is a current song...
                if let currentSong = mpd_run_current_song(self.connection!) {
                    // If the player is stopped...
                    if(try self.getPlayingState() == .stopped) {
                        /// The position of the current track in MPD
                        let trackPosition : Int = Int(mpd_song_get_pos(currentSong));
                        
                        // Free `currentSong` from memory
                        mpd_song_free(currentSong);
                        
                        // Start playing the current song
                        try self.seek(to: 0, trackPosition: trackPosition);
                    }
                    
                    // Set if the player is paused, and if it fails...
                    if(!mpd_run_pause(self.connection!, pause)) {
                        // Throw the current error
                        throw self.currentError();
                    }
                }
                // If there isn't a current song...
                else {
                    // Play the first song in the queue
                    try self.seek(to: 0, trackPosition: 0);
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Toggles pause for this MPD server
    ///
    /// - Returns: The paused state that was set
    /// - Throws: An `MIMPDError`
    func togglePaused() throws -> Bool {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Toggling pause");
            
            do {
                // If there is a current song...
                if((try? getCurrentSong()) != nil) {
                    // If the player is stopped...
                    if(try self.getPlayingState() == .stopped) {
                        // Start playing the current song
                        try self.seek(to: 0, trackPosition: try getCurrentSongPosition());
                    }
                    
                    // Run the toggle pause command and if it fails...
                    if(!mpd_run_toggle_pause(self.connection!)) {
                        // Throw the current error
                        throw self.currentError();
                    }
                }
                // If there isn't a current song...
                else {
                    // Play the first song in the queue
                    try self.seek(to: 0, trackPosition: 0);
                }
                
                // Return if the player is playing
                return try self.getPlayingState() == .playing;
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Stops playback for this MPD server
    ///
    /// - Throws: An `MIMPDError`
    func stop() throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Stopping playback");
            
            // Run the stop command and if it fails...
            if(!mpd_run_stop(self.connection!)) {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Skips to the previous song in the queue
    ///
    /// - Throws: An `MIMPDError`
    func skipPrevious() throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Skipping to the previous song");
            
            // Run the previous command and if it fails...
            if(!mpd_run_previous(self.connection!)) {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Skips to the previous song in the queue while maintaining playing state
    ///
    /// - Throws: An `MIMPDError`
    func skipPreviousAndMaintainPlayingState() throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Skipping to the previous song");
            
            do {
                /// The current playing state of this MPD server
                let playingState : AZPlayingState = try getPlayingState();
                
                // Skip to the previous song
                try self.skipPrevious();
                
                // If the playing state was paused...
                if(playingState == .paused) {
                    // Keep the song paused
                    try self.setPaused(true);
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Skips to the next song
    ///
    /// - Throws: An `MIMPDError`
    func skipNext() throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Skipping to the next song");
            
            // Run the previous command and if it fails...
            if(!mpd_run_next(self.connection!)) {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Skips to the next song in the queue while maintaining playing state
    ///
    /// - Throws: An `MIMPDError`
    func skipNextAndMaintainPlayingState() throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Skipping to the next song");
            
            do {
                /// The current playing state of this MPD server
                let playingState : AZPlayingState = try getPlayingState();
                
                // Skip to the next song
                try self.skipNext();
                
                // If the playing state was paused...
                if(playingState == .paused) {
                    // Keep the song paused
                    try self.setPaused(true);
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Sets the volume to the given value
    ///
    /// - Parameter to: The value to set the volume to
    /// - Throws: An `MIMPDError`
    func setVolume(to : Int) throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Setting volume to \(to)");
            
            // Run the volume command and if it fails...
            if(!mpd_run_set_volume(self.connection!, UInt32(to))) {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Adds the given volume to the current volume
    ///
    /// - Parameter to: The value to add to the volume, relative to the current volume(-100 to 100)
    /// - Throws: An `MIMPDError`
    func setRelativeVolume(to : Int) throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Adding \(to) to volume");
            
            // Run the volume command and if it fails...
            if(!mpd_run_change_volume(self.connection!, Int32(to))) {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Returns the elapsed time and duration of the current song in seconds
    ///
    /// - Returns: The elapsed time in seconds for the current song
    /// - Throws: An `MIMPDError`
    func getElapsed() throws -> Int {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Getting elapsed time", level: .full);
            
            // Get the current status from MPD, and if it isn't nil...
            if let mpdStatus = mpd_run_status(self.connection!) {
                /// The elapsed time into the current song
                let elapsedTime : Int = Int(mpd_status_get_elapsed_time(mpdStatus));
                
                // Free `mpdStatus` from memory
                mpd_status_free(mpdStatus);
                
                // Return `elapsedTime`
                return elapsedTime;
            }
            // If the MPD status is nil...
            else {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Seeks to the given position in seconds in the song at the given queue position
    ///
    /// - Parameter to: The time in seconds to seek to
    /// - Parameter trackPosition: The position of the track in
    /// - Throws: An `MIMPDError`
    func seek(to : Int, trackPosition : Int) throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Seeking to \(AZMusicUtilities.secondsToDisplayTime(to)) in #\(trackPosition)");
            
            // If `to` is in range of the queue...
            if(trackPosition < (try self.getQueueLength()) && trackPosition >= 0) {
                // Run the seek command and if it fails...
                if(!mpd_run_seek_pos(self.connection!, UInt32(trackPosition), UInt32(to))) {
                    // Throw the current error
                    throw self.currentError();
                }
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Seeks to the given position in seconds in the current song
    ///
    /// - Parameter to: The time in seconds to seek to
    /// - Throws: An `MIMPDError`
    func seek(to : Int) throws {
        do {
            // Run `seekTo` with `seconds` and the position of the current song in the queue
            try self.seek(to: to, trackPosition: try self.getCurrentSongPosition());
        }
        catch let error as MIMPDError {
            throw error;
        }
    }
    
    /// Seeks to and plays song at the given index in the queue
    ///
    /// - Parameter at: The position of the song in the queue to play
    /// - Throws: An `MIMPDError`
    func playSongInQueue(at : Int) throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Playing #\(at) in queue");
            
            // Play the song in the queue at `at`, and if it fails...
            if(!mpd_run_play_pos(self.connection, UInt32(at))) {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    
    // MARK: - Queue
    
    /// Gets all the songs in the current queue and returns them
    ///
    /// - Returns: All the `MISong`s in the current queue
    /// - Throws: An `MIMPDError`
    func getCurrentQueue() throws -> [MISong] {
        // If the connection isn't nil...
        if(connection != nil) {
            /// The current queue, returned at the end
            var currentQueue : [MISong] = [];
            
            /// The length of the currentQueue
            let currentQueueLength : Int = (try? self.getQueueLength()) ?? 0;
            
            // Send the `"playlistinfo"` command
            mpd_send_list_queue_meta(self.connection!);
            
            // If the queue has at least one song in it...
            if(currentQueueLength > 0) {
                // For every song index in the current queue...
                for _ in 0...(currentQueueLength - 1) {
                    // Get the current song in the iteration, and if it isn't nil...
                    if let song = mpd_recv_song(self.connection!) {
                        // Add `song` as an `MISong` to `currentQueue`
                        currentQueue.append(self.songFrom(mpdSong: song));
                    }
                    // If the song is nil...
                    else {
                        // Throw the current error
                        throw self.currentError();
                    }
                }
            }
          
            // Finish the `"playlistinfo"` command
            mpd_response_finish(self.connection!);
            
            // Return `currentQueue`
            return currentQueue;
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets the current playing song and returns it as an `MISong`(nil if there is none)
    ///
    /// - Returns: The current playing song as an `MISong`(nil if there is none)
    /// - Throws: An `MIMPDError`
    func getCurrentSong() throws -> MISong? {
        // If the connection isn't nil...
        if(connection != nil) {
            // If the current song from MPD isn't nil...
            if let currentSongObject = mpd_run_current_song(self.connection!) {
                // Return the `MISong` from `currentSongObject`
                return self.songFrom(mpdSong: currentSongObject);
            }
            // If the current song from MPD is nil...
            else {
                // Return nil
                return nil;
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets the position of the current song in the queue and returns it
    ///
    /// - Returns: The position of the current playing song in the queue, defaults to -1
    /// - Throws: An `MIMPDError`
    func getCurrentSongPosition() throws -> Int {
        // If the connection isn't nil...
        if(connection != nil) {
            // Get the current song from MPD, and if it's not nil...
            if let currentSong = mpd_run_current_song(self.connection!) {
                /// The position of the current song in the queue, returned at the end
                let position : Int = Int(mpd_song_get_pos(currentSong));
                
                // Free `currentSong` from memory
                mpd_song_free(currentSong);
                
                // Return `position`
                return position;
            }
            // If the current song is nil...
            else {
                // Return -1 to say there is no current song
                return -1;
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets the length of the current queue and returns it
    ///
    /// - Returns: The length of the current queue, defaults to -1
    /// - Throws: An `MIMPDError`
    func getQueueLength() throws -> Int {
        // If the connection isn't nil...
        if(connection != nil) {
            // Get the current status from MPD, and if it isn't nil...
            if let mpdStatus = mpd_run_status(self.connection!) {
                /// The length of the queue, returned
                let length : Int = Int(mpd_status_get_queue_length(mpdStatus));
                
                // Free `mpdStatus` from memory
                mpd_status_free(mpdStatus);
                
                // Return `length`
                return length;
            }
            // If the MPD status is nil...
            else {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Moves the given `MISong`s in the queue to `to`
    ///
    /// - Parameters:
    ///   - queueSongs: The `MISong`s in the queue to move
    ///   - to: The index in the queue to move them to
    /// - Throws: An `MIMPDError`
    func move(_ queueSongs : [MISong], to : Int) throws {
        // If the connection isn't nil...
        if(connection != nil) {
            do {
                /// The position to move the songs to
                var moveToPosition : Int = to;
                
                /// The length of the current queue
                let queueLength : Int = try self.getQueueLength();
                
                /// Are we moving the songs to the end of the queue?
                var movingToEnd : Bool = false;
                
                // If we are moving the songs to the end of the queue...
                if(to == queueLength) {
                    // Subtract one from `moveToPosition` so it moves to the end instead of one over the end(which would cause a crash)
                    moveToPosition = to - 1;
                    
                    // Set `movingToEnd`
                    movingToEnd = true;
                }
                
                AZLogger.log("MIMPD: Moving \(queueSongs) to \(moveToPosition)");
                
                /// Was the queue add successful?
                var successful : Bool = true;
                
                // Start the command list for moving the songs
                mpd_command_list_begin(self.connection!, true);
                
                // For every song in `songs`(reversed so it stays in the proper order)
                for(currentIndex, currentSong) in queueSongs.reversed().enumerated() {
                    // Send the move command, and if it fails...
                    if(!mpd_send_move(self.connection!, UInt32((movingToEnd) ? currentSong.position - currentIndex : currentSong.position + currentIndex), UInt32(moveToPosition))) {
                        // Throw the current error
                        throw self.currentError();
                    }
                }
                
                // Run the move command list
                mpd_command_list_end(self.connection!);
                
                // Run the actual move commands, and set `successful` to if it was successful
                /// If `mpd_response_finish` was successful
                let responseFinishSuccessful : Bool = mpd_response_finish(self.connection!);
                
                // Set `successful` to `responseFinishSuccessful`, but only if `successful` is true
                if(successful) {
                    successful = responseFinishSuccessful;
                }
                
                // If the operation was unsuccessful...
                if(!successful) {
                    // Throw the current error
                    throw self.currentError();
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Moves the given `MISong`s in the queue to after the current song
    ///
    /// - Parameter songs: The array of `MISong`s to move
    /// - Throws: An `MIMPDError`
    func moveAfterCurrent(songs : [MISong]) throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Moving \(songs) to after the current song");
            
            do {
                /// The position of the current song in the queue
                let currentSongPosition : Int = try self.getCurrentSongPosition();
                
                // If `currentSongPosition` isn't -1(meaning there is a current song)...
                if(currentSongPosition != -1) {
                    // Call the move function with the current song position and `songs`
                    try self.move(songs, to: currentSongPosition + 1);
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Adds the given array of `MISong`'s to the queue
    ///
    /// - Parameters:
    ///   - songs: The `MISong`s to add to the queue
    ///   - at: The position to insert the songs at(optional)
    /// - Throws: An `MIMPDError`
    func addToQueue(songs : [MISong], at : Int = -1) throws {
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
                        // Throw the current error
                        throw self.currentError();
                    }
                }
                // If `at` wasn't set...
                else {
                    // Send the add to queue command, and if it fails...
                    if(!mpd_send_add_id(self.connection!, currentSong.uri)) {
                        // Throw the current error
                        throw self.currentError();
                    }
                }
            }
            
            // Run the queue add command list
            mpd_command_list_end(self.connection!);
            
            // Run the actual queue add commands, and set `successful` to if it was successful
            /// If `mpd_response_finish` was successful
            let responseFinishSuccessful : Bool = mpd_response_finish(self.connection!);
            
            // Set `successful` to `responseFinishSuccessful`, but only if `successful` is true
            if(successful) {
                successful = responseFinishSuccessful;
            }
            
            // If the operation was unsuccessful...
            if(!successful) {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Removes the given `MISong`s from the current queue
    ///
    /// - Parameter songs: The array of `MISong`s to remove from the queue
    /// - Throws: An `MIMPDError`
    func removeFromQueue(songs : [MISong]) throws {
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
                    // Throw the current error
                    throw self.currentError();
                }
            }
            
            // Run the actual queue delete commands, and set `successful` to if it was successful
            /// If `mpd_response_finish` was successful
            let responseFinishSuccessful : Bool = mpd_response_finish(self.connection!);
            
            // Set `successful` to `responseFinishSuccessful`, but only if `successful` is true
            if(successful) {
                successful = responseFinishSuccessful;
            }
            
            // If the operation was unsuccessful...
            if(!successful) {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Clears the current queue
    ///
    /// - Throws: An `MIMPDError`
    func clearQueue() throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Clearing queue");
            
            // Call the clear command, and if it's unsuccessful...
            if(!mpd_run_clear(self.connection!)) {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Shuffles the current queue
    ///
    /// - Throws: An `MIMPDError`
    func shuffleQueue() throws {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Shuffling queue");
            
            // Call the shuffle command, and if it's unsuccessful...
            if(!mpd_run_shuffle(self.connection!)) {
                // Throw the current error
                throw self.currentError();
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    
    // MARK: - Database
    
    /// Gets the stats of this MPD server
    ///
    /// - Returns: An `MIMPDStats` object that has the current stats of this MPD server
    /// - Throws: An `MIMPDError`
    func getStats() throws -> MIMPDStats {
        // If `connection isn't nil`...
        if(self.connection != nil) {
            /// The stats object for `connection`
            let statsObject = mpd_run_stats(self.connection!);
            
            // If `statsObject` is nil...
            if(statsObject == nil) {
                // Throw the current error
                throw self.currentError();
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
            
            // Free `statsObject` from memory
            mpd_stats_free(statsObject);
            
            // Return an MIMPDStats object with the retrieved values
            return MIMPDStats(albumCount: albumCount,
                               artistCount: artistCount,
                               songCount: songCount,
                               databasePlayTime: databasePlayTime,
                               mpdUptime: mpdUptime,
                               mpdPlayTime: mpdPlayTime,
                               lastMpdDatabaseUpdate: NSDate(timeIntervalSince1970: TimeInterval(lastMpdDatabaseUpdate)));
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets all the artists in the MPD database
    ///
    /// - Returns: An array of `AZArtist`s containing all the artists in the MPD database(only the name is set)
    /// - Throws: An `MIMPDError`
    func getAllArtists() throws -> [AZArtist] {
        // If the connection isn't nil...
        if(connection != nil) {
            /// All the artists in the database, returned
            var artists : [AZArtist] = [];
            
            // For every artist in the user's database...
            for(_, currentArtistName) in self.getAllValues(of: MPD_TAG_ARTIST).enumerated() {
                // Append the current artist name as an `AZArtist` to `artists`
                artists.append(AZArtist(name: currentArtistName));
            }
            
            // Return `artists`
            return artists;
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets all the albums in the MPD database
    ///
    /// - Returns: An array of `AZAlbum`s containing all the albums in the MPD database
    /// - Throws: An `MIMPDError`
    func getAllAlbums() throws -> [AZAlbum] {
        // If the connection isn't nil...
        if(connection != nil) {
            /// All the albums in the database, returned
            var albums : [AZAlbum] = [];
            
            // For every album in the user's database...
            for(_, currentAlbumName) in self.getAllValues(of: MPD_TAG_ALBUM).enumerated() {
                // Append the current album name as an `AZAlbum` to `albums`
                albums.append(AZAlbum(name: currentAlbumName));
                
                do {
                    // Get all the songs for the album
                    albums.last!.songs = try self.getAllSongsFor(album: albums.last!);
                }
                catch let error as MIMPDError {
                    throw error;
                }
            }
            
            // Return `albums`
            return albums;
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets all the genres in the MPD database
    ///
    /// - Returns: An array of `AZGenre`s containing all the genres in the MPD database(only the name is set)
    /// - Throws: An `MIMPDError`
    func getAllGenres() throws -> [AZGenre] {
        // If the connection isn't nil...
        if(connection != nil) {
            /// All the genres in the database, returned
            var genres : [AZGenre] = [];
            
            // For every genre in the user's database...
            for(_, currentGenreName) in self.getAllValues(of: MPD_TAG_GENRE).enumerated() {
                // Append the current genre name as an `AZGenre` to `genres`
                genres.append(AZGenre(name: currentGenreName));
            }
            
            // Return `genres`
            return genres;
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets all the albums for the given artist, also stores the albums in `artist.albums`
    ///
    /// - Parameter artist: The `AZArtist` to get the albums of
    /// - Returns: All the `AZAlbum`s for the given `AZArtist`
    /// - Throws: An `MIMPDError`
    func getAllAlbumsFor(artist : AZArtist) throws -> [AZAlbum] {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Getting all albums for \(artist)");
            
            /// The albums to return
            var albums : [AZAlbum] = [];
            
            // Create the search, and if it fails...
            if(!mpd_search_db_tags(self.connection!, MPD_TAG_ALBUM)) {
                // Throw the current error
                throw self.currentError();
            }
            
            // Add tag constraint, and if it fails...
            if(!mpd_search_add_tag_constraint(self.connection!, MPD_OPERATOR_DEFAULT, MPD_TAG_ARTIST, artist.name)) {
                // Throw the current error
                throw self.currentError();
            }
            
            // Commit the search, and if it fails...
            if(!mpd_search_commit(self.connection!)) {
                // Throw the current error
                throw self.currentError();
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
            
            // If there was any errors...
            if(mpd_connection_get_error(self.connection!) != MPD_ERROR_SUCCESS || !mpd_response_finish(self.connection)) {
                // Throw the current error
                throw self.currentError();
            }
            
            // Store `albums` in the artist object's `albums` value
            artist.albums = albums;
            
            // For every album in the fetched albums...
            for(_, currentAlbum) in artist.albums.enumerated() {
                do {
                    // Search for all the songs of this album
                    currentAlbum.songs = try self.getAllSongsFor(album: currentAlbum);
                }
                catch let error as MIMPDError {
                    throw error;
                }
            }
            
            // Return `artist.albums`
            return artist.albums;
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets all the songs for the given album
    ///
    /// - Parameter album: The `AZAlbum` to get the songs of
    /// - Returns: All the `MISong`s for the given `AZAlbum`
    /// - Throws: An `MIMPDError`
    func getAllSongsFor(album : AZAlbum) throws -> [MISong] {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Getting all songs for album \(album)");
            
            do {
                // Return all the songs that have an album tag equal to the `album`'s name
                return try self.searchForSongs(with: album.name, within: MPD_TAG_ALBUM, exact: true);
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    /// Searches for songs in the database with the given paramaters
    ///
    /// - Parameters:
    ///   - query: The string to search for
    ///   - tags: The tags to limit the query to, `MPD_TAG_UNKNOWN` is used to denote an any search
    ///   - exact: Should the search use exact matching?
    /// - Returns: The results of the search as an array of `MISong`s
    /// - Throws: An `MIMPDError`
    func searchForSongs(with query : String, within tag : mpd_tag_type, exact : Bool) throws -> [MISong] {
        // If the connection isn't nil...
        if(connection != nil) {
            AZLogger.log("MIMPD: Searching for songs with query \"\(query)\" within tag \(((tag == MPD_TAG_UNKNOWN) ? "Any" : String(cString: mpd_tag_name(tag)))), exact: \(exact)");
            
            /// All the results of the search
            var results : [MISong] = [];
            
            // Create the search, and if it fails...
            if(!mpd_search_db_songs(self.connection!, exact)) {
                // Throw the current error
                throw self.currentError();
            }
            
            // If the search tag is `MPD_TAG_UNKNOWN`(meaning we want to do an any search)...
            if(tag == MPD_TAG_UNKNOWN) {
                // Add a new any search constraint, and if it fails...
                if(!mpd_search_add_any_tag_constraint(self.connection!, MPD_OPERATOR_DEFAULT, query)) {
                    // Throw the current error
                    throw self.currentError();
                }
            }
            // If the search tag is not `MPD_TAG_UNKNOWN`...
            else {
                // Add a new search constraint for `tag`, and if it fails...
                if(!mpd_search_add_tag_constraint(self.connection!, MPD_OPERATOR_DEFAULT, tag, query)) {
                    // Throw the current error
                    throw self.currentError();
                }
            }
            
            // Commit the search, and if it fails...
            if(!mpd_search_commit(self.connection!)) {
                // Throw the current error
                throw self.currentError();
            }
            
            /// The key value pair for the results from MPD, with name "file" so only search request key value pairs are retrieved
            var song = mpd_recv_song(self.connection!);
            
            // While `resultsKeyValuePair` isn't nil...
            while(song != nil) {
                /// Append the `MISong` from `song` to `results`
                results.append(self.songFrom(mpdSong: song!));
                
                // Read the next song from the server
                song = mpd_recv_song(self.connection!);
            }
            
            // If there was any errors...
            if(mpd_connection_get_error(self.connection!) != MPD_ERROR_SUCCESS || !mpd_response_finish(self.connection)) {
                // Throw the current error
                throw self.currentError();
            }
            
            // Return the results
            return results;
        }
        // If the connection is nil...
        else {
            // Throw a disconnected error
            throw MIMPDError.disconnected;
        }
    }
    
    
    // MARK: - Utilities
    
    /// Returns an `MISong` from the given `mpd_song`
    /// Automatically frees the given `mpd_song` from memory after usage
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
        
        // Free the `mpd_song` from memory, we no longer need it
        mpd_song_free(mpdSong);
        
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
    
    /// Returns the current error from MPD
    ///
    /// - Returns: The current `MIMPDError` from MPD
    func currentError() -> MIMPDError {
        /// The current error, returned
        var error : MIMPDError = .disconnected;
        
        // If `connection` isn't nil...
        if(self.connection != nil) {
            /// The MPD error from `connection`
            let mpdError : mpd_error = mpd_connection_get_error(self.connection!);
            
            // Switch on `mpdError` and set `error` accordingly
            switch mpdError {
                case MPD_ERROR_SUCCESS:
                    error = .success;
                    break;
                
                case MPD_ERROR_OOM:
                    error = .outOfMemory;
                    break;
                
                case MPD_ERROR_ARGUMENT:
                    error = .argument;
                    break;
                
                case MPD_ERROR_STATE:
                    error = .state;
                    break;
                
                case MPD_ERROR_TIMEOUT:
                    error = .timeout;
                    break;
                
                case MPD_ERROR_SYSTEM:
                    error = .system;
                    break;
                
                case MPD_ERROR_RESOLVER:
                    error = .resolver;
                    break;
                
                case MPD_ERROR_MALFORMED:
                    error = .malformed;
                    break;
                
                case MPD_ERROR_CLOSED:
                    error = .connectionClosed;
                    break;
                
                case MPD_ERROR_SERVER:
                    error = .serverError;
                    break;
                
                default:
                    error = .other;
                    break;
            }
        }
        
        // Return `error`
        return error;
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
