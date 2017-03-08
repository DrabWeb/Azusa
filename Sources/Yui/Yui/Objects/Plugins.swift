//
//  Plugins.swift
//  Yui
//
//  Created by Ushio on 2/14/17.
//

import Foundation

// MARK: - PluginManager
public class PluginManager {
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public class var global : PluginManager {
        return _global;
    }
    
    public var plugins : [PluginInfo] {
        return _plugins;
    }
    
    // MARK: Private Properties
    
    private let basePath : String = "\(NSHomeDirectory())/Library/Application Support/Azusa/Plugins"
    private static let _global : PluginManager = PluginManager();
    private var _plugins : [PluginInfo] = [];
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    // MARK: Private Methods
    
    // TODO: Maybe add some sort of safety here?
    // Not sure because it should be on the user to only install trusted plugins
    // Probably go with what most do where it's disabled when installed and the user has to enable it
    /// Loads all the `Plugin`s in the plugins folder and puts them in `_plugins`
    private func loadPlugins() {
        var plugins : [PluginInfo] = [];
        
        // Load the `Plugin` class from every `.bundle` in the `Plugins` directory, and if it's valid add it to `plugins`
        do {
            for (_, file) in try FileManager.default.contentsOfDirectory(atPath: basePath).enumerated() {
                if let filename = file as String? {
                    if let bundle = Bundle(path: "\(basePath)/\(filename)") {
                        if let plugin = PluginInfo(bundle: bundle) {
                            plugins.append(plugin);
                        }
                    }
                }
            }
        }
        catch let error {
            Logger.log("PluginManager: Error getting plugins, \(error)");
        }
        
        _plugins = plugins;
    }
    
    
    // MARK: - Init / Deinit
    
    init() {
        do {
            try FileManager.default.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil);
        }
        catch let error {
            Logger.log("PluginManager: Error creating plugins folder, \(error)");
        }
        
        loadPlugins();
    }
}

// MARK: - Plugin
/// The protocol for a Azusa plugin to implement in the base class, provides info about the plugin and access to it's classes
public protocol Plugin {
    // MARK: - Methods
    
    // MARK: Public Methods
    
    /// Provides a new instance of the plugin's `MusicSource` with the provided settings
    func getMusicSource(settings : [String : Any]) -> MusicSource;
    
    /// Provides a new `PluginPreferencesController` for this plugin
    func getPreferencesController() -> PluginPreferencesController;
    
    // MARK: - Init / Deinit
    
    init();
}

// MARK: - PluginInfo
public class PluginInfo: CustomStringConvertible {
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public var name : String = "";
    public var version : String = "";
    public var info : String = "";
    public var bundleIdentifier : String = "";
    public var bundlePath : String = "";
    public var plugin : Plugin.Type!
    
    public var description : String {
        return "PluginInfo(\(plugin)): \(name) v\(version), \(info)";
    }
    
    public var isEnabled : Bool {
        return Preferences.global.enabledPlugins.contains(bundleIdentifier);
    }
    
    public var getPlugin : Plugin? {
        if isEnabled {
            return plugin.init();
        }
        
        return nil;
    }
    
    public var preferences : [String : Any] {
        get {
            if let p = Preferences.global.pluginSettings[bundleIdentifier] {
                return p;
            }
            else {
                return [:];
            }
        }
    }

    // MARK: - Methods
    
    // MARK: Public Methods
    
    public func enable() {
        Preferences.global.enablePlugin(self);
    }
    
    public func disable() {
        Preferences.global.disablePlugin(self);
    }
    
    public func toggleEnabled() {
        if isEnabled {
            Preferences.global.disablePlugin(self);
        }
        else {
            Preferences.global.enablePlugin(self);
        }
    }
    
    // MARK: - Init / Deinit
    
    init?(bundle : Bundle) {
        if let pluginClass = bundle.principalClass.self?.class() as? Plugin.Type {
            self.name = bundle.object(forInfoDictionaryKey: "CFBundleName") as! String;
            self.version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String;
            self.info = bundle.object(forInfoDictionaryKey: "PluginDescription") as! String;
            self.bundleIdentifier = bundle.bundleIdentifier ?? "";
            self.bundlePath = bundle.bundlePath;
            self.plugin = pluginClass;
        }
        else {
            return nil;
        }
    }
    
    init(name : String, version : String, info : String, bundleIdentifier : String, plugin : Plugin.Type) {
        self.name = name;
        self.version = version;
        self.info = info;
        self.bundleIdentifier = bundleIdentifier;
        self.plugin = plugin;
    }
}

// NSViewController-based protocol that returns a settings dictionary for when the user presses apply
// Probably also some way to check if applying is allowed for something like Plex where the user has to enter the pin first
// Not sure how to go about that yet
// Preferences controllers should only be loaded when the plugin is enabled, if it was loaded when disabled then it could potentionally run code without user confirmation

// This is the best way I could see to force a base class and protocol on a subclass

// MARK: - PluginPreferencesProtocol
protocol PluginPreferencesProtocol {
    /// Gets the settings for the current state of this preferences controller
    ///
    /// - Returns: A dictionary of settings suitable for `MusicSource`
    func getSettings() -> [String : Any];
    
    /// Display the given settings dictionary
    ///
    /// - Parameter settings: The settings to display
    func display(settings : [String : Any]);
}

// MARK: - PluginPreferencesController
/// The base class for preferences views of plugins
open class PluginPreferencesController: NSViewController, PluginPreferencesProtocol {
    open func getSettings() -> [String : Any] {
        fatalError("PluginPreferencesController subclasses must override getSettings()");
    }
    
    open func display(settings: [String : Any]) {
        fatalError("PluginPreferencesController subclasses must override display(settings:)");
    }
}
