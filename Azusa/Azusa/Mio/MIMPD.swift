//
//  MIMPD.swift
//  Azusa.Mio
//
//  Created by Ushio on 11/24/16.
//

import Foundation
import CocoaAsyncSocket

/// The class for talking to an MPD server
class MIMPD {
    
    // Variables
    
    /// The address of this MPD server
    var serverAddress : String = "127.0.0.1";
    
    /// The port of this MPD server
    var serverPort : Int = 6600;
    
    /// The base music directory of this MPD server, append with a slash
    var musicDirectory : String = "";
    
    /// The TCP socket connection to this MPD server
    var socketConnection : MITCPCommunications = MITCPCommunications();
    
    
    // Functions
    
    /// Returns the current song
    func getCurrentSong(completionHandler : @escaping ((MISong?) -> ())) {
        if(socketConnection.socket != nil) {
            if(socketConnection.socket!.isConnected) {
                socketConnection.outputOf(command: "currentsong", completionHandler: { output in
                    /// The MISong from 'output'
                    let song : MISong? = MISong(string: output);
                    
                    // If the song is valid...
                    if(song!.valid) {
                        // Return the song
                        completionHandler(song!);
                    }
                        // If the song is invalid...
                    else {
                        // Return nil
                        completionHandler(nil);
                    }
                });
            }
            else {
                // Default to returning nil
                completionHandler(nil);
            }
        }
        else {
            // Default to returning nil
            completionHandler(nil);
        }
    }
    
    /// Connects to the MPD server, calls completionHandler on connect if it is set
    func connect(_ completionHandler : ((GCDAsyncSocket) -> ())?) {
        // Connect to the socket
        socketConnection.connect(completionHandler: completionHandler);
    }
    
    /// Calls connect(_ completionHandler:) with a nil completion handler
    func connect() {
        connect(nil);
    }
    
    
    /// Init
    
    // Init with a server address, port and music directory
    init(address : String, port : Int, musicDirectory : String) {
        self.serverAddress = address;
        self.serverPort = port;
        self.musicDirectory = musicDirectory;
        self.socketConnection = MITCPCommunications(host: self.serverAddress, port: self.serverPort);
    }
    
    // Blank init
    init() {
        self.serverAddress = "127.0.0.1";
        self.serverPort = 6600;
        self.musicDirectory = "";
        self.socketConnection = MITCPCommunications();
    }
}
