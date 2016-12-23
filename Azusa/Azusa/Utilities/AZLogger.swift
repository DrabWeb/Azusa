//
//  AZLogger.swift
//  Azusa
//
//  Created by Ushio on 12/7/16.
//

import Foundation

/// Levels of logging available to AZLogger
enum AZLoggerLevel: Int {
    /// Don't log anything
    case none = 0;
    
    /// The regular amount of logging
    case regular = 1;
    
    /// High logging
    case high = 2;
    
    /// Full logging
    case full = 3;
}

/// The class for managing logging in Azusa
struct AZLogger {
    // MARK: - Properties
    
    /// All the output of the application so far
    static var output : String = "";
    
    /// The current logging level of the application
    static var level : AZLoggerLevel = AZLoggerLevel.regular {
        didSet {
            print("AZLogger: Changed logging level to \(self.level)");
        }
    };
    
    
    // MARK: - Functions
    
    /// Logs the given object, with the given level
    ///
    /// - Parameters:
    ///   - object: The object to log
    ///   - level: The level this print should be
    static func log(_ object : Any, level : AZLoggerLevel = .regular) {
        /// The date formatter for the print timestamp
        let timestampDateFormatter : DateFormatter = DateFormatter();
        
        // Set `timestampDateFormatter`'s format
        timestampDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS";
        
        /// The timestamp for the print message
        let timestamp : String = timestampDateFormatter.string(from: Date());
        
        // Append the object to log to 'output'
        self.output.append("\(timestamp) Azusa: \(object)\n");
        
        // Only print if we are in a debug build
        #if DEBUG
            // If the level given is less than or equal to the current logging level...
            if(level.rawValue <= self.level.rawValue) {
                // Print the object
                print("\(timestamp) Azusa: \(object)");
            }
        #endif
    }
    
    /// Writes all the log output to the given file
    ///
    /// - Parameter file: The file to write the output to
    static func saveTo(file : String) {
        AZLogger.log("AZLogger: Saving all log output to \"\(file)\"");
        
        do {
            // Write the output to the given file
            try self.output.write(toFile: file, atomically: true, encoding: String.Encoding.utf8);
        }
        catch let error as NSError {
            AZLogger.log("AZLogger: Error saving log file to \"\(file)\", \(error.localizedDescription)");
        }
    }
}
