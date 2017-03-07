//
//  Logger.swift
//  Yui
//
//  Created by Ushio on 2/11/17.
//

import Foundation

public enum LoggingLevel: Int {
    case none, regular, high, full
}

public struct Logger {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public static var level : LoggingLevel = LoggingLevel.regular {
        didSet {
            Logger.log("Logger: Changed logging level to \(self.level)");
        }
    };
    
    // MARK: Private Properties
    
    private static var log : String = "";
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    /// Logs the given object, with the given level
    ///
    /// - Parameters:
    ///   - object: The object to log
    ///   - level: The level this print should be
    public static func log(_ object : Any, level : LoggingLevel = .regular) {
        let timestampDateFormatter : DateFormatter = DateFormatter();
        timestampDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS";
        let timestamp : String = timestampDateFormatter.string(from: Date());
        let message = "\(timestamp) Yui: \(object)";
        
        log.append("\(message)\n");
        
        // Only print if we are in a debug build
        #if DEBUG
            if(level.rawValue <= self.level.rawValue) {
                print(message);
            }
        #endif
    }
    
    /// Writes all the log output to the given file
    ///
    /// - Parameter file: The file to write the output to
    public static func saveTo(file : String) {
        Logger.log("Logger: Saving all log output to \"\(file)\"");
        
        do {
            try log.write(toFile: file, atomically: true, encoding: String.Encoding.utf8);
        }
        catch let error as NSError {
            Logger.log("Logger: Error saving log file to \"\(file)\", \(error.localizedDescription)");
        }
    }
}
