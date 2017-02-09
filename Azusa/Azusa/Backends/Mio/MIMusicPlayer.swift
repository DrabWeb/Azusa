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
    
    private var mpd : MIMPD? = nil;
    
    private var dispatchQueue : DispatchQueue = DispatchQueue(label: "Azusa.MIMusicPlayer");
    
    
    // MARK: - Functions
    
    // MARK: - Connection
    
    func connect(_ completionHandler: ((Bool) -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                let successful : Bool = self.mpd!.connect();

                DispatchQueue.main.async {
                    completionHandler?(successful);
                }
            }
            else {
                DispatchQueue.main.async {
                    completionHandler?(false);
                }
            }
        }
    }
    
    func getPlayerStatus(_ completionHandler: @escaping ((AZPlayerStatus) -> ())) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if let playerStatus = try? self.mpd!.getPlayerStatus() {
                    DispatchQueue.main.async {
                        completionHandler(playerStatus);
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error getting player status, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func getElapsed(_ completionHandler: @escaping ((Int) -> ())) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if let elapsed = try? self.mpd!.getElapsed() {
                    DispatchQueue.main.async {
                        completionHandler(elapsed);
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error getting elapsed time, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func seek(to: Int, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if (try? self.mpd!.seek(to: to)) != nil {
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error seeking, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func seek(to: Int, trackPosition: Int, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if (try? self.mpd!.seek(to: to, trackPosition: trackPosition)) != nil {
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error seeking, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func togglePaused(completionHandler: ((Bool) -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if let pausedState = try? self.mpd!.togglePaused() {
                    DispatchQueue.main.async {
                        completionHandler?(pausedState);
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error toggling paused state, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func setPaused(_ paused: Bool, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if (try? self.mpd!.setPaused(paused)) != nil {
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error setting paused, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func stop(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if (try? self.mpd!.stop()) != nil {
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error stopping playback, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    // The default behaviour for skipping next/previous from an AZMusicPlayer is to maintain playing state
    
    func skipPrevious(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if (try? self.mpd!.skipPreviousAndMaintainPlayingState()) != nil {
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error skipping to the previous song, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func skipNext(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if (try? self.mpd!.skipNextAndMaintainPlayingState()) != nil {
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error skipping to the next song, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func setVolume(to: Int, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if (try? self.mpd!.setVolume(to: to)) != nil {
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error setting volume, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func setRelativeVolume(to: Int, completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                if (try? self.mpd!.setRelativeVolume(to: to)) != nil {
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error setting relative volume, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    
    // MARK: - Queue
    
    func getQueue(completionHandler: @escaping (([AZSong], Int) -> ())) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                guard let queue = try? self.mpd!.getCurrentQueue(),
                      let currentPosition = try? self.mpd!.getCurrentSongPosition() else {
                    AZLogger.log("MIMusicPlayer: Error getting queue, \(self.mpd!.currentError())");
                    return;
                }
                
                DispatchQueue.main.async {
                    completionHandler(queue, currentPosition);
                }
            }
        }
    }
    
    func playSongInQueue(_ song: AZSong, completionHandler: ((AZSong?) -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                // Play the song at `song`'s `position`, and if there's no errors...
                if((try? self.mpd!.playSongInQueue(at: song.position)) != nil) {
                    // Get the current song, and if there's no errors...
                    if let currentSong = try? self.mpd!.getCurrentSong() {
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
            if self.mpd != nil {
                // Remove `songs` from the queue, and if there's no errors...
                if((try? self.mpd!.removeFromQueue(songs: songs as! [MISong])) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error removing from queue, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func moveAfterCurrent(_ songs: [AZSong], completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                // Move `songs` after the current song, and if there's no errors...
                if((try? self.mpd!.moveAfterCurrent(songs: songs as! [MISong])) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error moving after the current song, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func shuffleQueue(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                // Shuffle the queue, and if there's no errors...
                if((try? self.mpd!.shuffleQueue()) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error shuffling queue, \(self.mpd!.currentError())");
                }
            }
        }
    }
    
    func clearQueue(completionHandler: (() -> ())?) {
        self.dispatchQueue.async {
            if self.mpd != nil {
                // Clear the queue, and if there's no errors...
                if((try? self.mpd!.clearQueue()) != nil) {
                    // Call the completion handler
                    DispatchQueue.main.async {
                        completionHandler?();
                    }
                }
                else {
                    AZLogger.log("MIMusicPlayer: Error clearing queue, \(self.mpd!.currentError())");
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
