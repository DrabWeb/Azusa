//
//  AZPlayerStatus.swift
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

/// The protocol for a player status object used by Azusa
protocol AZPlayerStatus {
    
    // MARK: - Properties
    
    /// The current playing song
    var currentSong : AZSong { get set };
    
    /// The current volume(0 to 100)
    var volume : Int { get set };
    
    /// Is random on?
    var randomOn : Bool { get set };
    
    /// Is repeat on?
    var repeatOn : Bool { get set };
    
    /// Is single on?
    var singleOn : Bool { get set };
    
    /// Is consume on?
    var consumeOn : Bool { get set };
    
    /// The amount of songs in the current queue
    var queueLength : Int { get set };
    
    /// The current playing state
    var playingState : AZPlayingState { get set };
    
    /// The current song's position in the queue
    var currentSongPosition : Int { get set };
    
    /// The current time the user is in to the current song(in seconds)
    var timeElapsed : Int { get set };
    
    /// The description of this song for debugging purposes, like logging
    var debugDescription : String { get };
}
