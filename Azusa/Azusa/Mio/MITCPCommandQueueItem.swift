//
//  MITCPCommandQueueItem.swift
//  Azusa
//
//  Created by Ushio on 11/27/16.
//

import Foundation

/// Represents an item in the MITCPCommunications command queue
class MITCPCommandQueueItem {
    
    /// Variables
    
    /// The completion handler for the command if no output is wanted
    var noOutputCompletionHandler : (() -> ())? = nil;
    
    /// The completion handler for the command if output is wanted, called with the output of the command
    var outputCompletionHandler : ((String) -> ())? = nil;
    
    /// Does the completion handler for this command want output?
    var wantsOutput : Bool = true;
    
    /// The tag for this item when putting it through CocoaAsyncSocket functions
    var tag : MITCPTag = .commandOutput;
    
    /// The command to run
    var command : String = "";
    
    var debugDescription : String {
        return "\(self): \"\(command)\" \((wantsOutput) ? "with output" : "without output")";
    }
    
    
    /// Init
    
    // Init with a command, tag and completion handler
    init(command : String, completionHandler : ((String) -> ())?, tag : MITCPTag) {
        self.command = command;
        self.outputCompletionHandler = completionHandler;
        self.wantsOutput = true;
        self.tag = tag;
    }
    
    init(command : String, completionHandler : (() -> ())?, tag : MITCPTag) {
        self.command = command;
        self.noOutputCompletionHandler = completionHandler;
        self.wantsOutput = false;
        self.tag = tag;
    }
}
