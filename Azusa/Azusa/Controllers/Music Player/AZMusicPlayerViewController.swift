//
//  AZMusicPlayerViewController.swift
//  Azusa
//
//  Created by Ushio on 12/10/16.
//

import Foundation
import AppKit

/// The view controller for a music player in Azusa
class AZMusicPlayerViewController: NSSplitViewController, NSToolbarDelegate {
    
    // MARK: - Properties
    
    /// The window for this view controller
    var window : NSWindow? = nil;
    
    
    // MARK: - Toolbar Items
    
    /// The toolbar button for skipping to the previous song
    var toolbarSkipPreviousButton: NSButton? = nil;
    
    /// The toolbar button for pausing/playing
    var toolbarPausePlayButton: NSButton? = nil;
    
    /// The toolbar button for skipping to the next song
    var toolbarSkipNextButton: NSButton? = nil;
    
    /// The toolbar slider for controlling the volume
    var toolbarVolumeSlider: NSSlider? = nil;
    
    /// The `AZToolbarStatusView` item for the toolbar of this music player
    var toolbarStatusItem : AZToolbarStatusView? = nil;
    
    /// The toolbar button for displaying the queue popup
    var toolbarQueueButton: NSButton? = nil;
    
    /// The toolbar search field for searching for songs
    var toolbarSearchField: NSSearchField? = nil;
    
    
    // MARK: - Toolbar Actions
    
    /// Called when the user presses `toolbarSkipPreviousButton`
    @IBAction func toolbarSkipPreviousPressed(sender : NSButton) {
        
    }
    
    /// Called when the user presses `toolbarPausePlayButton`
    @IBAction func toolbarPausePlayPressed(sender : NSButton) {
        
    }
    
    /// Called when the user presses `toolbarSkipNextButton`
    @IBAction func toolbarSkipNextPressed(sender : NSButton) {
        
    }
    
    /// Called when the user changes `toolbarVolumeSlider`
    @IBAction func toolbarVolumeSliderChanged(sender : NSSlider) {
        
    }
    
    /// Called when the user presses `toolbarQueueButton`
    @IBAction func toolbarQueuePressed(sender : NSButton) {
        
    }
    
    /// Called when text is entered into `toolbarSearchField`
    @IBAction func toolbarSearchFieldEntered(sender : NSSearchField) {
        
    }
    
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Run setup
        self.setup();
    }
    
    /// Displays the given `AZPlayerStatus` in the toolbar of this music player
    ///
    /// - Parameter status: The `AZPlayerStatus` to display
    func display(status : AZPlayerStatus) {
        AZLogger.log("AZMusicPlayerViewController: Displaying status \(status)", level: .full);
        
        // Update the toolbar items
        self.toolbarPausePlayButton?.state = ((status.playingState == .playing) ? 1 : 0);
        self.toolbarVolumeSlider?.intValue = Int32(status.volume);
        
        // Display `status` in `toolbarStatusItem`
        self.toolbarStatusItem?.display(status: status);
    }
    
    override func viewWillAppear() {
        super.viewWillAppear();
        
        // Get all the toolbar items
        for(_, currentItem) in self.window!.toolbar!.items.enumerated() {
            switch(currentItem.itemIdentifier) {
                case "Previous":
                    self.toolbarSkipPreviousButton = (currentItem.view as! NSButton);
                    break;
                
                case "PausePlay":
                    self.toolbarPausePlayButton = (currentItem.view as! NSButton);
                    break;
                
                case "Next":
                    self.toolbarSkipNextButton = (currentItem.view as! NSButton);
                    break;
                
                case "Volume":
                    self.toolbarVolumeSlider = (currentItem.view as! NSSlider);
                    break;
                
                case "Status":
                    self.toolbarStatusItem = (currentItem.view as! AZToolbarStatusView);
                    break;
                
                case "Queue":
                    self.toolbarQueueButton = (currentItem.view as! NSButton);
                    break;
                
                case "Search":
                    self.toolbarSearchField = (currentItem.view as! NSSearchField);
                    break;
                
                default:
                    break;
            }
        }
    }
    
    /// Sets up this view controller(styling, init, etc.)
    func setup() {
        // Get the window of this view controller
        self.window = NSApp.windows.last!;
        
        // Style the window
        self.window!.styleMask.insert(NSWindowStyleMask.fullSizeContentView);
        self.window!.titleVisibility = .hidden;
        self.window!.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
    }
}
