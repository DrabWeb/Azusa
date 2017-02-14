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
    
    public var plugins : [Plugin.Type] {
        return _plugins;
    }
    
    // MARK: Private Properties
    
    private let basePath : String = "\(NSHomeDirectory())/Library/Application Support/Azusa/Plugins"
    private static let _global : PluginManager = PluginManager();
    private var _plugins : [Plugin.Type] = [];
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    // MARK: Private Methods
    
    // TODO: Maybe add some sort of safety here?
    // Not sure because it should be on the user to only install trusted plugins
    // Probably go with what most do where it's disabled when installed and the user has to enable it
    /// Loads all the `Plugin`s in the plugins folder and puts them in `_plugins`
    private func loadPlugins() {
        var plugins : [Plugin.Type] = [];
        
        // Load the `Plugin` class from every `.bundle` in the `Plugins` directory, and if it's valid add it to `plugins`
        do {
            for (_, file) in try FileManager.default.contentsOfDirectory(atPath: basePath).enumerated() {
                if let filename = file as String? {
                    if let bundle = Bundle(path: "\(basePath)/\(filename)") {
                        if let pluginClass = (bundle.principalClass.self?.class() as? Plugin.Type) {
                            plugins.append(pluginClass);
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
    // MARK: - Properties
    
    // MARK: Public Properties
    
    /// The name of this plugin
    var name : String { get };
    
    /// The version of this plugin
    var version : String { get };
    
    /// A short description about this plugin
    var description : String { get };
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    /// Provides a new instance of the plugin's `MusicSource` with the provided settings
    func getMusicSource(settings : [String : Any]) -> MusicSource;
    
    // MARK: - Init / Deinit
    
    init();
}
