//
//  MIStatus.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/5/16.
//

import Foundation

/// The object for representing the current status in Mio
class MIStatus : AZStatus {
    
    var volume : Int = -1;
    
    var random : Bool = false;
    
    var consume : Bool = false;
    
    var queueLength : Int = -1;
    
    var playingState : AZPlayingState = .stopped;
    
    var currentSongPosition : Int = -1;
    
    var timeElapsed : Int = -1;
    
    var repeatMode : AZRepeatMode = .off;
}
