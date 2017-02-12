//
//  MIMusicSource.swift
//  Azusa.Mio
//
//  Created by Ushio on 2/11/16.
//

import Foundation

/// The implementation for the `MusicSource` protocol in Mio
class MIMusicSource: MusicSource {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var settings : [String : Any] = [:];
    var eventManager: EventManager {
        return mpd!.eventManager;
    }
    
    // MARK: Private Properties
    
    private var mpd : MIMPD? = nil;
    private var dispatchQueue : DispatchQueue = DispatchQueue(label: "Azusa.MIMusicSource");
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    // TODO: Make these all throw real errors when `MusicSourceError` is implemented
    
    func connect(_ completionHandler : ((Bool, MusicSourceError?) -> Void)?) {
        if !perform({
            let output = self.mpd!.connect();
            
            DispatchQueue.main.async {
                completionHandler?(output, nil);
            }
        }) {
            completionHandler?(false, MusicSourceError.none);
        }
    }
    
    // MARK: - Player
    func getPlayerStatus(_ completionHandler : @escaping ((PlayerStatus, MusicSourceError?) -> Void)) {
        if !perform({
            if let playerStatus = try? self.mpd!.getPlayerStatus() {
                DispatchQueue.main.async {
                    completionHandler(playerStatus, nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler(MIPlayerStatus(), MusicSourceError.none);
        }
    }
    
    func getElapsed(_ completionHandler : @escaping ((Int, MusicSourceError?) -> Void)) {
        if !perform({
            if let elapsed = try? self.mpd!.getElapsed() {
                DispatchQueue.main.async {
                    completionHandler(elapsed, nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler(0, MusicSourceError.none);
        }
    }
    
    func seek(to : Int, completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.seek(to: to)) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    func seek(to : Int, trackPosition : Int, completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.seek(to: to, trackPosition: trackPosition)) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    func togglePaused(completionHandler : ((Bool, MusicSourceError?) -> Void)?) {
        if !perform({
            if let paused = try? self.mpd!.togglePaused() {
                DispatchQueue.main.async {
                    completionHandler?(paused, nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(false, MusicSourceError.none);
        }
    }
    
    func setPaused(_ paused : Bool, completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.setPaused(paused)) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    func stop(completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.stop()) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    func skipNext(completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.skipNextAndMaintainPlayingState()) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    func skipPrevious(completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.skipPreviousAndMaintainPlayingState()) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    func setVolume(to volume : Int, completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.setVolume(to: volume)) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    func setRelativeVolume(to volume : Int, completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.setRelativeVolume(to: volume)) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    // MARK: - Queue
    func getQueue(completionHandler : @escaping (([Song], Int, MusicSourceError?) -> Void)) {
        if !perform({
            if let queue = try? self.mpd!.getCurrentQueue(), let currentPosition = try? self.mpd!.getCurrentSongPosition() {
                DispatchQueue.main.async {
                    completionHandler(queue, currentPosition, nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler([], 0, MusicSourceError.none);
        }
    }
    
    func playSongInQueue(_ song : Song, completionHandler : ((Song?, MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.playSongInQueue(at: song.position)) != nil, let currentSong = try? self.mpd!.getCurrentSong() {
                DispatchQueue.main.async {
                    completionHandler?(currentSong, nil);
                }
            }
            else {
                DispatchQueue.main.async {
                    completionHandler?(nil, MusicSourceError.none);
                }
            }
        }) {
            completionHandler?(nil, MusicSourceError.none);
        }
    }
    
    func removeFromQueue(_ songs : [Song], completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.removeFromQueue(songs: songs as! [MISong])) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    func moveAfterCurrent(_ songs : [Song], completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.moveAfterCurrent(songs: songs as! [MISong])) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    func shuffleQueue(completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.shuffleQueue()) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    func clearQueue(completionHandler : ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.clearQueue()) != nil {
                DispatchQueue.main.async {
                    completionHandler?(nil);
                }
            }
            else {
                
            }
        }) {
            completionHandler?(MusicSourceError.none);
        }
    }
    
    // MARK: - Private Methods
    
    /// Small wrapper for nil checking on `mpd` and async
    private func perform(_ async: @escaping (() -> Void)) -> Bool {
        if self.mpd != nil {
            dispatchQueue.async {
                async();
            }
        }
        
        return self.mpd != nil;
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    required init(settings : [String : Any]) {
        // TODO: Make these keys constants
        self.mpd = MIMPD(serverInfo: MIServerInfo(address: settings["address"] as! String, port: settings["port"] as! Int, directory: settings["directory"] as! String));
    }
}
