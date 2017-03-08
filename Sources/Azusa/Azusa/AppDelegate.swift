//
//  AppDelegate.swift
//  Azusa
//
//  Created by Ushio on 2/8/17.
//

import Cocoa
import Yui

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.global.load();
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Preferences.global.save();
    }
}
