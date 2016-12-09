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
        
        AZLogger.log("Connection was successful: \(mpd.connect())");
        AZLogger.log("Current song: \(mpd.getCurrentSong() ?? MISong.empty)");
        AZLogger.log("Database stats: \(mpd.getStats() ?? MIMPDStats())");
        AZLogger.log("Player status: \(mpd.getPlayerStatus() ?? MIMPDPlayerStatus())");
        AZLogger.log("Queue: \(mpd.getCurrentQueue())");
        AZLogger.log("All artists: \(mpd.getAllArtists())");
        AZLogger.log("All albums: \(mpd.getAllAlbums())");
        AZLogger.log("All genres: \(mpd.getAllGenres())");
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
