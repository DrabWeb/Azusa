//
//  PlayerStatus.swift
//  Yui
//
//  Created by Ushio on 2/11/17.
//

import Foundation

public enum PlayingState {
    case stopped, paused, playing
    
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

public enum RepeatMode {
    case none, queue, single
    
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
    var currentSong : Song { get set };
    var volume : Int { get set };
    var repeatMode : RepeatMode { get set };
    var isConsuming : Bool { get set };
    var isRandom : Bool { get set };
    var queueLength : Int { get set };
    var playingState : PlayingState { get set };
    var currentSongPosition : Int { get set };
    var elapsedTime : Int { get set };
}
