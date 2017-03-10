//
//  MusicPlayer.swift
//  Yui
//
//  Created by Ushio on 2/11/17.
//

import Foundation

// TODO: Add actual errors here, not sure which to be handled by all `MusicSource`s
// MARK: - MusicSourceError
public enum MusicSourceError: Error {
    case none
}

/// Basic default keys for music sources
public struct SettingsKey {
    public static let address = "address";
    public static let port = "port";
    public static let directory = "directory";
}

// MARK: - MusicSource
/// The protocol for a music source azusa can connect to
public protocol MusicSource {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var settings : [String : Any] { get set };
    var eventManager : EventManager { get };
    
    
    // MARK: - Methods
    
    // MARK: - Connection
    
    /// Starts up the connection to this music player backend and calls the given completion handler upon finishing(if given)
    ///
    /// - Parameter completionHandler: The closure to call when the connection function finishes, passed if it was successful(optional)
    func connect(_ completionHandler : ((Bool, MusicSourceError?) -> Void)?);
    
    
    // MARK: - Player
    
    /// Gets the current `PlayerStatus` of this music player
    ///
    /// - Parameter completionHandler: The completion handler to call with the retrieved `PlayerStatus`
    func getPlayerStatus(_ completionHandler : @escaping ((PlayerStatus, MusicSourceError?) -> Void));
    
    /// Gets the elapsed time and duration of the current playing song, used for updating progress bars and similar
    ///
    /// - Parameter completionHandler: The completion handler for the request, passed the elapsed time of the current song in seconds
    func getElapsed(_ completionHandler : @escaping ((Int, MusicSourceError?) -> Void));
    
    /// Seeks to `to` in the current playing song
    ///
    /// - Parameters:
    ///   - to: The time in seconds to skip to
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func seek(to : Int, completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Seeks to `to` in the song at `trackPosition` in the queue
    ///
    /// - Parameters:
    ///   - to: The time in seconds to skip to
    ///   - trackPosition: The position of the track in the queue to jump to
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func seek(to : Int, trackPosition : Int, completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Toggles the paused state of this music player
    ///
    /// - Parameters:
    ///   - completionHandler: The completion handler to call when the operation finishes(optional), passed the paused state that was set
    func togglePaused(completionHandler : ((Bool, MusicSourceError?) -> Void)?);
    
    /// Sets the paused state of this music player
    ///
    /// - Parameters:
    ///   - paused: The value to set paused to
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func setPaused(_ paused : Bool, completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Stops playback for this music player
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    func stop(completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Skips to the next song in the queue
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    func skipNext(completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Skips to the previous song in the queue
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    func skipPrevious(completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Sets the volume of this music player to the given value
    ///
    /// - Parameters:
    ///   - volume: The volume to set
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func setVolume(to volume : Int, completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Adds the given volume to the current volume
    ///
    /// - Parameters:
    ///   - volume: The value to add to the volume, relative to the current volume(-100 to 100)
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func setRelativeVolume(to volume : Int, completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Sets the repeat mode of this source to the given mode
    ///
    /// - Parameters:
    ///   - mode: The mode to set to
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func setRepeatMode(to mode : RepeatMode, completionHandler : ((MusicSourceError?) -> Void)?);
    
    
    // MARK: - Queue
    
    /// Gets the current queue
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes, passed an array of `Song`s for the queue and the position of the current song in the queue(defaults to -1 if no song is playing)
    func getQueue(completionHandler : @escaping (([Song], Int, MusicSourceError?) -> Void));
    
    /// Plays the given song if it's in the queue
    ///
    /// - Parameters:
    ///   - song: The song to play
    ///   - completionHandler: The completion handler to call when the operation finishes(optional), passed the song that was played(nil if `song` was not in the queue)
    func playSongInQueue(_ song : Song, completionHandler : ((Song?, MusicSourceError?) -> Void)?);
    
    /// Removes the given `Song`s from the queue
    ///
    /// - Parameters:
    ///   - songs: The `Song`s to remove
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func removeFromQueue(_ songs : [Song], completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Moves the given `Song`s in the queue to after the current song(do not use this for adding songs to the queue after the current song, only move queued songs)
    ///
    /// - Parameters:
    ///   - songs: The `Song`s to move to after the current song
    ///   - completionHandler: The completion handler to call when the operation finishes(optional)
    func moveAfterCurrent(_ songs : [Song], completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Shuffles the current queue
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    func shuffleQueue(completionHandler : ((MusicSourceError?) -> Void)?);
    
    /// Clears the current queue
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    func clearQueue(completionHandler : ((MusicSourceError?) -> Void)?);
    
    
    // MARK: - Initialization and Deinitialization
    
    init(settings : [String : Any]);
}
