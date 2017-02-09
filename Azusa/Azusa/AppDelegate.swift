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
        let dateFormatter : DateFormatter = DateFormatter();
        dateFormatter.dateFormat = "Y-M-d";
        savePanel.nameFieldStringValue = "azusa.\(dateFormatter.string(from: Date())).log";
        
        // Run the modal, and if the user clicks save...
        if(Bool(savePanel.runModal() as NSNumber)) {
            // Save the log output to the chosen file
            AZLogger.saveTo(file: savePanel.url!.absoluteString.replacingOccurrences(of: "file://", with: ""));
        }
    }
    
    /// View/Open Queue ⌥⌘U
    @IBOutlet weak var menuItemOpenQueue: NSMenuItem!
    
    /// Controls/Pause/Play Space
    @IBOutlet weak var menuItemPausePlay: NSMenuItem!
    
    /// Controls/Stop ⌘.
    @IBOutlet weak var menuItemStop: NSMenuItem!
    
    /// Controls/Next ⌘⇢
    @IBOutlet weak var menuItemNext: NSMenuItem!
    
    /// Controls/Previous ⌘⇠
    @IBOutlet weak var menuItemPrevious: NSMenuItem!
    
    /// Controls/Increase Volume ⌘⇡
    @IBOutlet weak var menuItemIncreaseVolume: NSMenuItem!
    
    /// Controls/Decrease Volume ⌘⇣
    @IBOutlet weak var menuItemDecreaseVolume: NSMenuItem!
    
    /// Controls/Queue/Play First Song ⇧⌘1
    @IBOutlet weak var menuItemPlayFirstSong: NSMenuItem!
    
    /// Controls/Queue/Shuffle Queue ⌥⌘S
    @IBOutlet weak var menuItemShuffleQueue: NSMenuItem!
    
    /// Controls/Queue/Clear Queue ⇧⌘C
    @IBOutlet weak var menuItemClearQueue: NSMenuItem!
    
    
    // MARK: Delegate Methods

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Setup the menu items
        setupMenuItems();
    }
    
    /// Sets up the actions for all the menu items
    func setupMenuItems() {
        // Setup the menu items
        menuItemOpenQueue.action = #selector(AZMusicPlayerViewController.openQueuePopup);
        menuItemPausePlay.action = #selector(AZMusicPlayerViewController.togglePaused);
        menuItemStop.action = #selector(AZMusicPlayerViewController.stopPlayback);
        menuItemNext.action = #selector(AZMusicPlayerViewController.skipNext);
        menuItemPrevious.action = #selector(AZMusicPlayerViewController.skipPrevious);
        menuItemIncreaseVolume.action = #selector(AZMusicPlayerViewController.increaseVolume);
        menuItemDecreaseVolume.action = #selector(AZMusicPlayerViewController.decreaseVolume);
        menuItemPlayFirstSong.action = #selector(AZMusicPlayerViewController.jumpToFirstSong);
        menuItemShuffleQueue.action = #selector(AZMusicPlayerViewController.shuffleQueue);
        menuItemClearQueue.action = #selector(AZMusicPlayerViewController.clearQueue);
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
}
