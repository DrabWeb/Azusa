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
    
    func getElapsedAndDuration(_ completionHandler: @escaping ((Int, Int) -> ())) {
        self.dispatchQueue.async {
            // If `mpd` exists..
            if(self.mpd != nil) {
                /// The output of `getElapsedAndDuration`
                let elapsedTimeAndDuration = self.mpd!.getElapsedAndDuration();
                
                // If `getElapsedAndDuration` was successful...
                if(elapsedTimeAndDuration.0) {
                    // Call the completion handler with `elapsedTimeAndDuration`
                    DispatchQueue.main.async {
                        completionHandler((elapsedTimeAndDuration.1, elapsedTimeAndDuration.2));
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
                if(self.mpd!.skipPrevious()) {
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
                if(self.mpd!.skipNext()) {
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
    
    
    // MARK: - Initialization and Deinitialization
    required init(settings : [String : Any]) {
        self.mpd = MIMPD(address: settings["address"] as! String, port: settings["port"] as! Int, musicDirectory: settings["musicDirectory"] as! String);
        
        self.mpd!.eventSubscriber = self.eventSubscriber;
    }
}
