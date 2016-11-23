//
//  AZMusicPlayerViewController.swift
//  Azusa
//
//  Created by Ushio on 11/23/16.
//

import Cocoa

class AZMusicPlayerViewController: NSViewController {

    /// The main window of this view controller
    var musicPlayerWindow : NSWindow = NSWindow();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the window
        musicPlayerWindow = NSApplication.shared().windows.last!;
        
        // Style the window
        musicPlayerWindow.styleMask.insert(NSWindowStyleMask.fullSizeContentView);
        musicPlayerWindow.titlebarAppearsTransparent = true;
        musicPlayerWindow.titleVisibility = .hidden;
        musicPlayerWindow.standardWindowButton(.closeButton)?.superview?.superview?.removeFromSuperview();
        musicPlayerWindow.backgroundColor = NSColor(calibratedWhite: 0.08, alpha: 1);
    }
}
