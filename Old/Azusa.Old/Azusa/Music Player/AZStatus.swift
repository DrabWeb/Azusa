//
//  AZStatus.swift
//  Azusa
//
//  Created by Ushio on 12/5/16.
//

import Foundation

/// The different playing states that the music player can be in
enum AZPlayingState : Int {
    case playing = 0
    case paused = 1
    case stopped = 2
}

/// The different looping modes that the music player can be in
enum AZRepeatMode : Int {
    case off = 0
    case playlist = 1
    case single = 2
}

/// The protocol for a status object used by Azusa
protocol AZStatus {
    /// The current volume(0 to 100)
    var volume : Int { get set };
    
    /// Is random on?
    var random : Bool { get set };
    
    /// Is consume on?
    var consume : Bool { get set };
    
    /// The amount of songs in the current queue
    var queueLength : Int { get set };
    
    /// The current playing state
    var playingState : AZPlayingState { get set };
    
    /// The current song's position in the queue
    var currentSongPosition : Int { get set };
    
    /// The current time the user is in to the current song(in seconds)
    var timeElapsed : Int { get set };
    
    /// The current repeat mode
    var repeatMode : AZRepeatMode { get set };
}
