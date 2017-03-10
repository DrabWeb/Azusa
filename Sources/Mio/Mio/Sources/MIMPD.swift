//
//  MIMPD.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/7/16.
//

import Foundation
import MPD
import Yui

// TODO: Make `MIMPDError` convertible to `MusicSourceError`

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
public enum MIMPDError: String, Error, CustomStringConvertible {
    public var description: String {
        return rawValue;
    }
    
    case success = "Success"
    case disconnected = "The MIMPD object is not connected to any servers"
    case outOfMemory = "Out of memory"
    case argument = "A function was called with an uncrecognized or invalid argument"
    case state = "A function was called which is not available in the current state of libmpdclient"
    case timeout = "Timeout trying to talk to MPD"
    case system = "System error"
    case resolver = "Unknown host"
    case malformed = "Malformed response received from MPD"
    case connectionClosed = "Connection closed by MPD"
    case serverError = "The server has returned an error code"
    case other = "Error not handled"
}

/// libmpdclient interaction handler in Mio
public class MIMPD {
    // MARK: - Properties
    
    // MARK: Public Properties
    
    /// The event manager for this MPD server
    var eventManager : EventManager = EventManager();
    
    /// Is this MPD object connected to a server?
    var connected : Bool = false;
    
    /// The server info to connect to
    var serverInfo : MIServerInfo = MIServerInfo();
    
    // MARK: Private Properties
    
    /// The connection to MPD for this object(`mpd_connection`)
    private var connection: OpaquePointer? = nil;
    
    /// The connection to MPD for idle events for this object(`mpd_connection`)
    private var idleConnection: OpaquePointer? = nil;
    
    /// The default amount of seconds to timeout connections
    private var connectionTimeout : Int = 30;
    
    
    // MARK: - Functions
    
    // MARK: - Connection
    
    /// Connects to the server set in `serverInfo`
    ///
    /// - Returns: Returns if the connection was successful
    func connect() -> Bool {
        return connect(address: serverInfo.address, port: serverInfo.port);
    }
    
    /// Connects to the server at the given address and port
    ///
    /// - Parameters:
    ///   - address: The address of the server(e.g. `127.0.0.1`)
    ///   - port: The port of the server(e.g. `6600`)
    /// - Returns: If the connection was successful
    private func connect(address : String, port : Int) -> Bool {
        Logger.log("MIMPD: Connecting to \(address):\(port)...");
        
        self.connection = mpd_connection_new(address, UInt32(port), UInt32(self.connectionTimeout * 1000));
        self.idleConnection = mpd_connection_new(address, UInt32(port), UInt32(self.connectionTimeout * 1000));
        
        if mpd_connection_get_error(connection) != MPD_ERROR_SUCCESS {
            Logger.log("MIMPD: Error connecting to server at \(address):\(port), \(self.currentErrorMessage())");
            
            self.connection = nil;
            return false;
        }
        
        if mpd_connection_get_error(idleConnection) != MPD_ERROR_SUCCESS {
            Logger.log("MIMPD: Error connecting to idle server at \(address):\(port), \(self.currentErrorMessage())");
            
            self.idleConnection = nil;
            return false;
        }
        
        Logger.log("MIMPD: Connected to \(address):\(port)");
        Logger.log("MIMPD: Starting event idle thread");
        
        // Idle loops are done in another thread
        DispatchQueue.global(qos: .background).async {
            self.idle();
        }
        
        self.connected = true;
        return true;
    }
    
    /// Disconnects from MPD(if it's connected)
    func disconnect() {
        if self.connection != nil {
            mpd_connection_free(self.connection);
            self.connection = nil;
        }
        
        self.connected = false;
    }
    
    
    // MARK: - Idle Events
    
