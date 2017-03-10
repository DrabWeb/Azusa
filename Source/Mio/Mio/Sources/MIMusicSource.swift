//
//  MIMusicSource.swift
//  Azusa.Mio
//
//  Created by Ushio on 2/11/16.
//

import Foundation
import Yui

/// The implementation for the `MusicSource` protocol in Mio
public class MIMusicSource: MusicSource {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public var settings : [String : Any] = [:];
    public var eventManager: EventManager {
        return mpd!.eventManager;
    }
    
    // MARK: Private Properties
    
    private var mpd : MIMPD? = nil;
    private var dispatchQueue : DispatchQueue = DispatchQueue(label: "Azusa.MIMusicSource");
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    // TODO: Make these all throw real errors when `MusicSourceError` is implemented
    
    public func connect(_ completionHandler : ((Bool, MusicSourceError?) -> Void)?) {
        if !perform({
            let output = self.mpd!.connect();
            if output {
                self.eventManager.emit(event: .connect);
            }
            
            DispatchQueue.main.async {
                completionHandler?(output, nil);
            }
        }) {
            completionHandler?(false, MusicSourceError.none);
        }
    }
    
    // MARK: - Player
    public func getPlayerStatus(_ completionHandler : @escaping ((PlayerStatus, MusicSourceError?) -> Void)) {
        if !perform({
            // TODO: Find out why this player status never gets the elapsed time
            // It's always zero
            // And mpd.getElapsedTime returns the proper for some reason
            // Temporarly just calling that to replace elapsed until fixed
            if let playerStatus = try? self.mpd!.getPlayerStatus() {
                playerStatus.elapsedTime = (try? self.mpd!.getElapsed()) ?? 0;
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
    
    public func getElapsed(_ completionHandler : @escaping ((Int, MusicSourceError?) -> Void)) {
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
    
    public func seek(to : Int, completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func seek(to : Int, trackPosition : Int, completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func togglePaused(completionHandler : ((Bool, MusicSourceError?) -> Void)?) {
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
    
    public func setPaused(_ paused : Bool, completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func stop(completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func skipNext(completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func skipPrevious(completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func setVolume(to volume : Int, completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func setRelativeVolume(to volume : Int, completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func setRepeatMode(to mode: RepeatMode, completionHandler: ((MusicSourceError?) -> Void)?) {
        if !perform({
            if (try? self.mpd!.setRepeatMode(to: mode)) != nil {
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
    public func getQueue(completionHandler : @escaping (([Song], Int, MusicSourceError?) -> Void)) {
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
    
    public func playSongInQueue(_ song : Song, completionHandler : ((Song?, MusicSourceError?) -> Void)?) {
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
    
    public func removeFromQueue(_ songs : [Song], completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func moveAfterCurrent(_ songs : [Song], completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func shuffleQueue(completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public func clearQueue(completionHandler : ((MusicSourceError?) -> Void)?) {
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
    
    public required init(settings : [String : Any]) {
        self.mpd = MIMPD(serverInfo: MIServerInfo(address: settings[SettingsKey.address] as! String, port: settings[SettingsKey.port] as! Int, directory: settings[SettingsKey.directory] as! String));
    }
}
