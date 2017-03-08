//
//  Preferences.swift
//  Yui
//
//  Created by Ushio on 3/8/17.
//

import Cocoa

public class Preferences: NSObject, NSCoding {
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public class var global : Preferences {
        return _global;
    }
    
    /// The bundle identifiers of the enabled plugins
    public private(set) var enabledPlugins : [String] {
        get {
            return _enabledPlugins;
        }
        set {
            _enabledPlugins = Array<String>(Set<String>(newValue));
        }
    }
    
    /// The preferences for all the enabled plugins (bundle identifier : preferences)
    public var pluginSettings : [String : [String : Any]] = [:];
    
    // MARK: Private Properties
    
    private static var _global : Preferences = Preferences();
    private var _enabledPlugins : [String] = [];
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    public func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self);
        UserDefaults.standard.set(data, forKey: PreferencesKey.preferences);
        UserDefaults.standard.synchronize();
    }
    
    public func load() {
        if let data = UserDefaults.standard.object(forKey: PreferencesKey.preferences) as? Data {
            Preferences._global = (NSKeyedUnarchiver.unarchiveObject(with: data) as! Preferences);
        }
    }
    
    public func enablePlugin(_ plugin : PluginInfo) {
        enabledPlugins.append(plugin.bundleIdentifier);
    }
    
    public func disablePlugin(_ plugin : PluginInfo) {
        for (i, p) in enabledPlugins.enumerated() {
            if p == plugin.bundleIdentifier {
                enabledPlugins.remove(at: i);
                break;
            }
        }
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(enabledPlugins, forKey: PreferencesKey.enabledPlugins);
        coder.encode(pluginSettings, forKey: PreferencesKey.pluginSettings);
    }
    
    required convenience public init(coder decoder: NSCoder) {
        self.init();
        
        enabledPlugins = decoder.decodeObject(forKey: PreferencesKey.enabledPlugins) as? [String] ?? [];
        pluginSettings = decoder.decodeObject(forKey: PreferencesKey.pluginSettings) as? [String : [String : Any]] ?? [:];
    }
}

struct PreferencesKey {
    public static let preferences = "Preferences";
    public static let enabledPlugins = "EnabledPlugins";
    public static let pluginSettings = "PluginSettings";
}
