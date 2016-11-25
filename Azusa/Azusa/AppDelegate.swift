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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
