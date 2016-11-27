//
//  AppDelegate.swift
//  Azusa
//
//  Created by Ushio on 11/22/16.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// The global preferences object
    var preferences : AZPreferences = AZPreferences();
    
    /// Azusa/Save Log
    @IBAction func saveLogMenuItemPressed(_ sender: Any) {
        /// The save panel for prompting where to save the log file to
        let savePanel : NSSavePanel = NSSavePanel();
        
        // Set the default filename
        savePanel.nameFieldStringValue = "log.txt";
        
        // Run the modal, and if the user clicks save...
        if(Bool(savePanel.runModal() as NSNumber)) {
            // Save the log output to the chosen file
            MILogger.saveTo(file: savePanel.url!.absoluteString.replacingOccurrences(of: "file://", with: ""));
        }
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // Set the logging level
        MILogger.level = .regular;
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
