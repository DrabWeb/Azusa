//
//  AZMusicUtilities.swift
//  Azusa
//
//  Created by Ushio on 12/7/16.
//

import Foundation

/// General music related utilities for Azusa
struct AZMusicUtilities {
    
    // MARK: - Functions
    
    /// Returns the hours, minutes and seconds from the given amount of seconds
    ///
    /// - Parameter seconds: The seconds to use
    /// - Returns: The hours, minutes and seconds of `seconds`
    static func hoursMinutesSeconds(from seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60);
    }
    
    /// Returns the display string for given seconds
    ///
    /// - Parameter seconds: The seconds to get the display time from
    /// - Returns: The display string for the given seconds(e.g. 1:40, 0:32, 1:05:42, etc.)
    static func secondsToDisplayTime(_ seconds : Int) -> String {
        /// The hours, minutes and seconds from `seconds`
        let hoursMinutesSeconds = AZMusicUtilities.hoursMinutesSeconds(from: seconds);
        
        /// The display string for the hours
        var hoursString : String = "";
        
        /// The display string for the minutes
        var minutesString : String = "";
        
        /// The display string for the seconds
        var secondsString : String = "";
        
        // If there is at least one hour...
        if(hoursMinutesSeconds.0 > 0) {
            // Set the hours string to the hour count
            hoursString = String(hoursMinutesSeconds.0);
        }
        
        // Set the minutes string to minutes, zero padded by one
        minutesString = String(format: "%01d", hoursMinutesSeconds.1);
        
        // Set the seconds string to seconds, zero padded by two
        secondsString = String(format: "%02d", hoursMinutesSeconds.2);
        
        // If the hours string is set...
        if(hoursString != "") {
            // Set minutes string to have two zero padding
            minutesString = String(format: "%02d", hoursMinutesSeconds.1);
            
            // Return the display string
            return "\(hoursString):\(minutesString):\(secondsString)";
        }
        // If the hours string isn't set...
        else {
            // Return the display string as is
            return "\(minutesString):\(secondsString)";
        }
    }
}
