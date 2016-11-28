//
//  MILogger.swift
//  Azusa.Mio
//
//  Created by Ushio on 11/26/16.
//

import Foundation

/// Levels of logging available to MILogger
enum MILoggerLevel : Int {
    // Don't log anything
    case none = 0
    
    // The regular amount of logging, info but nothing too verbose
    case regular = 2
    
    // More verbose but still keeping it clean
    case high = 3
    
    // Just log me up. Full on verbose
    case full = 4
}

/// The class for managing logging in Mio
struct MILogger {
    /// All the output of the application so far
    static var output : String = "";
    
    /// The current logging level of the application
    static var level : MILoggerLevel = MILoggerLevel.regular {
        didSet {
            // Print what level we are changing logging to
            print("MILogger: Changed logging level to \(self.level)");
        }
    };
    
    /// Logs the given object, with the given level
    static func log(_ object : Any, level : MILoggerLevel? = .regular) {
        /// The logging level from level, but defaults to regular if it's nil
        let loggingLevel : MILoggerLevel = (level != nil) ? level! : MILoggerLevel.regular;
        
        // Append the object to log to 'output'
        self.output.append("\(object)\n");
        
        // If the level given is less than or equal to the current logging level...
        if(loggingLevel.rawValue <= self.level.rawValue) {
            // Print the object
            print(object);
        }
    }
    
    /// Writes all the log output to the given file
    static func saveTo(file : String) {
        MILogger.log("MILogger: Saving all log output to \"\(file)\"");
        
        do {
            // Write the output to the given file
            try self.output.write(toFile: file, atomically: false, encoding: String.Encoding.utf8);
        }
        // If there is an error with saving the file...
        catch let error as NSError {
            // Print the error
            MILogger.log("MILogger: Error saving log file to \"\(file)\", \(error.localizedDescription)");
        }
    }
}
