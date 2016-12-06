//
//  AZMusicUtilities.swift
//  Azusa
//
//  Created by Ushio on 11/25/16.
//

import Foundation

/// General music related utilities for Azusa
struct AZMusicUtilities {
    /// Returns the display string for given seconds
    static func secondsToDisplayTime(_ seconds : Int) -> String {
        /// The hours, minutes and seconds values of the given seconds
        let hoursMinutesSeconds : (Int, Int, Int) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60);
        
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
            // Return the display string
            return "\(minutesString):\(secondsString)";
        }
    }
}
