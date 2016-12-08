//
//  MITCPCommandQueueItem.swift
//  Azusa
//
//  Created by Ushio on 12/6/16.
//

import Foundation

/// Represents an item in the command queue of an MITCP object
class MITCPCommandQueueItem {
    /// The command to run
    var command : String = "";
    
    /// The completion handler for this command, passed the output of the command and if there was an error the error message
    var completionHandler : ((String, String?) -> ())? = nil;
    
    /// Performs this command queue item with the given output and error(optional)
    ///
    /// - Parameters:
    ///   - output: The output to run the completion handler with
    ///   - error: The error to run the completion handler with(optional)
    func perform(with output : String, error : String?) {
        // Perform the completion handler
        self.completionHandler?(output, error);
    }
    
    init(command : String, completionHandler : ((String, String?) -> ())?) {
        self.command = command;
        self.completionHandler = completionHandler;
    }
}
