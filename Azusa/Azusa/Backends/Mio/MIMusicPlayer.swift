//
//  MIMusicPlayer.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/11/16.
//

import Foundation

/// The implementation for the `AZMusicPlayer` protocol in Mio
class MIMusicPlayer: AZMusicPlayer {
    
    // MARK: - Properties
    
    var settings : [String : Any] = [:];
    
    var eventSubscriber : AZEventSubscriber = AZEventSubscriber();
    
    /// The `MIMPD` for this music player
    var mpd : MIMPD? = nil;
    
    /// The dispatch queue for doing async `MIMPD` actions
    var dispatchQueue : DispatchQueue = DispatchQueue(label: "Azusa.MIMusicPlayer");
    
    
    // MARK: - Functions
    
    // MARK: - Connection
    
    func connect(_ completionHandler: ((Bool) -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                /// The output of `mpd.connect`, if the connection was successful
                let successful : Bool = self.mpd!.connect();
                
                // Call the completion handler with `successful`
                DispatchQueue.main.async {
                    completionHandler?(successful);
                }
            }
            // If `mpd` doesn't exist...
            else {
                // Return false because we can't even attempt without having `mpd` exist
                DispatchQueue.main.async {
                    completionHandler?(false);
                }
            }
        }
    }
    
    func getPlayerStatus(_ completionHandler: @escaping ((AZPlayerStatus) -> ())) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Get the current `MIMPDPlayerStatus` from MPD, and if it there's no errors...
                if let playerStatus : MIMPDPlayerStatus = try? self.mpd!.getPlayerStatus() {
                    // Call the completion handler with `playerStatus`
                    DispatchQueue.main.async {
                        completionHandler(playerStatus);
                    }
                }
                else {
                    print("MIMusicPlayer: Error getting player status, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func getElapsed(_ completionHandler: @escaping ((Int) -> ())) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Get the current elapsed time, and if there's no errors...
                if let elapsed : Int = try? self.mpd!.getElapsed() {
                    // Call the completion handler with `elapsed`
                    DispatchQueue.main.async {
                        completionHandler(elapsed);
                    }
                }
                else {
                    print("MIMusicPlayer: Error getting elapsed time, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func seek(to: Int, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Call `seek`, and if there's no errors...
                if((try? self.mpd!.seek(to: to)) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error seeking, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func seek(to: Int, trackPosition: Int, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Call the seek command, and if there's no errors...
                if((try? self.mpd!.seek(to: to, trackPosition: trackPosition)) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error seeking, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func togglePaused(completionHandler: ((Bool) -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Toggle the paused state and get the toggled to state, and if there were no errors...
                if let pausedState : Bool = try? self.mpd!.togglePaused() {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?(pausedState);
                    }
                }
                else {
                    print("MIMusicPlayer: Error toggling paused state, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func stop(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Run the stop command, and if there were no errors...
                if((try? self.mpd!.togglePaused()) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error stopping playback, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func skipPrevious(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Run skip previous, and if there's no errors...
                if ((try? self.mpd!.skipPreviousAndMaintainPlayingState()) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error skipping to the previous song, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func skipNext(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Run skip next, and if there's no errors...
                if ((try? self.mpd!.skipNextAndMaintainPlayingState()) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error skipping to the next song, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func setVolume(to: Int, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Run the volume command, and if there's no errors...
                if((try? self.mpd!.setVolume(to: to)) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error setting volume, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func setRelativeVolume(to: Int, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Run the relative volume command, and if there's no errors...
                if((try? self.mpd!.setRelativeVolume(to: to)) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error setting relative volume, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    
    // MARK: - Queue
    
    func getQueue(completionHandler: @escaping (([AZSong], Int) -> ())) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Get the current queue, and if there's no errors...
                if let queue : [MISong] = try? self.mpd!.getCurrentQueue() {
                    // Get the position of the current song in the queue, and if there's no errors...
                    if let currentPosition : Int = try? self.mpd!.getCurrentSongPosition() {
                        // Call the completion handler
                        DispatchQueue.main.async {
                            completionHandler(queue, currentPosition);
                        }
                    }
                    else {
                        print("MIMusicPlayer: Error getting current song position, \(self.mpd!.currentError())");
                    }
                }
                else {
                    print("MIMusicPlayer: Error getting queue, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func playSongInQueue(_ song: AZSong, completionHandler: ((AZSong?) -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Play the song at `song`'s `position`, and if there's no errorss...
                if((try? self.mpd!.playSongInQueue(at: song.position)) != nil) {
                    // Get the current song, and if there's no errors...
                    if let currentSong : MISong? = try? self.mpd!.getCurrentSong() {
                        // Call the completion handler
                        DispatchQueue.main.async {
                            completionHandler?(currentSong);
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            completionHandler?(nil);
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completionHandler?(nil);
                    }
                }
            }
        }
    }
    
    func removeFromQueue(_ songs: [AZSong], completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Remove `songs` from the queue, and if there's no errors...
                if((try? self.mpd!.removeFromQueue(songs: songs as! [MISong])) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error removing from queue, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func moveAfterCurrent(_ songs: [AZSong], completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Move `songs` after the current song, and if there's no errors...
                if((try? self.mpd!.moveAfterCurrent(songs: songs as! [MISong])) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error moving after the current song, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func shuffleQueue(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Shuffle the queue, and if there's no errors...
                if((try? self.mpd!.shuffleQueue()) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error shuffling queue, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func clearQueue(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Clear the queue, and if there's no errors...
                if((try? self.mpd!.clearQueue()) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    print("MIMusicPlayer: Error clearing queue, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    
    // MARK: - Initialization and Deinitialization
    required init(settings : [String : Any]) {
        self.mpd = MIMPD(address: settings["address"] as! String, port: settings["port"] as! Int, musicDirectory: settings["musicDirectory"] as! String);
        
        self.mpd!.eventSubscriber = self.eventSubscriber;
    }
}
