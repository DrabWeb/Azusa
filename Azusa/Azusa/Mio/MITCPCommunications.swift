//
//  MITCPCommunications.swift
//  Azusa.Mio
//
//  Created by Ushio on 11/22/16.
//

import Foundation
import CocoaAsyncSocket

/// The different tags for 'GCDAsyncSocket' requests in 'MITCPCommunications'
enum MITCPTag : Int {
    /// The tag for write requests made from 'outputOf'
    case commandOutput = 0

    /// The tag for running a command without capturing output
    case command = 1
    
    /// The tag for the event listener
    case eventListener = 2
    
    /// The tag for the progress getter
    case progress = 3
}

/// The different MPD idle events that are supported
enum MIMPDEvent : String {
    /// The song database has been modified after 'update'
    case database = "database"
    
    /// A database update has started or finished. If the database was modified during the update, the database event is also emitted
    case update = "update"
    
    /// A stored playlist has been modified, renamed, created or deleted
    case storedPlaylist = "stored_playlist"
    
    /// The current playlist has been modified
    case playlist = "playlist"
    
    /// The player has been started, stopped or seeked
    case player = "player"
    
    /// The volume has been changed
    case mixer = "mixer"
    
    /// An audio output has been enabled or disabled
    case output = "output"
    
    /// Options like repeat, random, crossfade, replay gain
    case options = "options"
    
    /// The sticker database has been modified.
    case sticker = "sticker"
    
    /// A client has subscribed or unsubscribed to a channel
    case subscription = "subscription"
    
    /// A message was received on a channel this client is subscribed to; this event is only emitted when the queue is empty
    case message = "message"
}

/// The class for making TCP connections and requests to MPD
class MITCPCommunications : NSObject, GCDAsyncSocketDelegate {
    
    /// Variables
    
    /// The address of the host for the MPD server
    var host : String = "";
    
    /// The port of the MPD server on 'host'
    var port : Int = -1;
    
    /// The socket for sending/receiving commands and their output from the MPD TCP server
    var commandSocket : GCDAsyncSocket? = nil;
    
    /// The socket for catching MPD events
    var eventSocket : GCDAsyncSocket? = nil;
    
    /// The socket for getting the progress of the current song from MPD
    var progressSocket : GCDAsyncSocket? = nil;
    
    /// Has the event idle loop started yet?
    var eventIdleLoopStarted : Bool = false;
    
    /// All the event subscribers
    var eventSubscribers : [MIMPDEventSubscriber] = [];
    
    /// The closure to call for progres updates, passed the current song progress in seconds
    var progressListener : ((Int) -> ())? = nil;
    
    /// The completion handlers from 'connect'
    private var connectionCompletionHandlers : [((GCDAsyncSocket) -> ())] = [];
    
    /// The completion handlers from 'outputOf'
    private var outputCompletionHandlers : [(String) -> ()] = [];
    
    /// The completion handlers from 'run'
    private var runCommandCompletionHandlers : [() -> ()] = [];
    
    
    /// Functions
    
    /// Creates the TCP socket connection to the MPD server
    func connect(completionHandler : ((GCDAsyncSocket) -> ())?) {
        // If the host and port are set...
        if(host != "" && port != -1) {
            // Create the socket
            if(self.commandSocket == nil) {
                self.commandSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main);
            }
            
            // Create the event socket
            if(self.eventSocket == nil) {
                self.eventSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main);
            }
            
