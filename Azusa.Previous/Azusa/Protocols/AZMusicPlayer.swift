//
//  AZMusicPlayer.swift
//  Azusa
//
//  Created by Ushio on 12/5/16.
//

import Foundation

/// The protocol for some form of music player backend that Azusa can connect and use
protocol AZMusicPlayer {
    
    // MARK: - Properties
    
    /// The key value pairs for the settings of this music player
    var settings : [String : Any] { get set };
    
    /// The event subscriber for this music player
    var eventSubscriber : AZEventSubscriber { get set };
    
    
    // MARK: - Functions
    
    // MARK: - Connection
    
    /// Starts up the connection to this music player backend and calls the given completion handler upon finishing(if given)
    ///
    /// - Parameter completionHandler: The closure to call when the connection function finishes, passed if it was successful(optional)
    func connect(_ completionHandler : ((Bool) -> ())?);
    
    
    // MARK: - Player
    
    /// Gets the current `AZPlayerStatus` of this music player
    ///
    /// - Parameter completionHandler: The completion handler to call with the retrieved `AZPlayerStatus`
    func getPlayerStatus(_ completionHandler : @escaping ((AZPlayerStatus) -> ()));
    
    /// Gets the elapsed time and duration of the current playing song, used for updating progress bars and similar
    ///
    /// - Parameter completionHandler: The completion handler for the request, passed the elapsed time of the current song in seconds
    func getElapsed(_ completionHandler : @escaping ((Int) -> ()));
    
    /// Seeks to `to` in the current playing song
    ///
    /// - Parameters:
    ///   - to: The time in seconds to skip to
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func seek(to : Int, completionHandler : (() -> ())?);
    
    /// Seeks to `to` in the song at `trackPosition` in the queue
    ///
    /// - Parameters:
    ///   - to: The time in seconds to skip to
    ///   - trackPosition: The position of the track in the queue to jump to
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func seek(to : Int, trackPosition : Int, completionHandler : (() -> ())?);
    
    /// Toggles the paused state of this music player
    ///
    /// - Parameters:
    ///   - completionHandler: The completion handler to call when the operation finishes(optional), passed the paused state that was set
    func togglePaused(completionHandler : ((Bool) -> ())?);
    
    /// Sets the paused state of this music player
    ///
    /// - Parameters:
    ///   - paused: The value to set paused to
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func setPaused(_ paused : Bool, completionHandler : (() -> ())?);
    
    /// Stops playback for this music player
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    func stop(completionHandler : (() -> ())?);
    
    /// Skips to the next song in the queue
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    func skipNext(completionHandler : (() -> ())?);
    
    /// Skips to the previous song in the queue
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    func skipPrevious(completionHandler : (() -> ())?);
    
    /// Sets the volume of this music player to the given value
    ///
    /// - Parameters:
    ///   - to: The volume to set
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func setVolume(to : Int, completionHandler : (() -> ())?);
    
    /// Adds the given volume to the current volume
    ///
    /// - Parameters:
    ///   - to: The value to add to the volume, relative to the current volume(-100 to 100)
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func setRelativeVolume(to : Int, completionHandler : (() -> ())?);
    
    
    // MARK: - Queue
    
    /// Gets the current queue
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes, passed an array of `AZSong`s for the queue and the position of the current song in the queue(defaults to -1 if no song is playing)
    func getQueue(completionHandler : @escaping (([AZSong], Int) -> ()));
    
    /// Plays the given song if it's in the queue
    ///
    /// - Parameters:
    ///   - song: The song to play
    ///   - completionHandler: The completion handler to call when the operation finishes(optional), passed the song that was played(nil if `song` was not in the queue)
    func playSongInQueue(_ song : AZSong, completionHandler : ((AZSong?) -> ())?);
    
    /// Removes the given `AZSong`s from the queue
    ///
    /// - Parameters:
    ///   - songs: The `AZSong`s to remove
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func removeFromQueue(_ songs : [AZSong], completionHandler : (() -> ())?);
    
    /// Moves the given `AZSong`s in the queue to after the current song(do not use this for adding songs to the queue after the current song, only move queued songs)
    ///
    /// - Parameters:
    ///   - songs: The `AZSong`s to move to after the current song
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func moveAfterCurrent(_ songs : [AZSong], completionHandler : (() -> ())?);
    
    /// Shuffles the current queue
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    func shuffleQueue(completionHandler : (() -> ())?);
    
    /// Clears the current queue
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    func clearQueue(completionHandler : (() -> ())?);
    
    
    // MARK: - Initialization and Deinitialization
    
    init(settings : [String : Any]);
}
