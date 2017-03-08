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
    
    @IBOutlet private weak var sourcesMenu: NSMenu!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.global.load();
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.updateSourcesMenu), name: PreferencesNotification.updated, object: nil);
        
        updateSourcesMenu();
    }
    
    func updateSourcesMenu() {
        sourcesMenu.removeAllItems();
        PluginManager.global.enabledPlugins.forEach { p in
            let item = NSMenuItem(title: p.name + (p.isDefault ? " (Default)" : ""), action: #selector(AppDelegate.sourcesMenuItemPressed(_:)), keyEquivalent: "");
            item.representedObject = p;
            sourcesMenu.addItem(item);
        }
    }
    
    func sourcesMenuItemPressed(_ sender : NSMenuItem) {
        
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Preferences.global.save();
    }
}
