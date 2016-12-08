//
//  AppDelegate.swift
//  Azusa
//
//  Created by Ushio on 12/7/16.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    // MARK: - Menu Items
    
    /// Azusa/Save Log
    @IBAction func menuItemSaveLog(_ sender: NSMenuItem) {
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
    
    
    // MARK: Delegate Methods

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let mpd : MIMPD = MIMPD(address: "127.0.0.1", port: 6600);
        
        AZLogger.log(mpd.connect());
        AZLogger.log(mpd.getStats().debugDescription);
        AZLogger.log(mpd.getPlayerStatus()!.debugDescription);
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
