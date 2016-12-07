//
//  MITCP.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/6/16.
//

import Foundation
import CocoaAsyncSocket

/// The different tags used when transmitting data through TCP in MITCP
enum MITCPTag : Int {
    /// The tag used when sending commands to MPD
    case command = 0;
    
    /// The tag used when reading the actual output of a command
    case commandOutput = 1;
}

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
    
    /// The current command queue for this MITCP object
    var commandQueue : [MITCPCommandQueueItem] = [];
    
    /// Adds the given MITCPCommandQueueItem to the command queue
    ///
    /// - Parameter command: The command queue item to queue
    func addCommandToQueue(command : MITCPCommandQueueItem) {
        AZLogger.log("MITCP: Queueing command \"\(command.command)\"");
        
        /// Should the queue start from this add?
        let startQueue : Bool = commandQueue.isEmpty;
        
        // Add the command to the queue array
        commandQueue.append(command);
        
        // If we need to start the queue...
        if(startQueue) {
            // Start the queue
            self.queue();
        }
    }
    
    /// The lifecycle function of the command queue. Called to continue the queue after one finishes or if a command queue item is added and the queue isn't started
    private func queue() {
        AZLogger.log("MITCP: Running queue lifecycle function", level: .high);
        
        if(socket != nil) {
            if(commandQueue.count > 0) {
                // Write the command to the command socket
                socket!.write(commandQueue.first!.command.data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(10), tag: MITCPTag.command.rawValue);
                
                // Queue the output read
                socket!.readData(withTimeout: TimeInterval(-1), tag: MITCPTag.command.rawValue);
                socket!.readData(withTimeout: TimeInterval(1), tag: MITCPTag.commandOutput.rawValue);
            }
            else {
                AZLogger.log("MITCP: Failed to run queue because there are no queue items");
            }
        }
        else {
            AZLogger.log("MITCP: Failed to run queue because the command socket does not exist(run connect first)");
        }
    }
    
    /// Queues the given command for running and calls the completion handler upon command completion(if there is one)
    ///
    /// - Parameters:
    ///   - command: The command to run
    ///   - completionHandler: The closure to call after the command finishes running(optional), passed the output of the command and if there was an error the error message
    func run(command : String, with completionHandler : ((String, String?) -> ())?) {
        AZLogger.log("MITCP: Running command \"\(command)\"");
        
        // Queue the command
        self.addCommandToQueue(command: MITCPCommandQueueItem(command: command, completionHandler: completionHandler));
    }
    
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
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("New socket");
        
        self.socket = newSocket;
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        AZLogger.log("MITCP: Wrote data to command socket with tag \"MITCPTag.\(MITCPTag(rawValue: tag)!)\"", level: .high);
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        AZLogger.log("MITCP: Read data from command socket with tag \"MITCPTag.\(MITCPTag(rawValue: tag)!)\"", level: .high);
        
        /// The string from `data`
        let readString : String? = String(describing: NSString(data: data, encoding: String.Encoding.utf8.rawValue));
        
        if(readString != nil) {
            print(readString!);
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        
        print("\(tag) timed out after \(elapsed), read \(length)");
        
        return TimeInterval(0);
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        AZLogger.log("MITCP: Connected to \(host):\(port)");
        
        // Call the completion handler
        self.lastConnectionCompletionHandler?();
        
        // Run a testing command
        self.run(command: "status", with: { output, error in
            print("Command \"status\" completed with output \"\(output)\" and error \"\(error)\"");
        });
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        AZLogger.log("MITCP: Disconnected from \(serverHost):\(serverPort) with error \"\(err!.localizedDescription)\"(\((err! as NSError).code))");
        
        // Emit the disconnect event
        mpd?.eventSubscriber.emit(event: .disconnect);
    }
}
