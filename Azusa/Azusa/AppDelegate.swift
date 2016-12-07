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
            AZLogger.saveTo(file: savePanel.url!.absoluteString.replacingOccurrences(of: "file://", with: ""));
        }
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // Set the logging level
        AZLogger.level = .full;
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        /// The AZMusicPlayer for testing
        let musicPlayer : AZMusicPlayer = MIMPD(host: "127.0.0.1", port: 6600, musicDirectory: "/Volumes/Storage/macOS/Music/");
        
        // Connect to the music player
        musicPlayer.connect({
            print("Connected to music player!");
        });
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
