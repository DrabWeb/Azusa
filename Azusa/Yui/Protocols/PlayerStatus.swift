//
//  PlayerStatus.swift
//  Yui
//
//  Created by Ushio on 2/11/17.
//

import Foundation

/// A player playing state
///
/// - stopped: Stopped
/// - paused: Paused
/// - playing: Playing
public enum PlayingState {
    case stopped, paused, playing
    
    /// Toggles between `PausedState`s (pause <-> play, stopped -> stopped)
    ///
    /// - Returns: The toggled `PauseState`
    public func toggle() -> PlayingState {
        switch self {
            case .stopped:
                return .stopped;
            
            case .paused:
                return .playing;
            
            case .playing:
                return .paused;
        }
    }
}

/// A player repeat mode
///
/// - none: No repeat
/// - queue: Repeat the queue
/// - single: Repeat a single song
public enum RepeatMode {
    case none, queue, single
    
    /// Switches between repeat modes, none -> queue -> single
    ///
    /// - Returns: The switched repeat mode
    public func next() -> RepeatMode {
        switch self {
            case .none:
                return .queue;
            
            case .queue:
                return .single;
            
            case .single:
                return .none;
        }
    }
}

/// The protocol for a player status object used by azusa
public protocol PlayerStatus: CustomStringConvertible {
    /// The current playing song
    var currentSong : Song { get set };
    
    /// The current volume
    var volume : Int { get set };
    
    /// The current repeat mode
    var repeatMode : RepeatMode { get set };
    
    /// Is consume mode on? (consume mode is when the player removes played songs from the queue)
    var isConsuming : Bool { get set };
    
    /// Is random mode on? (like shuffle but doesn't modify the queue)
    var isRandom : Bool { get set };
    
    /// The length of the queue
    var queueLength : Int { get set };
    
    /// The current playing state
    var playingState : PlayingState { get set };
    
    /// The position in the queue of the current song
    var currentSongPosition : Int { get set };
    
    /// The elapsed time into the current song
    var elapsedTime : Int { get set };
}
