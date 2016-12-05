//
//  MIMPD.swift
//  Azusa.Mio
//
//  Created by Ushio on 11/24/16.
//

import Foundation
import CocoaAsyncSocket

/// The different types of looping available
enum MILoopMode : Int {
    case off = 0
    case playlist = 1
    case song = 2
}

/// The class for talking to an MPD server
class MIMPD {
    
    // Variables
    
    /// The address of this MPD server
    var serverAddress : String = "127.0.0.1";
    
    /// The port of this MPD server
    var serverPort : Int = 6600;
    
    /// The base music directory of this MPD server, append with a slash
    var musicDirectory : String = "";
    
    /// The TCP socket connection to this MPD server
    var socketConnection : MITCPCommunications = MITCPCommunications();
    
    /// The last received status object
    var status : MIStatus? = nil;
    
    
    // Functions
    
    /// Jumps to the song at the given index in the current playlist
    func jumpToSongInPlaylist(at : Int, log : Bool, completionHandler : (() -> ())?) {
        if(log) {
            AZLogger.log("MIMPD: Jumping to #\(at) in current playlist");
        }
        
        // Jump to the given song index
        self.socketConnection.run(command: "seek \(at) 0", log: false, completionHandler: {
            // Make sure the song is unpaused, and call the completion handler afterwards
            self.setPaused(to: false, completionHandler: completionHandler);
        });
    }
    
    /// Gets the current playlist as an array of MISongs, calls the completion handler with said array, logs the command if 'log' is true
    func getPlaylist(log : Bool, completionHandler : (([MISong]) -> ())?) {
        if(log) {
            AZLogger.log("MIMPD: Getting current playlist");
        }
        
        // Call and get the output of the playlistinfo command
        self.socketConnection.outputOf(command: "playlistinfo", log: log, completionHandler: { output in
            // Call the completion handler with the MISongs created from output
            completionHandler?(MISong.from(songList: output));
        });
    }
    
    /// Gets the current MIStatus object and calls the given completion handler with it, logs the command if 'log' is true
    func getStatus(log : Bool, completionHandler : ((MIStatus) -> ())?) {
        if(log) {
            AZLogger.log("MIMPD: Getting current status");
        }
        
        // Call and get the output of the status command
        self.socketConnection.outputOf(command: "status", log: log, completionHandler: { output in
            /// The MIStatus created from 'output'
            let status : MIStatus = MIStatus(string: output);
            
            // Set status
            self.status = status;
            
            // Call the completion handler with the status object
            completionHandler?(status);
        });
    }
    
    /// Seeks to the given time in the current song(in seconds), optional completion handler for when the command finishes(passed command output)
    func seek(to : Int, completionHandler : (() -> ())?) {
        AZLogger.log("MIMPD: Seeking to \(MIUtilities.secondsToDisplayTime(to))");
        
        // Seek to the given time
        self.socketConnection.run(command: "seekcur \(to)", log: false, completionHandler: completionHandler);
    }
    
    /// Skips to the previous song in the playlist, optional completion handler for when the command finishes(passed command output)
    func skipPrevious(completionHandler : (() -> ())?) {
        AZLogger.log("MIMPD: Skipping to the previous song");
        
        // Skip to the next song
        self.socketConnection.run(command: "previous", log: false, completionHandler: completionHandler);
    }
    
    /// Skips to the next song in the playlist, optional completion handler for when the command finishes(passed command output)
    func skipNext(completionHandler : (() -> ())?) {
        AZLogger.log("MIMPD: Skipping to the next song");
        
        // Skip to the next song
        self.socketConnection.run(command: "next", log: false, completionHandler: completionHandler);
    }
    
    /// Toggles pause based on 'to', optional completion handler for when the command finishes(passed command output)
    func setPaused(to : Bool, completionHandler : (() -> ())?) {
        switch(to) {
            case true:
                AZLogger.log("MIMPD: Pausing song");
                break;
            
            case false:
                AZLogger.log("MIMPD: Playing song");
                break;
        }
        
        self.getStatus(log: false, completionHandler: { status in
            if(status.playingState == .stop && status.currentSongId != -1) {
                // Play the song
                self.socketConnection.run(command: "playid \(status.currentSongId)", log: false, completionHandler: completionHandler);
            }
            else {
                // Set the pause accordingly
                self.socketConnection.run(command: "pause \((to) ? 1 : 0)", log: false, completionHandler: completionHandler);
            }
        });
    }
    
