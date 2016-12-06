//
//  MIMPD.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/5/16.
//

import Foundation

/// The AZMusicPlayer extension for MPD in Azusa
class MIMPD : NSObject, AZMusicPlayer {
    /// The event subscriber for this music player
    var eventSubscriber : AZEventSubscriber {
        return self._eventSubscriber;
    }
    
    /// The event subscriber object for this music player
    private var _eventSubscriber : AZEventSubscriber = AZEventSubscriber();
    
    /// The MITCP object to use for interacting with MPD
    var tcp : MITCP = MITCP();
    
    /// The host of the MPD server this object is to connect to
    var serverHost : String = "127.0.0.1";
    
    /// The port of the MPD server this object is to connect to
    var serverPort : Int = 6600;
    
    /// The music directory of the MPD server this object is to connect to
    var musicDirectory : String = "";
    
    /// Starts up the connection to MPD and calls the given completion handler upon finishing(if given)
    ///
    /// - Parameter completionHandler: The closure to call when the connection finishes successfully(optional)
    func connect(_ completionHandler : (() -> ())?) {
        // Set `tcp`'s MPD object
        self.tcp.mpd = self;
        
        // Connect the TCP socket
        self.tcp.connect({
            // Emit the connect event
            self._eventSubscriber.emit(event: .connect);
            
            // Call the completion handler
            completionHandler?();
        });
    }
    
    init(host : String, port : Int, musicDirectory : String) {
        self.serverHost = host;
        self.serverPort = port;
        self.musicDirectory = musicDirectory;
        
        // Make sure there is a trailing slash on the music directory
        if(!self.musicDirectory.hasSuffix("/")) {
            self.musicDirectory = self.musicDirectory + "/";
        }
    }
    
    override init() {
        super.init();
        
        self.serverHost = "127.0.0.1";
        self.serverPort = 6600;
        self.musicDirectory = "";
    }
}
