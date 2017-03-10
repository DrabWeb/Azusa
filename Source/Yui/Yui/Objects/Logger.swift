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
    
    /// Shows an error alert with the given message and logs it
    ///
    /// - Parameter object: The object to log
    public static func logError(_ object : Any) {
        Logger.log(object);
        
        let alert = NSAlert();
        alert.messageText = "An error has occured";
        alert.informativeText = "\(object)";
        alert.icon = NSImage(named: "NSCaution");
        alert.addButton(withTitle: "Report");
        alert.addButton(withTitle: "OK");
        
        if alert.runModal() == NSAlertFirstButtonReturn {
            if (Logger.promptSave()) {
                NSWorkspace.shared().open(URL(string: "https://github.com/DrabWeb/Azusa/issues/new")!);
            }
        }
    }
    
    /// Prompts the user for a place to save the log
    public static func promptSave() -> Bool {
        var p = NSSavePanel();
        p.title = "Save Log";
        p.nameFieldStringValue = "azusa.txt";
        
        if p.runModal() == NSModalResponseOK {
            Logger.saveTo(file: p.url!.absoluteString.removingPercentEncoding!.replacingOccurrences(of: "file://", with: ""));
            return true;
        }
        
        return false;
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
            Logger.logError("Logger: Error saving log file to \"\(file)\", \(error.localizedDescription)");
        }
    }
}