    /// Toggles random mode based on 'to', optional completion handler for when the command finishes(passed command output)
    func setRandomMode(to : Bool, completionHandler : (() -> ())?) {
        switch(to) {
            case true:
                AZLogger.log("MIMPD: Enabling random");
                break;
            
            case false:
                AZLogger.log("MIMPD: Disabling random");
                break;
        }
        
        // Set the random mode accordingly
        self.socketConnection.run(command: "random \((to) ? 1 : 0)", log: false, completionHandler: completionHandler);
    }
    
    /// Sets the loop mode to the given loop mode, calls the given completion handler when the command returns(if given)
    func setLoopMode(to : MILoopMode, completionHandler : (() -> ())?) {
        // Set the loop mode accordingly
        if(to == .off) {
            self.socketConnection.run(command: "command_list_begin\nrepeat 0\nsingle 0\ncommand_list_end", log: false, completionHandler: completionHandler);
            
            AZLogger.log("MIMPD: Disabling repeat");
        }
        else if(to == .playlist) {
            self.socketConnection.run(command: "command_list_begin\nrepeat 1\nsingle 0\ncommand_list_end", log: false, completionHandler: completionHandler);
            
            AZLogger.log("MIMPD: Setting repeat mode to playlist");
        }
        else if(to == .song) {
            self.socketConnection.run(command: "command_list_begin\nrepeat 1\nsingle 1\ncommand_list_end", log: false, completionHandler: completionHandler);
            
            AZLogger.log("MIMPD: Setting repeat mode to single");
        }
    }
    
    /// Calls the completion handler with the current song and status at the same time
    func getCurrentSongAndStatus(completionHandler : @escaping ((MISong, MIStatus) -> ())) {
        /// Get the output of status and currentsong
        self.socketConnection.outputOf(command: "command_list_begin\nstatus\ncurrentsong\ncommand_list_end", log: true, completionHandler: { output in
            /// The MISong created from 'output'
            var song : MISong = MISong(string: output);
            
            /// The MIStatus created from 'output'
            let status : MIStatus = MIStatus(string: output);
            
            // Set status
            self.status = status;
            
            // If the song is valid...
            if(song.valid) {
                // Update the song's file
                song.file = self.musicDirectory + song.file;
                
                // Call the completion handler
                completionHandler(song, status);
            }
            // If the song is invalid...
            else {
                // Set 'song' to the placeholder song
                song = MISong.placeholder();
                
                // Call the completion handler
                completionHandler(song, status);
            }
        });
    }
    
    /// Returns the current song to the given completion handler, if there is no current song it returns the placeholder song
    func getCurrentSong(completionHandler : @escaping ((MISong) -> ())) {
        AZLogger.log("MIMPD: Getting current song...");
        
        if(socketConnection.commandSocket != nil) {
            if(socketConnection.commandSocket!.isConnected) {
                socketConnection.outputOf(command: "currentsong", log: false, completionHandler: { output in
                    /// The MISong from 'output'
                    let song : MISong = MISong(string: output);
                    
                    // If the song is valid...
                    if(song.valid) {
                        // Update the file path
                        song.file = self.musicDirectory + song.file;
                        
                        // Return the song
                        completionHandler(song);
                    }
                    // If the song is invalid...
                    else {
                        // Return the placeholder song
                        completionHandler(MISong.placeholder());
                    }
                });
            }
            else {
                // Default to returning the placeholder song
                completionHandler(MISong.placeholder());
            }
        }
        else {
            // Default to returning the placeholder song
            completionHandler(MISong.placeholder());
        }
    }
    
    /// Connects to the MPD server, calls completionHandler on connect if it is set
    func connect(_ completionHandler : ((GCDAsyncSocket) -> ())?) {
        // Connect to the socket
        socketConnection.connect(completionHandler: completionHandler);
    }
    
    /// Calls connect(_ completionHandler:) with a nil completion handler
    func connect() {
        connect(nil);
    }
    
    
    /// Init
    
    // Init with a server address, port and music directory
    init(address : String, port : Int, musicDirectory : String) {
        self.serverAddress = address;
        self.serverPort = port;
        self.musicDirectory = musicDirectory;
        self.socketConnection = MITCPCommunications(host: self.serverAddress, port: self.serverPort);
    }
    
    // Blank init
    init() {
        self.serverAddress = "127.0.0.1";
        self.serverPort = 6600;
        self.musicDirectory = "";
        self.socketConnection = MITCPCommunications();
    }
}
