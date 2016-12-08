//
//  AZMusicPlayer.swift
//  Azusa
//
//  Created by Ushio on 12/5/16.
//

import Foundation

/// The protocol for some form of music player backend that Azusa can connect and use
protocol AZMusicPlayer {
    
    // MARK: - Functions
    
    /// Starts up the connection to this music player backend and calls the given completion handler upon finishing(if given)
    ///
    /// - Parameter completionHandler: The closure to call when the connection finishes successfully(optional)
    func connect(_ completionHandler : (() -> ())?);
}
