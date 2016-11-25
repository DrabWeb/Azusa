//
//  MIStatus.swift
//  Azusa.Mio
//
//  Created by Ushio on 11/24/16.
//

import Foundation

/// The different playing states MPD can be in
enum MIMPDState : Int {
    case play = 0
    case pause = 1
    case stop = 2
}

/// An object to represent MPD's current status
class MIStatus: NSObject {
    
    // Variables
    
    /// The current volume(0 to 100)
    var volume : Int = -1;
    
    /// Is repeat on?
    var repeatMode : Bool = false;
    
    /// Is random on?
    var randomMode : Bool = false;
    
    /// Is single mode on?
    var singleMode : Bool = false;
    
    /// Is consume mode on?
    var consumeMode : Bool = false;
    
    /// The amount of songs in the playlist
    var playlistLength : Int = -1;
    
    /// The current playing state
    var playingState : MIMPDState = MIMPDState.stop;
    
    /// The current song's position in the playlist
    var currentSongPosition : Int = 0;
    
    /// The ID of the current song
    var currentSongId : Int = -1;
    
    /// The current time the user is in to the current song
    var timeElapsed : Float = 0;
    
    /// The position of the next song in the playlist
    var nextSongPosition : Int = 0;
    
    /// The ID of the next song
    var nextSongId : Int = -1;
    
    /// Instantaneous bitrate in KBps
    var bitrate : Int = 0;
    
    /// The audio output info, format is sampleRate:bits:channels
    var audioInfo : String = "0:0:0";
    
    override var debugDescription : String {
        var playingStateString : String = "";
        
        switch(self.playingState) {
            case .play:
                playingStateString = "playing";
                break;
            case .pause:
                playingStateString = "paused";
                break;
            case .stop:
                playingStateString = "stopped";
                break;
        }
        
        return "\(self): [\(playingStateString)] #\(currentSongPosition)/\(playlistLength) \(MIUtilities.secondsToDisplayTime(Int(self.timeElapsed))), next up #\(nextSongPosition)/\(playlistLength)\n" +
               "volume: \(self.volume)%   repeat: \(self.repeatMode ? "on" : "off")   random: \(self.randomMode ? "on" : "off")   single: \(self.singleMode ? "on" : "off")   consume: \(self.consumeMode ? "on" : "off")";
    }
    
    
    // Init
    
    /// Init from a string returned by MPD
    init(string : String) {
        // Example string
        //
        // volume: 75
        // repeat: 0
        // random: 0
        // single: 0
        // consume: 0
        // playlistlength: 24
        // state: play
        // song: 11
        // songid: 127
        // elapsed: 39.868
        // nextsong: 12
        // nextsongid: 111
        // bitrate: 320
        // audio: 44100:16:2
        //
        
        // For every line in the given string...
        for(_, currentLine) in string.components(separatedBy: "\n").enumerated() {
            /// The prefix for this line(e.g. file:, Album:, etc.)
            var prefix : String = "";
            
            /// The content for this line(the line without the prefix)
            var content : String = "";
            
            /// 'currentLine' split at every space
            var currentLineSplitAtSpaces : [String] = currentLine.components(separatedBy: " ");
            
            // Set prefix to the first item in 'currentLineSplitAtSpaces' and remove it from the array
            prefix = currentLineSplitAtSpaces[0];
            currentLineSplitAtSpaces.remove(at: 0);
            
            // For every item in currentLineSplitAtSpaces...
            for(_, currentSplitItem) in currentLineSplitAtSpaces.enumerated() {
                // Append 'currentSplitItem' to content
                content = content + " " + currentSplitItem;
            }
            
            // If 'currentLineSplitAtSpaces' has at least one item...
            if(currentLineSplitAtSpaces.count > 0) {
                // Remove the leading space from content
                content = content.substring(from: content.index(after: content.startIndex));
            }
            
            // Switch and set the appropriate variable based on the prefix
            switch(prefix) {
                case "volume:":
                    self.volume = Int(NSString(string: content).intValue);
                    break;
                
                case "repeat:":
                    self.repeatMode = ((content == "1") ? true : false);
                    break;
                
                case "random:":
                    self.randomMode = ((content == "1") ? true : false);
                    break;
                
                case "single:":
                    self.singleMode = ((content == "1") ? true : false);
                    break;
                
                case "consume:":
                    self.consumeMode = ((content == "1") ? true : false);
                    break;
                
                case "playlistlength:":
                    self.playlistLength = Int(NSString(string: content).intValue);
                    break;
                
                case "state:":
                    if(content == "play") {
                        self.playingState = .play;
                    }
                    else if(content == "pause") {
                        self.playingState = .pause;
                    }
                    else if(content == "stop") {
                        self.playingState = .stop;
                    }
                    break;
                
                case "song:":
                    self.currentSongPosition = Int(NSString(string: content).intValue);
                    break;
                
                case "songid:":
                    self.currentSongId = Int(NSString(string: content).intValue);
                    break;
                
                case "elapsed:":
                    self.timeElapsed = NSString(string: content).floatValue;
                    break;
                
                case "nextsong:":
                    self.nextSongPosition = Int(NSString(string: content).intValue);
                    break;
                
                case "nextsongid:":
                    self.nextSongId = Int(NSString(string: content).intValue);
                    break;
                
                case "bitrate:":
                    self.bitrate = Int(NSString(string: content).intValue);
                    break;
                
                case "audio:":
                    self.audioInfo = content;
                    break;
                
                default:
                    break;
            }
        }
    }
}
