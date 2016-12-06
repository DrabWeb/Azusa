//
//  MIMPD.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/5/16.
//

import Foundation

/// The AZMusicPlayer extension for MPD in Azusa
class MIMPD : AZMusicPlayer {
    /// The event subscriber for this music player
    var eventSubscriber : MIEventSubscriber {
        return self._eventSubscriber;
    }
    
    /// The event subscriber object for this music player
    internal var _eventSubscriber : MIEventSubscriber = MIEventSubscriber();
    
    /// Starts up the connection to MPD and calls the given completion handler upon finishing(if given)
    func connect(_ completionHandler : (() -> ())?) {
        
    }
}
