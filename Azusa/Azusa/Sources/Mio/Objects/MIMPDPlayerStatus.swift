//
//  MIMPDPlayerStatus.swift
//  Azusa.Mio
//
//  Created by Ushio on 2/11/17.
//

import Foundation

class MIMPDPlayerStatus: PlayerStatus {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var currentSong : Song = MISong.empty;
    var volume : Int = 100;
    var repeatMode : RepeatMode = .none;
    var isConsuming : Bool = false;
    var isRandom : Bool = false;
    var queueLength : Int = 0;
    var playingState : PlayingState = .stopped;
    var currentSongPosition : Int = 0;
    var elapsedTime : Int = 0;
    var nextSongPosition : Int = 0;
    var timeElapsed : Int = 0;
    
    var isRepeating : Bool = false;
    var isSingle : Bool = false;
    
    var description : String {
        return "MIMPDPlayerStatus: [\(playingState)] #\(currentSongPosition)/\(queueLength) \(MusicUtilities.displayTime(from: timeElapsed))/\(MusicUtilities.displayTime(from: currentSong.duration)), next up #\(nextSongPosition)/\(queueLength)\n" +
               "volume: \(volume)%   repeat: \(isRepeating ? "on" : "off")   random: \(isRandom ? "on" : "off")   single: \(isSingle ? "on" : "off")   consume: \(isConsuming ? "on" : "off")";
    }
}
