//
//  Preferences.swift
//  Azusa
//
//  Created by Ushio on 2/15/17.
//

import Cocoa
import Yui

// TODO: Add preferences encoding/decoding
class Preferences: NSObject {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public class var global : Preferences {
        return _global;
    }
    
    /// The bundle identifiers of all the enabled plugins
    var enabledPlugins : [String] {
        get {
            return _enabledPlugins;
        }
        set {
            // Why is there no native remove duplicates method?
            // Maybe make an extension later
            var newEnabledPlugins : [String] = [];
            for (_, plugin) in newValue.enumerated() {
                if !newEnabledPlugins.contains(plugin) {
                    newEnabledPlugins.append(plugin);
                }
            }
            
            _enabledPlugins = newEnabledPlugins;
        }
    }
    
    // MARK: Private Properties
    
    private static let _global : Preferences = Preferences();
    private var _enabledPlugins : [String] = [];
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    func enabledPlugin(_ plugin : PluginInfo) {
        enabledPlugins.append(plugin.bundleIdentifier);
    }
    
    func disablePlugin(_ plugin : PluginInfo) {
        for (index, bundleIdentifier) in enabledPlugins.enumerated() {
            if plugin.bundleIdentifier == bundleIdentifier {
                enabledPlugins.remove(at: index);
                break;
            }
        }
    }
}
