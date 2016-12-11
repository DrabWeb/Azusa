//
//  AppDelegate.swift
//  Azusa
//
//  Created by Ushio on 12/7/16.
//

import Cocoa
import MPD

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
        AZLogger.log("Add to beginning of queue: \(mpd.addToQueue(songs: mpd.searchForSongs("team skull", within: MPD_TAG_UNKNOWN, exact: false)))");
        AZLogger.log("Add to beginning of queue: \(mpd.addToQueue(song: mpd.searchForSongs("team skull", within: MPD_TAG_UNKNOWN, exact: false)[0], at: 0))");
        AZLogger.log("All songs in the mikgazer vol. 1 album: \(mpd.getAllSongsForAlbum(album: AZAlbum(name: "mikgazer vol.1")))");
        AZLogger.log("All albums by きのこ帝国: \(mpd.getAllAlbumsForArtist(artist: AZArtist(name: "きのこ帝国")))");
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
