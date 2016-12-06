//
//  MIStatus.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/5/16.
//

import Foundation

/// The object for representing the current status in Mio
class MIStatus : AZStatus {
    /// The current volume(0 to 100)
    var volume : Int = -1;
    
    /// Is random on?
    var random : Bool = false;
    
    /// Is consume on?
    var consume : Bool = false;
    
    /// The amount of songs in the current queue
    var queueLength : Int = -1;
    
    /// The current playing state
    var playingState : AZPlayingState = .stopped;
    
    /// The current song's position in the queue
    var currentSongPosition : Int = -1;
    
    /// The current time the user is in to the current song(in seconds)
    var timeElapsed : Int = -1;
    
    /// Returns the current repeat mode
    var repeatMode : AZRepeatMode = .off;
}