            // Create the progress socket
            if(self.progressSocket == nil) {
                self.progressSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main);
            }
            
            // Print what server we are connecting to
            print("MITCPCommunications: Connecting to \(host):\(port)...");
            
            do {
                // Connect to the server without a timeout
                if(!commandSocket!.isConnected) {
                    try commandSocket!.connect(toHost: host, onPort: UInt16(port), withTimeout: TimeInterval(-1));
                }
                
                if(!eventSocket!.isConnected) {
                    try eventSocket!.connect(toHost: host, onPort: UInt16(port), withTimeout: TimeInterval(-1));
                }
                
                if(!progressSocket!.isConnected) {
                    try progressSocket!.connect(toHost: host, onPort: UInt16(port), withTimeout: TimeInterval(-1));
                }
                
                // Add the completion handler to 'connectionCompletionHandlers'
                if(completionHandler != nil) {
                    connectionCompletionHandlers.append(completionHandler!);
                }
            }
            catch let error as NSError {
                // Print the error to the log
                print("MITCPCommunications: Error connecting to \(host):\(port), \(error.localizedDescription)");
            }
        }
    }
    
    /// Calls the completion handler with the output of the given MPD command, and logs the command if 'log' is true
    func outputOf(command : String, log : Bool, completionHandler : ((String) -> ())?) {
        // Add the completion handler to 'outputCompletionHandlers'
        if(completionHandler != nil) {
            outputCompletionHandlers.append(completionHandler!);
        }
        
        // If we said to log the command...
        if(log) {
            // Print what command we are running
            print("MITCPCommunications: Getting output of command \"\(command)\"");
        }
        
        /// Do we need to connect to the socket?
        var needsConnect : Bool = false;
        
        // If the command socket isn't nil...
        if(commandSocket != nil) {
            // If the command socket is connected...
            if(commandSocket!.isConnected) {
                // Write the command to the command socket
                commandSocket!.write("\(command)\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: MITCPTag.commandOutput.rawValue);
            }
                // If the socket is disconnected...
            else {
                // Say we need to connect
                needsConnect = true;
            }
        }
            // If the socket is nil...
        else {
            // Say we need to connect
            needsConnect = true;
        }
        
        // If we need to connect to the socket...
        if(needsConnect) {
            // Connect to the socket
            self.connect(completionHandler: { connectedSocket in
                // Write the command to the socket
                self.commandSocket!.write("\(command)\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: MITCPTag.commandOutput.rawValue);
            });
        }
    }
    
    /// Calls the completion handler when the given command finishes
    func run(command : String, log : Bool, completionHandler : (() -> ())?) {
        if(completionHandler != nil) {
            // Add the completion handler to 'runCommandCompletionHandlers'
            runCommandCompletionHandlers.append(completionHandler!);
        }
        
        // If we said to log the command...
        if(log) {
            // Print what command we are running
            print("MITCPCommunications: Running command \"\(command)\"");
        }
        
        // Write the command to the socket
//        socket?.write("\(command)\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: MITCPTag.command.rawValue);
        
        /// Do we need to connect to the socket?
        var needsConnect : Bool = false;
        
        // If the command socket isn't nil...
        if(commandSocket != nil) {
            // If the command socket is connected...
            if(commandSocket!.isConnected) {
                // Write the command to the socket
                commandSocket!.write("\(command)\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: MITCPTag.command.rawValue);
            }
            // If the socket is disconnected...
            else {
                // Say we need to connect
                needsConnect = true;
            }
        }
            // If the socket is nil...
        else {
            // Say we need to connect
            needsConnect = true;
        }
        
        // If we need to connect to the socket...
        if(needsConnect) {
            // Connect to the socket
            self.connect(completionHandler: { connectedSocket in
                // Write the command to the socket
                self.commandSocket!.write("\(command)\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: MITCPTag.command.rawValue);
            });
        }
    }
    
    /// Subscribes to the given events, 'subscriber' gets called with the event type when the event fires, returns the subscriber object
    func subscribeTo(events : [MIMPDEvent], with subscriber : @escaping ((MIMPDEvent) -> ())) -> MIMPDEventSubscriber {
        print("MITCPCommunications: Subscribing to events \(events) with \(subscriber)");
        
        /// The event subscriber created from the passed values
        let subscriptionObject : MIMPDEventSubscriber = MIMPDEventSubscriber(eventHandler: subscriber, subscriptions: events);
        
        // Add the subscription
        eventSubscribers.append(subscriptionObject);
        
        // If the idle loop isn't running yet...
        if(!eventIdleLoopStarted) {
            // Start it
            eventSocket?.write("idle\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: MITCPTag.eventListener.rawValue);
            
            // Say the loop has started
            eventIdleLoopStarted = true;
        }
        
        // Return the subscriber object
        return subscriptionObject;
    }
    
    /// Removes the given subscription object from the subscribers
    func removeSubscription(_ subscriber : MIMPDEventSubscriber) {
        /// The index of the event subscriber to remove
        var removalIndex : Int = -1;
        
        // For every event subscriber...
        for(currentIndex, currentSubscriber) in eventSubscribers.enumerated() {
            // If the current event subscriber is equal to the given subscriber...
            if(currentSubscriber.equals(subscriber)) {
                // Set 'removalIndex'
                removalIndex = currentIndex;
            }
        }
        
        // If removal index isn't -1...
        if(removalIndex != -1) {
            print("MITCPCommunications: Removing \"\(subscriber.subscriptions)\" event subscriber \"\(subscriber.uuid)\"");
            
            // Remove the event subscriber
            self.eventSubscribers.remove(at: removalIndex);
        }
    }
    
    /// Handles calling the given event(e.g. managing listeners)
    func handleEvent(event : MIMPDEvent) {
        print("MITCPCommunications: Received event \(event)");
        
        // For every event subscriber...
        for(_, currentSubscriber) in eventSubscribers.enumerated() {
            // If the subcriber's event is equal to the passed event...
            if(currentSubscriber.subscriptions.contains(event)) {
                // Call the subscriber's event handler
                currentSubscriber.eventHandler?(event);
            }
        }
    }
    
    
    /// Delegate Methods
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        /// The name of the socket that disconnected
        var socketName : String = "Unknown";
        
        // Switch on the socket and set the appropriate name
        if(sock == commandSocket) {
            socketName = "Command";
        }
        else if(sock == eventSocket) {
            socketName = "Event";
        }
        else if(sock == progressSocket) {
            socketName = "Progress";
        }
        
        print("MITCPCommunications: \(socketName) disconnected with error \"\(err!.localizedDescription)\"(\((err! as NSError).code))");
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        if(MITCPTag(rawValue: tag)! != .progress) {
            // Print the tag that was used to write the data
            print("MITCPCommunications: Data was written with tag \"Azusa.Mio.MITCPTag.\(MITCPTag(rawValue: tag)!)\"");
        }
        
        // If the socket is the main socket...
        if(sock == self.commandSocket) {
            // If the tag is the command output tag...
            if(tag == MITCPTag.commandOutput.rawValue) {
                // Read all the data in the MPD output
                commandSocket?.readData(to: "\nOK\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: tag);
            }
            // If the tag is the command tag..
            else if(tag == MITCPTag.command.rawValue) {
                if(runCommandCompletionHandlers.count > 0) {
                    // Run the completion handler
                    runCommandCompletionHandlers.removeFirst()();
                }
            }
        }
        // If the socket is the event socket...
        else if(sock == self.eventSocket) {
            // If the tag is the event listener tag...
            if(tag == MITCPTag.eventListener.rawValue) {
                // Read all the data in the MPD output
                eventSocket?.readData(to: "\nOK".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: tag);
            }
        }
        // If the socket is the progress socket...
        else if(sock == self.progressSocket) {
            // If the tag is the progress tag...
            if(tag == MITCPTag.progress.rawValue) {
                // Read all the data in the MPD output
                progressSocket?.readData(to: "\nOK".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: tag);
            }
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        /// The string from 'data'
        let dataString : String = String(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!);
        
        if(MITCPTag(rawValue: tag)! != .progress) {
            // Print that we read the data and with what tag
            print("MITCPCommunications: Read data written with tag \"Azusa.Mio.MITCPTag.\(MITCPTag(rawValue: tag)!)\"");
            
            print("MITCPCommunications: Read string \"\(dataString)\"");
        }
        
        // If the socket is the main socket...
        if(sock == self.commandSocket) {
            // If the tag is MITCPTag.commandOutput(meaning we want to pass 'dataString' to the completion handler of 'outputOf')...
            if(tag == MITCPTag.commandOutput.rawValue) {
                if(self.outputCompletionHandlers.first != nil) {
                    print("MITCPCommunications: Output completion handlers: \(self.outputCompletionHandlers)");
                    // Call and remove the completion handler with 'sock'
                    self.outputCompletionHandlers.removeFirst()(dataString);
                }
            }
        }
        // If the socket is the event socket...
        if(sock == self.eventSocket) {
            // If the tag is the event listener tag...
            if(tag == MITCPTag.eventListener.rawValue) {
                if(dataString.contains("changed: ")) {
                    /// The string of the event that occured
                    var eventString : String = dataString;
                    
                    // Parse out the event name
                    eventString = eventString.replacingOccurrences(of: "changed: ", with: "");
                    eventString = eventString.replacingOccurrences(of: "\nOK", with: "");
                    eventString = eventString.components(separatedBy: "\n")[1];
                    
                    /// The parsed event
                    let event : MIMPDEvent? = MIMPDEvent(rawValue: eventString);
                    
                    // If the event isn't nil...
                    if(event != nil) {
                        // Call the event handler with the event
                        self.handleEvent(event: event!);
                    }
                }
                
                // Call the idle command again so we get an infinite loop
                eventSocket?.write("idle\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: MITCPTag.eventListener.rawValue);
            }
        }
        // If the socket is the progress socket...
        else if(sock == self.progressSocket) {
            // If the tag is the progress tag...
            if(tag == MITCPTag.progress.rawValue) {
                /// The status object created
                let status : MIStatus = MIStatus(string: dataString);
                
                // Call the progress closure with the time elapsed(plus one because it's off for whatever reason)
                self.progressListener?(Int(status.timeElapsed));
                
                // Wait half a second(so we don't use up alot of power or anything)
                Timer.scheduledTimer(withTimeInterval: TimeInterval(0.5), repeats: false, block: { _ in
                    // Continue the loop
                    self.progressSocket!.write("status\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: MITCPTag.progress.rawValue);
                });
            }
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        // If the socket is the main socket...
        if(sock == self.commandSocket) {
            // Print that the connection was made
            print("MITCPCommunications: Connected to command socket \(host):\(port)");
            
            if(self.connectionCompletionHandlers.first != nil) {
                // Call and remove the completion handler
                self.connectionCompletionHandlers.removeFirst()(sock);
            }
        }
        // If the socket is the event socket...
        else if(sock == self.eventSocket) {
            // Print that the connection was made
            print("MITCPCommunications: Connected to event socket \(host):\(port)");
        }
        // If the socket is the progress socket...
        else if(sock == self.progressSocket) {
            // Print that the connection was made
            print("MITCPCommunications: Connected to progress socket \(host):\(port)");
            
            // Start the progress loop
            self.progressSocket!.write("status\n".data(using: String.Encoding.utf8)!, withTimeout: TimeInterval(-1), tag: MITCPTag.progress.rawValue);
        }
    }
    
    
    /// Init
    
    // Init with a host and port
    init(host : String, port : Int) {
        self.host = host;
        self.port = port;
        self.commandSocket = nil;
    }
    
    // Blank init
    override init() {
        super.init();
        
        self.host = "";
        self.port = -1;
        self.commandSocket = nil;
    }
}
