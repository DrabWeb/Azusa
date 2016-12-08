//
//  MIMPDPlayerStatus.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/8/16.
//

import Foundation

/// An object to represent the status of an MPD server(current song, volume, random, etc.)
class MIMPDPlayerStatus: AZPlayerStatus {
    
    // MARK: - Properties
    
    var currentSong : AZSong = MISong.empty;
    
    var volume : Int = 100;
    
    var randomOn : Bool = false;
    
    var repeatOn : Bool = false;
    
    var singleOn : Bool = false;
    
    var consumeOn : Bool = false;
    
    var queueLength : Int = 0;
    
    var playingState : AZPlayingState = .stopped;
    
    var currentSongPosition : Int = 0;
    
    /// The position of the next song in the queue
    var nextSongPosition : Int = 0;
    
    var timeElapsed : Int = 0;
    
    var description : String {
        var playingStateString : String = "";
        
        switch(self.playingState) {
            case .playing:
                playingStateString = "playing";
                break;
            case .paused:
                playingStateString = "paused";
                break;
            case .stopped:
                playingStateString = "stopped";
                break;
        }
        
        return "MIMPDPlayerStatus: [\(playingStateString)] #\(currentSongPosition)/\(queueLength) \(AZMusicUtilities.secondsToDisplayTime(self.timeElapsed))/\(AZMusicUtilities.secondsToDisplayTime(self.currentSong.duration)), next up #\(nextSongPosition)/\(queueLength)\n" +
               "volume: \(self.volume)%   repeat: \(self.repeatOn ? "on" : "off")   random: \(self.randomOn ? "on" : "off")   single: \(self.singleOn ? "on" : "off")   consume: \(self.consumeOn ? "on" : "off")";
    }
}
