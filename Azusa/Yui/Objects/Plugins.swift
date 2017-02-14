//
//  Plugins.swift
//  Yui
//
//  Created by Ushio on 2/14/17.
//

import Foundation

public class PluginManager {
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public class var global : PluginManager {
        return _global;
    }
    
    // MARK: Private Properties
    
    private let basePath : String = "\(NSHomeDirectory())/Library/Application Support/Azusa/Plugins"
    private static let _global : PluginManager = PluginManager();
    
    // TODO: Maybe add some sort of safety here?
    // Not sure because it should be on the user to only install trusted plugins
    /// All the `Plugin`s in the plugins folder
    private var plugins : [Plugin.Type] {
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
        
        return plugins;
    }
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    // MARK: Private Methods
    
    
    // MARK: - Init / Deinit
    
    init() {
        do {
            try FileManager.default.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil);
        }
        catch let error {
            Logger.log("PluginManager: Error creating plugins folder, \(error)");
        }
    }
}

public protocol Plugin {
    var name : String { get };
    var description : String { get };
    var version : String { get };
    
    init();
}
