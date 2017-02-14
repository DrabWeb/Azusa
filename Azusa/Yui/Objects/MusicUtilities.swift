//
//  MusicUtilities.swift
//  Yui
//
//  Created by Ushio on 2/11/16.
//

import Foundation

/// Little utilities for working with music, like time
public struct MusicUtilities {
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    /// Returns the hours, minutes and seconds from the given amount of seconds
    ///
    /// - Parameter seconds: The seconds to use
    /// - Returns: A `Time` object from the given values
    public static func hoursMinutesSeconds(from seconds : Int) -> Time {
        return Time(hours: seconds / 3600, minutes: (seconds % 3600) / 60, seconds: (seconds % 3600) % 60);
    }
    
    /// Returns the display string for given seconds
    ///
    /// - Parameter seconds: The seconds to get the display time from
    /// - Returns: The display string for the given seconds
    public static func displayTime(from seconds : Int) -> String {
        //
        // 0:31
        // 1:32:41
        // 2:05
        //
        
        let time = MusicUtilities.hoursMinutesSeconds(from: seconds);
        
        var hoursString : String = "";
        var minutesString : String = String(format: "%01d", time.minutes);
        let secondsString : String = String(format: "%02d", time.seconds);
        
        if(time.hours > 0) {
            hoursString = String(time.hours);
        }
        
        if(hoursString != "") {
            minutesString = String(format: "%02d", time.minutes);
            
            return "\(hoursString):\(minutesString):\(secondsString)";
        }
        else {
            return "\(minutesString):\(secondsString)";
        }
    }
}

public struct Time {
    public var hours : Int = 0;
    public var minutes : Int = 0;
    public var seconds : Int = 0;
    
    public init(hours : Int = 0, minutes : Int = 0, seconds : Int = 0) {
        self.hours = hours;
        self.minutes = minutes;
        self.seconds = seconds;
    }
}
