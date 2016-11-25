//
//  MITCPCommunications.swift
//  Azusa.Mio
//
//  Created by Ushio on 11/22/16.
//

import Foundation
import CocoaAsyncSocket

/// The different tags for 'GCDAsyncSocket' requests in 'MITCPCommunications'
enum MITCPTags : Int {
    /// The tag for write requests made from 'outputOf'
    case commandOutput
}

/// The class for making TCP connections and requests to MPD
class MITCPCommunications : NSObject, GCDAsyncSocketDelegate {
    
    /// Variables
    
    /// The address of the host for the MPD server
    var host : String = "";
    
    /// The port of the MPD server on 'host'
    var port : Int = -1;
    
    /// The socket for sending/receiving data from the MPD TCP server
    var socket : GCDAsyncSocket? = nil;
    
    /// The last set completion handler for 'connect'
    private var connectionCompletionHandler : ((GCDAsyncSocket) -> ())? = nil;
    
    /// The last set completion handler for 'outputOf'
    private var outputCompletionHandler : ((String) -> ())? = nil;
    
    
    /// Functions
    
    /// Creates the TCP socket connection to the MPD server
    func connect(completionHandler : ((GCDAsyncSocket) -> ())?) {
        // If the host and port are set...
        if(host != "" && port != -1) {
            // Create the socket
            socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main);
            
            // Print what server we are connecting to
            print("MITCPCommunications: Connecting to \(host):\(port)...");
            
            do {
                // Connect to the server with a timeout of 10
                try socket!.connect(toHost: host, onPort: UInt16(port), withTimeout: TimeInterval(10));
                
                // Set connectionCompletionHandler
                connectionCompletionHandler = completionHandler;
            }
            catch let error as NSError {
                // Print the error to the log
                print("MITCPCommunications: Error connecting to \(host):\(port), \(error.localizedDescription)");
            }
        }
    }
    
    /// Calls the completion handler with the output of the given MPD command
    func outputOf(command : String, completionHandler : ((String) -> ())?) {
        // Set outputCompletionHandler
        outputCompletionHandler = completionHandler;
        
        // Print what command we are running
        print("MITCPCommunications: Getting output of command \"\(command)\"");
        
        // Write the command to the socket
        socket?.write("\(command)\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: MITCPTags.commandOutput.rawValue);
    }
    
    
    /// Delegate Methods
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        // Print the tag that was used to write the data
        print("MITCPCommunications: Data was written with tag \"\(tag)\"");
        
        // Read all the data in the MPD output
        sock.readData(to: "\nOK".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: tag);
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        // Print that we read the data and with what tag
        print("MITCPCommunications: Read data written with tag \"\(tag)\"");
        
        /// The string from 'data'
        let dataString : String = String(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!);
        
        // If the tag is MITCPTags.commandOutput(meaning we want to pass 'dataString' to the completion handler of 'outputOf')...
        if(tag == MITCPTags.commandOutput.rawValue) {
            // Call the completion handler with 'dataString'
            outputCompletionHandler?(dataString);
            
            // Clear outputCompletionHandler
//            outputCompletionHandler = nil;
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        // Print that the connection was made
        print("MITCPCommunications: Connected to \(host):\(port)");
        
        // Call connectionCompletionHandler
        self.connectionCompletionHandler?(sock);
        
        // Clear connectionCompletionHandler
//        connectionCompletionHandler = nil;
    }
    
    
    /// Init
    
    // Init with a host and port
    init(host : String, port : Int) {
        self.host = host;
        self.port = port;
        self.socket = nil;
    }
    
    // Blank init
    override init() {
        super.init();
        
        self.host = "";
        self.port = -1;
        self.socket = nil;
    }
}
