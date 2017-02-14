//
//  MIPlayerStatus.swift
//  Azusa.Mio
//
//  Created by Ushio on 2/11/17.
//

import Foundation
import Yui

public class MIPlayerStatus: PlayerStatus {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public var currentSong : Song = MISong.empty;
    public var volume : Int = 100;
    public var repeatMode : RepeatMode = .none;
    public var isConsuming : Bool = false;
    public var isRandom : Bool = false;
    public var queueLength : Int = 0;
    public var playingState : PlayingState = .stopped;
    public var currentSongPosition : Int = 0;
    public var elapsedTime : Int = 0;
    public var nextSongPosition : Int = 0;
    public var timeElapsed : Int = 0;
    
    public var isRepeating : Bool = false;
    public var isSingle : Bool = false;
    
    public var description : String {
        return "MIMPDPlayerStatus: [\(playingState)] #\(currentSongPosition)/\(queueLength) \(MusicUtilities.displayTime(from: timeElapsed))/\(MusicUtilities.displayTime(from: currentSong.duration)), next up #\(nextSongPosition)/\(queueLength)\n" +
               "volume: \(volume)%   repeat: \(isRepeating ? "on" : "off")   random: \(isRandom ? "on" : "off")   single: \(isSingle ? "on" : "off")   consume: \(isConsuming ? "on" : "off")";
    }
}
