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
    private var dispatchQueue : DispatchQueue = DispatchQueue(label: "Azusa.MIMusicSourcez");
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    func connect(_ completionHandler : ((Bool) -> ())?) {
        
    }
    
    // MARK: - Player
    func getPlayerStatus(_ completionHandler : @escaping ((PlayerStatus) -> ())) {
        
    }
    
    func getElapsed(_ completionHandler : @escaping ((Int) -> ())) {
        
    }
    
    func seek(to : Int, completionHandler : (() -> ())?) {
        
    }
    
    func seek(to : Int, trackPosition : Int, completionHandler : (() -> ())?) {
        
    }
    
    func togglePaused(completionHandler : ((Bool) -> ())?) {
        
    }
    
    func setPaused(_ paused : Bool, completionHandler : (() -> ())?) {
        
    }
    
    func stop(completionHandler : (() -> ())?) {
        
    }
    
    func skipNext(completionHandler : (() -> ())?) {
        
    }
    
    func skipPrevious(completionHandler : (() -> ())?) {
        
    }
    
    func setVolume(to : Int, completionHandler : (() -> ())?) {
        
    }
    
    func setRelativeVolume(to : Int, completionHandler : (() -> ())?) {
        
    }
    
    // MARK: - Queue
    func getQueue(completionHandler : @escaping (([Song], Int) -> ())) {
        
    }
    
    func playSongInQueue(_ song : Song, completionHandler : ((Song?) -> ())?) {
        
    }
    
    func removeFromQueue(_ songs : [Song], completionHandler : (() -> ())?) {
        
    }
    
    func moveAfterCurrent(_ songs : [Song], completionHandler : (() -> ())?) {
        
    }
    
    func shuffleQueue(completionHandler : (() -> ())?) {
        
    }
    
    func clearQueue(completionHandler : (() -> ())?) {
        
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    required init(settings : [String : Any]) {
        
    }
}
