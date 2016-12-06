//
//  MITCP.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/6/16.
//

import Foundation
import CocoaAsyncSocket

/// The class for interfacing with MPD's TCP protocol
class MITCP : NSObject, GCDAsyncSocketDelegate {
    /// The MIMPD object this MITCP object is bound to(optional)
    var mpd : MIMPD? = nil;
    
    /// The delegate to use for `socket`(it only works if I store it in here), set by `connect(_ completionHandler:)`
    var socketDelegate : GCDAsyncSocketDelegate? = nil;
    
    /// The socket for TCP connection/communication to MPD
    var socket : GCDAsyncSocket? = nil;
    
    /// The host of the MPD server this socket will connect to
    var serverHost : String = "127.0.0.1";
    
    /// The port of the MPD server this socket will connect to
    var serverPort : Int = 6600;
    
    /// The last completion handler from connect(_ completionHandler:)
    private var lastConnectionCompletionHandler : (() -> ())? = nil;
    
    /// Connects to the TCP socket and calls the completion handler upon successful connection
    ///
    /// - Parameter completionHandler: The closure to call when the connection is successful(optional)
    func connect(_ completionHandler : (() -> ())?) {
        // If the host and port are set...
        if(self.serverHost != "" && self.serverPort >= 0) {
            // Set `socketDelegate`
            self.socketDelegate = self;
            
            if(self.socket == nil) {
                // Create the socket
                self.socket = GCDAsyncSocket(delegate: self.socketDelegate, delegateQueue: DispatchQueue.main);
            }
            
            // Set the last connection completion handler
            self.lastConnectionCompletionHandler = completionHandler;
            
            // Print what server we are connecting to
            AZLogger.log("MITCP: Connecting to \(serverHost):\(serverPort)...");
            
            do {
                // Connect the socket
                try self.socket!.connect(toHost: serverHost, onPort: UInt16(serverPort), withTimeout: TimeInterval(10));
            }
            catch let error as NSError {
                AZLogger.log("MITCP: Error connecting to \(serverHost):\(serverPort), \(error.description)");
            }
        }
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        AZLogger.log("MITCP: Disconnected from \(serverHost):\(serverPort) with error \"\(err!.localizedDescription)\"(\((err! as NSError).code))");
        
        // Emit the disconnect event
        mpd?.eventSubscriber.emit(event: .disconnect);
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        AZLogger.log("MITCP: Connected to \(host):\(port)");
        
        // Call the completion handler
        self.lastConnectionCompletionHandler?();
    }
}
