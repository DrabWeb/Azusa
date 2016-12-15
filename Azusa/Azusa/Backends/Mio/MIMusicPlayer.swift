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
                // Get the `MIPlayerStatus` of `mpd`, and if it isn't nil...
                if let playerStatus = self.mpd!.getPlayerStatus() {
                    // Call the completion handler with `playerStatus`
                    DispatchQueue.main.async {
                        completionHandler(playerStatus);
                    }
                }
            }
        }
    }
    
    func getElapsed(_ completionHandler: @escaping ((Int) -> ())) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                /// The output of `getElapsed`
                let output = self.mpd!.getElapsed();
                
                // If `getElapsed` was successful...
                if(output.0) {
                    // Call the completion handler with `output`
                    DispatchQueue.main.async {
                        completionHandler(output.1);
                    }
                }
            }
        }
    }
    
    func seek(to: Int, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Call `seek`, and if it's successful...
                if(self.mpd!.seek(to: to)) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
            }
        }
    }
    
    func togglePaused(completionHandler: ((Bool) -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                /// The output of `togglePaused`
                let togglePausedResult : (Bool, Bool) = self.mpd!.togglePaused();
                
                // If the toggle was successful...
                if(togglePausedResult.0) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?(togglePausedResult.1);
                    }
                }
            }
        }
    }
    
    func skipPrevious(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Run skip previous, and if it was successful...
                if(self.mpd!.skipPreviousAndMaintainPlayingState()) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
            }
        }
    }
    
    func skipNext(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Run skip next, and if it was successful...
                if(self.mpd!.skipNextAndMaintainPlayingState()) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
            }
        }
    }
    
    func setVolume(to: Int, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Run the volume command, and if it was successful...
                if(self.mpd!.setVolume(to: to)) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
            }
        }
    }
    
    func getQueue(completionHandler: @escaping (([AZSong], Int) -> ())) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                /// All the songs in the current queue
                let queue : [MISong] = self.mpd!.getCurrentQueue();
                
                /// The position of the current song in the queue
                let currentPosition : Int = self.mpd!.getCurrentSongPosition();
                
                // Call the completion handler
                DispatchQueue.main.async {
                    completionHandler(queue, currentPosition);
                }
            }
        }
    }
    
    func playSongInQueue(_ song: AZSong, completionHandler: ((AZSong?) -> ())?) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                // Play the song at `song`'s `position`, and if it's successful...
                if(self.mpd!.playSongInQueue(at: song.position)) {
                    // Get the current song, and if it isn't nil...
                    if let currentSong = self.mpd!.getCurrentSong() {
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
                // Remove `songs` from the queue, and if it's successful...
                if(self.mpd!.removeFromQueue(songs: songs as! [MISong])) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
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
