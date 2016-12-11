//
//  AZMusicPlayerViewController.swift
//  Azusa
//
//  Created by Ushio on 12/10/16.
//

import Foundation
import AppKit

/// The view controller for a music player in Azusa
class AZMusicPlayerViewController: NSViewController {
    
    // MARK: - Properties
    
    /// The window for this view controller
    var window : NSWindow? = nil;
    
    // MARK: - Toolbar Actions
    
    /// Called when text is entered into the search field
    @IBAction func toolbarSearchFieldEntered(sender : NSSearchField) {
        print("\"\(sender.stringValue)\"");
    }
    
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Run setup
        self.setup();
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