    /// The while loop for catching idle events from MPD
    private func idle() {
        while self.idleConnection != nil {
            let currentEvent : mpd_idle = mpd_run_idle(self.idleConnection!);
            
            switch currentEvent {
                case MPD_IDLE_UPDATE:
                    eventManager.emit(event: .database);
                    break;
                
                case MPD_IDLE_OPTIONS:
                    eventManager.emit(event: .options);
                    break;
                
                case MPD_IDLE_PLAYER:
                    eventManager.emit(event: .player);
                    break;
                
                case MPD_IDLE_QUEUE:
                    eventManager.emit(event: .queue);
                    break;
                
                case MPD_IDLE_MIXER:
                    eventManager.emit(event: .volume);
                    break;
                
                default:
                    // For some reason idle "12" is called when the playlist is cleared, not `MPD_IDLE_QUEUE`, so this is the handler for that
                    if(currentEvent.rawValue == UInt32(12)) {
                        eventManager.emit(event: .queue);
                    }
                    
                    break;
            }
        }
    }
 
    
    // MARK: - Player
    
    /// Gets the current player status of this MPD server
    ///
    /// - Returns: An `MIPlayerStatus` object representing the current status of this MPD server
    /// - Throws: An `MIMPDError`
    func getPlayerStatus() throws -> MIPlayerStatus {
        if connection != nil {
            let playerStatusObject : MIPlayerStatus = MIPlayerStatus();
            
            do {
                if let status = mpd_run_status(self.connection!) {
                    playerStatusObject.currentSong = try getCurrentSong() ?? MISong.empty;
                    playerStatusObject.volume = Int(mpd_status_get_volume(status));
                    playerStatusObject.isRandom = mpd_status_get_random(status);
                    playerStatusObject.isRepeating = mpd_status_get_repeat(status);
                    playerStatusObject.isSingle = mpd_status_get_single(status);
                    playerStatusObject.isConsuming = mpd_status_get_consume(status);
                    playerStatusObject.queueLength = try getQueueLength();
                    playerStatusObject.playingState = try getPlayingState();
                    playerStatusObject.currentSongPosition = try getCurrentSongPosition();
                    playerStatusObject.nextSongPosition = Int(mpd_status_get_next_song_pos(status));
                    playerStatusObject.timeElapsed = try getElapsed();
                    
                    mpd_status_free(status);
                    return playerStatusObject;
                }
                else {
                    throw self.currentError();
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets the current `PlayingState` of this MPD server
    ///
    /// - Returns: The current `PlayingState`
    /// - Throws: An `MIMPDError`
    func getPlayingState() throws -> PlayingState {
        if(connection != nil) {
            if let status = mpd_run_status(self.connection!) {
                let playingState : PlayingState = self.playingStateFrom(mpdState: mpd_status_get_state(status));
                mpd_status_free(status);
                
                return playingState;
            }
            else {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Sets if this MPD server is paused
    ///
    /// - Parameter pause: The pause state to set(`true` for play, `false` for pause)
    /// - Throws: An `MIMPDError`
    func setPaused(_ pause : Bool) throws {
        if connection != nil {
            Logger.log("MIMPD: \((pause == true) ? "Pausing" : "Playing")");
            
            do {
                if try getCurrentSong() != nil {
                    // Start the song if the player is stopped
                    if try self.getPlayingState() == .stopped {
                        try self.seek(to: 0);
                    }
                    
                    if !mpd_run_pause(self.connection!, pause) {
                        throw self.currentError();
                    }
                }
                else {
                    // Play the first song in the queue if there's no current song
                    try self.seek(to: 0, trackPosition: 0);
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Toggles pause for this MPD server
    ///
    /// - Returns: The paused state that was set
    /// - Throws: An `MIMPDError`
    func togglePaused() throws -> Bool {
        if connection != nil {
            Logger.log("MIMPD: Toggling pause");
            
            do {
                if (try? getCurrentSong()) != nil {
                    // Start playing the current song if stopped
                    if try self.getPlayingState() == .stopped {
                        try self.seek(to: 0, trackPosition: try getCurrentSongPosition());
                    }
                    
                    if !mpd_run_toggle_pause(self.connection!) {
                        throw self.currentError();
                    }
                }
                else {
                    // Play the first song in the queue if there's no current song
                    try self.seek(to: 0, trackPosition: 0);
                }
                
                return try self.getPlayingState() == .playing;
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Stops playback for this MPD server
    ///
    /// - Throws: An `MIMPDError`
    func stop() throws {
        if connection != nil {
            Logger.log("MIMPD: Stopping playback");
            
            if(!mpd_run_stop(self.connection!)) {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Skips to the previous song in the queue
    ///
    /// - Throws: An `MIMPDError`
    func skipPrevious() throws {
        if(connection != nil) {
            Logger.log("MIMPD: Skipping to the previous song");
            
            if !mpd_run_previous(self.connection!) {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Skips to the previous song in the queue while maintaining playing state
    ///
    /// - Throws: An `MIMPDError`
    func skipPreviousAndMaintainPlayingState() throws {
        if connection != nil {
            Logger.log("MIMPD: Skipping to the previous song");
            
            do {
                let playingState : PlayingState = try getPlayingState();
                try self.skipPrevious();
                
                if playingState == .paused {
                    try self.setPaused(true);
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Skips to the next song
    ///
    /// - Throws: An `MIMPDError`
    func skipNext() throws {
        if connection != nil {
            Logger.log("MIMPD: Skipping to the next song");
            
            if !mpd_run_next(self.connection!) {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Skips to the next song in the queue while maintaining playing state
    ///
    /// - Throws: An `MIMPDError`
    func skipNextAndMaintainPlayingState() throws {
        if connection != nil {
            Logger.log("MIMPD: Skipping to the next song");
            
            do {
                let playingState : PlayingState = try getPlayingState();
                try self.skipNext();
                
                if playingState == .paused {
                    try self.setPaused(true);
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        else {
            
            throw MIMPDError.disconnected;
        }
    }
    
    /// Sets the volume to the given value
    ///
    /// - Parameter to: The value to set the volume to
    /// - Throws: An `MIMPDError`
    func setVolume(to : Int) throws {
        if connection != nil {
            Logger.log("MIMPD: Setting volume to \(to)");
            
            if !mpd_run_set_volume(self.connection!, UInt32(to)) {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    // TODO: Make this return the new volume
    /// Adds the given volume to the current volume
    ///
    /// - Parameter to: The value to add to the volume, relative to the current volume(-100 to 100)
    /// - Throws: An `MIMPDError`
    func setRelativeVolume(to : Int) throws {
        if connection != nil {
            Logger.log("MIMPD: Adding \(to) to volume");
            
            if !mpd_run_change_volume(self.connection!, Int32(to)) {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Returns the elapsed time and duration of the current song in seconds
    ///
    /// - Returns: The elapsed time in seconds for the current song
    /// - Throws: An `MIMPDError`
    func getElapsed() throws -> Int {
        if connection != nil {
            Logger.log("MIMPD: Getting elapsed time", level: .full);
            
            if let status = mpd_run_status(self.connection!) {
                let elapsedTime : Int = Int(mpd_status_get_elapsed_time(status));
                mpd_status_free(status);
                
                return elapsedTime;
            }
            else {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Seeks to the given position in seconds in the song at the given queue position
    ///
    /// - Parameter to: The time in seconds to seek to
    /// - Parameter trackPosition: The position of the track in
    /// - Throws: An `MIMPDError`
    func seek(to : Int, trackPosition : Int) throws {
        if connection != nil {
            Logger.log("MIMPD: Seeking to \(MusicUtilities.displayTime(from: to)) in #\(trackPosition)");
            
            // Make sure `trackPosition` is in range of the queue
            if(trackPosition < (try self.getQueueLength()) && trackPosition >= 0) {
                if !mpd_run_seek_pos(self.connection!, UInt32(trackPosition), UInt32(to)) {
                    throw self.currentError();
                }
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Seeks to the given position in seconds in the current song
    ///
    /// - Parameter to: The time in seconds to seek to
    /// - Throws: An `MIMPDError`
    func seek(to : Int) throws {
        do {
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
        if connection != nil {
            Logger.log("MIMPD: Playing #\(at) in queue");
            
            if !mpd_run_play_pos(self.connection, UInt32(at)) {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    func setRepeatMode(to mode : RepeatMode) throws {
        if connection != nil {
            Logger.log("MIMPD: Setting repeat mode to \(mode)");
            
            if !mpd_run_repeat(self.connection!, mode != .none) {
                throw self.currentError();
            }
            if !mpd_run_single(self.connection!, mode == .single) {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    
    // MARK: - Queue
    
    /// Gets all the songs in the current queue and returns them
    ///
    /// - Returns: All the `MISong`s in the current queue
    /// - Throws: An `MIMPDError`
    func getCurrentQueue() throws -> [MISong] {
        if connection != nil {
            var currentQueue : [MISong] = [];
            let currentQueueLength : Int = (try? self.getQueueLength()) ?? 0;
            mpd_send_list_queue_meta(self.connection!);
            
            if currentQueueLength > 0 {
                for _ in 0...(currentQueueLength - 1) {
                    if let song = mpd_recv_song(self.connection!) {
                        currentQueue.append(self.songFrom(mpdSong: song));
                    }
                    else {
                        throw self.currentError();
                    }
                }
            }
            
            mpd_response_finish(self.connection!);
            return currentQueue;
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets the current playing song and returns it as an `MISong`(nil if there is none)
    ///
    /// - Returns: The current playing song as an `MISong`(nil if there is none)
    /// - Throws: An `MIMPDError`
    func getCurrentSong() throws -> MISong? {
        if connection != nil {
            if let currentSong = mpd_run_current_song(self.connection!) {
                return self.songFrom(mpdSong: currentSong);
            }
            else {
                return nil;
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets the position of the current song in the queue and returns it
    ///
    /// - Returns: The position of the current playing song in the queue, defaults to -1 if there's no current song
    /// - Throws: An `MIMPDError`
    func getCurrentSongPosition() throws -> Int {
        if connection != nil {
            if let currentSong = mpd_run_current_song(self.connection!) {
                let position : Int = Int(mpd_song_get_pos(currentSong));
                mpd_song_free(currentSong);
                
                return position;
            }
            else {
                return -1;
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets the length of the current queue and returns it
    ///
    /// - Returns: The length of the current queue, defaults to -1
    /// - Throws: An `MIMPDError`
    func getQueueLength() throws -> Int {
        if connection != nil {
            if let status = mpd_run_status(self.connection!) {
                let length : Int = Int(mpd_status_get_queue_length(status));
                mpd_status_free(status);
                
                return length;
            }
            else {
                throw self.currentError();
            }
        }
        else {
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
        if connection != nil {
            do {
                var moveToPosition : Int = to;
                let queueLength : Int = try self.getQueueLength();
                var movingToEnd : Bool = false;
                
                if to == queueLength {
                    // Subtract one from `moveToPosition` so it moves to the end instead of one over the end(which would cause a crash)
                    moveToPosition = to - 1;
                    movingToEnd = true;
                }
                
                Logger.log("MIMPD: Moving \(queueSongs) to \(moveToPosition)");
                
                var successful : Bool = true;
                mpd_command_list_begin(self.connection!, true);
                
                for (currentIndex, currentSong) in queueSongs.reversed().enumerated() {
                    if !mpd_send_move(self.connection!, UInt32((movingToEnd) ? currentSong.position - currentIndex : currentSong.position + currentIndex), UInt32(moveToPosition)) {
                        throw self.currentError();
                    }
                }
                
                mpd_command_list_end(self.connection!);
                
                // I forget why this only sets if true, but I'm sure there's a reason
                // TODO: See why this is neccessary
                let responseFinishSuccessful : Bool = mpd_response_finish(self.connection!);
                if successful {
                    successful = responseFinishSuccessful;
                }
                
                if !successful {
                    throw self.currentError();
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Moves the given `MISong`s in the queue to after the current song
    ///
    /// - Parameter songs: The array of `MISong`s to move
    /// - Throws: An `MIMPDError`
    func moveAfterCurrent(songs : [MISong]) throws {
        if connection != nil {
            Logger.log("MIMPD: Moving \(songs) to after the current song");
            
            do {
                let currentSongPosition : Int = try self.getCurrentSongPosition();
                
                // Only move if there is a current song
                if currentSongPosition != -1 {
                    try self.move(songs, to: currentSongPosition + 1);
                }
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        else {
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
        if connection != nil {
            Logger.log("MIMPD: Adding \(songs) to queue at \(((at == -1) ? "end" : "\(at)"))");
            
            var successful : Bool = true;
            mpd_command_list_begin(self.connection!, true);
            
            // Reverse `songs` so it stays in proper order
            for (_, currentSong) in ((at > -1) ? songs.reversed() : songs).enumerated() {
                if at != -1 {
                    if !mpd_send_add_id_to(self.connection!, currentSong.uri, UInt32(at)) {
                        throw self.currentError();
                    }
                }
                else {
                    if !mpd_send_add_id(self.connection!, currentSong.uri) {
                        throw self.currentError();
                    }
                }
            }
            
            mpd_command_list_end(self.connection!);
            
            // TODO: Same as above
            let responseFinishSuccessful : Bool = mpd_response_finish(self.connection!);
            if successful {
                successful = responseFinishSuccessful;
            }
            
            if !successful {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Removes the given `MISong`s from the current queue
    ///
    /// - Parameter songs: The array of `MISong`s to remove from the queue
    /// - Throws: An `MIMPDError`
    func removeFromQueue(songs : [MISong]) throws {
        if connection != nil {
            Logger.log("MIMPD: Removing \(songs) from the queue");
            
            var successful : Bool = true;
            mpd_command_list_begin(self.connection!, true);
            
            for (_, currentSong) in songs.enumerated() {
                if(!mpd_send_delete_id(self.connection!, UInt32(currentSong.id))) {
                    throw self.currentError();
                }
            }
            
            // TODO: And once more
            
            let responseFinishSuccessful : Bool = mpd_response_finish(self.connection!);
            if successful {
                successful = responseFinishSuccessful;
            }
            
            if !successful {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Clears the current queue
    ///
    /// - Throws: An `MIMPDError`
    func clearQueue() throws {
        if connection != nil {
            Logger.log("MIMPD: Clearing queue");
            
            if !mpd_run_clear(self.connection!) {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Shuffles the current queue
    ///
    /// - Throws: An `MIMPDError`
    func shuffleQueue() throws {
        if connection != nil {
            Logger.log("MIMPD: Shuffling queue");
            
            if !mpd_run_shuffle(self.connection!) {
                throw self.currentError();
            }
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    
    // MARK: - Database
    
    /// Gets the stats of this MPD server
    ///
    /// - Returns: An `MIStats` object that has the current stats of this MPD server
    /// - Throws: An `MIMPDError`
    func getStats() throws -> MIStats {
        if connection != nil {
            let stats = mpd_run_stats(self.connection!);
            
            if stats == nil {
                throw self.currentError();
            }
            
            let albumCount : Int = Int(mpd_stats_get_number_of_albums(stats));
            let artistCount : Int = Int(mpd_stats_get_number_of_artists(stats));
            let songCount : Int = Int(mpd_stats_get_number_of_songs(stats));
            let databasePlayTime : Int = Int(mpd_stats_get_db_play_time(stats));
            let mpdUptime : Int = Int(mpd_stats_get_uptime(stats));
            let mpdPlayTime : Int = Int(mpd_stats_get_play_time(stats));
            let lastMpdDatabaseUpdateTimestamp : Int = Int(mpd_stats_get_db_update_time(stats));
            
            mpd_stats_free(stats);
            
            return MIStats(albumCount: albumCount,
                               artistCount: artistCount,
                               songCount: songCount,
                               databasePlayTime: databasePlayTime,
                               mpdUptime: mpdUptime,
                               mpdPlayTime: mpdPlayTime,
                               lastMpdDatabaseUpdate: NSDate(timeIntervalSince1970: TimeInterval(lastMpdDatabaseUpdateTimestamp)));
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets all the artists in the MPD database
    ///
    /// - Returns: An array of `Artist`s containing all the artists in the MPD database(only the name is set)
    /// - Throws: An `MIMPDError`
    func getAllArtists() throws -> [Artist] {
        if connection != nil {
            var artists : [Artist] = [];
            
            for (_, currentArtistName) in self.getAllValues(of: MPD_TAG_ARTIST).enumerated() {
                artists.append(Artist(name: currentArtistName));
            }
            
            return artists;
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets all the albums in the MPD database
    ///
    /// - Returns: An array of `Album`s containing all the albums in the MPD database
    /// - Throws: An `MIMPDError`
    func getAllAlbums() throws -> [Album] {
        if connection != nil {
            var albums : [Album] = [];
            
            for (_, currentAlbumName) in self.getAllValues(of: MPD_TAG_ALBUM).enumerated() {
                albums.append(Album(name: currentAlbumName));
                
                do {
                    albums.last!.songs = try getAllSongsFor(album: albums.last!);
                }
                catch let error as MIMPDError {
                    throw error;
                }
            }
            
            return albums;
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets all the genres in the MPD database
    ///
    /// - Returns: An array of `Genre`s containing all the genres in the MPD database(only the name is set)
    /// - Throws: An `MIMPDError`
    func getAllGenres() throws -> [Genre] {
        if connection != nil {
            var genres : [Genre] = [];
            
            for (_, currentGenreName) in self.getAllValues(of: MPD_TAG_GENRE).enumerated() {
                genres.append(Genre(name: currentGenreName));
            }
            
            return genres;
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets all the albums for the given artist, also stores the albums in `artist.albums`
    ///
    /// - Parameter artist: The `Artist` to get the albums of
    /// - Returns: All the `Album`s for the given `Artist`
    /// - Throws: An `MIMPDError`
    func getAllAlbumsFor(artist : Artist) throws -> [Album] {
        if connection != nil {
            Logger.log("MIMPD: Getting all albums for \(artist)");
            
            var albums : [Album] = [];
            
            if !mpd_search_db_tags(self.connection!, MPD_TAG_ALBUM) {
                throw self.currentError();
            }
            
            if !mpd_search_add_tag_constraint(self.connection!, MPD_OPERATOR_DEFAULT, MPD_TAG_ARTIST, artist.name) {
                throw self.currentError();
            }
            
            if !mpd_search_commit(self.connection!) {
                throw self.currentError();
            }
            
            var resultsKeyValuePair = mpd_recv_pair_tag(self.connection!, MPD_TAG_ALBUM);
            
            while resultsKeyValuePair != nil {
                albums.append(Album(name: String(cString: resultsKeyValuePair!.pointee.value)));
                mpd_return_pair(self.connection!, resultsKeyValuePair);
                resultsKeyValuePair = mpd_recv_pair_tag(self.connection!, MPD_TAG_ALBUM);
            }
            
            if mpd_connection_get_error(self.connection!) != MPD_ERROR_SUCCESS || !mpd_response_finish(self.connection) {
                throw self.currentError();
            }
            
            artist.albums = albums;
            
            // TODO: I don't like this very much
            // Thinking like a MusicSource stores fetched stuff or something
            for(_, currentAlbum) in artist.albums.enumerated() {
                do {
                    currentAlbum.songs = try self.getAllSongsFor(album: currentAlbum);
                }
                catch let error as MIMPDError {
                    throw error;
                }
            }
            
            return artist.albums;
        }
        else {
            throw MIMPDError.disconnected;
        }
    }
    
    /// Gets all the songs for the given album
    ///
    /// - Parameter album: The `Album` to get the songs of
    /// - Returns: All the `MISong`s for the given `Album`
    /// - Throws: An `MIMPDError`
    func getAllSongsFor(album : Album) throws -> [MISong] {
        if connection != nil {
            Logger.log("MIMPD: Getting all songs for album \(album)");
            
            do {
                return try self.searchForSongs(with: album.name, within: MPD_TAG_ALBUM, exact: true);
            }
            catch let error as MIMPDError {
                throw error;
            }
        }
        else {
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
        if connection != nil {
            Logger.log("MIMPD: Searching for songs with query \"\(query)\" within tag \(((tag == MPD_TAG_UNKNOWN) ? "Any" : String(cString: mpd_tag_name(tag)))), exact: \(exact)");
            
            var results : [MISong] = [];
            
            if !mpd_search_db_songs(self.connection!, exact) {
                throw self.currentError();
            }
            
            if tag == MPD_TAG_UNKNOWN {
                if !mpd_search_add_any_tag_constraint(self.connection!, MPD_OPERATOR_DEFAULT, query) {
                    throw self.currentError();
                }
            }
            else {
                if !mpd_search_add_tag_constraint(self.connection!, MPD_OPERATOR_DEFAULT, tag, query) {
                    throw self.currentError();
                }
            }
            
            if !mpd_search_commit(self.connection!) {
                throw self.currentError();
            }
            
            var song = mpd_recv_song(self.connection!);
            
            while song != nil {
                results.append(self.songFrom(mpdSong: song!));
                song = mpd_recv_song(self.connection!);
            }
            
            if mpd_connection_get_error(self.connection!) != MPD_ERROR_SUCCESS || !mpd_response_finish(self.connection) {
                throw self.currentError();
            }
            
            return results;
        }
        else {
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
        let returnSong : MISong = MISong();
        
        // Load all the values
        
        let uriObject = mpd_song_get_uri(mpdSong);
        
        if uriObject != nil {
            let uriData = Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: uriObject!), count: Int(strlen(uriObject)), deallocator: .none);
            returnSong.uri = String(data: uriData, encoding: .utf8) ?? "";
        }
        
        returnSong.id = Int(mpd_song_get_id(mpdSong));
        returnSong.artist = Artist(name: tagFrom(mpdSong, tag: MPD_TAG_ARTIST) ?? "");
        returnSong.album = Album(name: tagFrom(mpdSong, tag: MPD_TAG_ALBUM) ?? "");
        returnSong.albumArtist = Artist(name: tagFrom(mpdSong, tag: MPD_TAG_ALBUM_ARTIST) ?? "");
        returnSong.title = tagFrom(mpdSong, tag: MPD_TAG_TITLE) ?? "";
        returnSong.track = Int(NSString(string: tagFrom(mpdSong, tag: MPD_TAG_TRACK) ?? "").intValue);
        returnSong.genre = Genre(name: tagFrom(mpdSong, tag: MPD_TAG_GENRE) ?? "");
        returnSong.year = Int(NSString(string: tagFrom(mpdSong, tag: MPD_TAG_DATE) ?? "").intValue);
        returnSong.composer = tagFrom(mpdSong, tag: MPD_TAG_COMPOSER) ?? "";
        returnSong.performer = tagFrom(mpdSong, tag: MPD_TAG_PERFORMER) ?? "";
        returnSong.file = "\(serverInfo.directory)/\(returnSong.uri)";
        
        /// The string from the output of the disc metadata, either blank or "#/#"
        let discString = self.tagFrom(mpdSong, tag: MPD_TAG_DISC) ?? "";
        
        if discString != "" && discString.contains("/") {
            returnSong.disc = Int(NSString(string: discString.components(separatedBy: "/").first!).intValue);
            returnSong.discCount = Int(NSString(string: discString.components(separatedBy: "/").last!).intValue);
        }
        
        returnSong.duration = Int(mpd_song_get_duration(mpdSong));
        returnSong.position = Int(mpd_song_get_pos(mpdSong));
        
        mpd_song_free(mpdSong);
        
        return returnSong;
    }
    
    /// Gets the value of the given tag for the given `mpd_song`
    ///
    /// - Parameters:
    ///   - mpdSong: The song to get the tag value from
    ///   - tag: The tag to get the value of
    /// - Returns: The string value of the `tag` tag from `mpdSong`, nil if the tag was nil
    private func tagFrom(_ mpdSong : OpaquePointer, tag : mpd_tag_type) -> String? {
        let tagObject = mpd_song_get_tag(mpdSong, tag, 0);
        
        if tagObject != nil {
            let tagData = Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: tagObject!), count: Int(strlen(tagObject)), deallocator: .none);
            return String(data: tagData, encoding: .utf8);
        }
        else {
            return nil;
        }
    }
    
    /// Returns the `PlayingState` from the given `mpd_state`
    ///
    /// - Parameter state: The `mpd_state` to get the `PlayingState` of
    /// - Returns: The `PlayingState` of `state`
    private func playingStateFrom(mpdState : mpd_state) -> PlayingState {
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
        var values : [String] = [];
        
        if !mpd_search_db_tags(self.connection!, tag) || !mpd_search_commit(self.connection!) {
            Logger.log("MIMPD: Error retrieving all values for tag \"\(tag)\", \(self.currentErrorMessage())");
            
            return [];
        }
        
        var tagKeyValuePair = mpd_recv_pair_tag(self.connection!, tag);
        
        while tagKeyValuePair != nil {
            if let string = String(data: Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: (tagKeyValuePair?.pointee.value)!), count: Int(strlen(tagKeyValuePair?.pointee.value)), deallocator: .none), encoding: .utf8) {
                values.append(string);
            }
            
            mpd_return_pair(self.connection!, tagKeyValuePair);
            tagKeyValuePair = mpd_recv_pair_tag(self.connection!, tag);
        }
        
        return values;
    }
    
    /// Returns the current error message
    ///
    /// - Returns: The current error message
    private func currentErrorMessage() -> String {
        if connection != nil {
            return self.errorMessageFor(connection: self.connection!);
        }
        
        return "No Error Message";
    }
    
    /// Returns the current error from MPD
    ///
    /// - Returns: The current `MIMPDError` from MPD
    func currentError() -> MIMPDError {
        var error : MIMPDError = .disconnected;
        
        if self.connection != nil {
            let mpdError : mpd_error = mpd_connection_get_error(self.connection!);
            
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
        
        return error;
    }
    
    /// Returns the error message for the given MPD connection
    ///
    /// - Parameter connection: The `mpd_connection` to get the error from
    /// - Returns: The error message, defaults to `"No Error Message"`
    private func errorMessageFor(connection: OpaquePointer) -> String {
        let error = mpd_connection_get_error_message(connection);
        
        if error != nil {
            if let message = String(data: Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: error!), count: Int(strlen(error!)), deallocator: .none), encoding: .utf8) {
                return message;
            }
        }
        
        return "No Error Message";
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(serverInfo : MIServerInfo) {
        self.serverInfo = serverInfo;
    }
    
    deinit {
        self.disconnect();
    }
}

struct MIServerInfo: CustomStringConvertible {
    var address : String = "127.0.0.1";
    var port : Int = 6600;
    
    /// No trailing slash
    var directory : String = "\(NSHomeDirectory())/Music";
    
    var description: String {
        return "MIServerInfo: \(address):\(port) \(directory)"
    }
    
    init(address : String, port : Int, directory : String) {
        self.address = address;
        self.port = port;
        self.directory = directory;
    }
    
    init() {
        self.address = "127.0.0.1";
        self.port = 6600;
        self.directory = "\(NSHomeDirectory())/Music";
    }
}
