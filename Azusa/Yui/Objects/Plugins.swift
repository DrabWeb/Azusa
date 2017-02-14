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
    
    /// All the bundles in the plugins folder
    var bundles : [Bundle] {
        var bundles : [Bundle] = [];
        
        do {
            for (_, file) in try FileManager.default.contentsOfDirectory(atPath: basePath).enumerated() {
                if let filename = file as String? {
                    if let bundle = Bundle(path: "\(basePath)/\(filename)") {
                        bundle.load();
                        
                        if let principalClass = bundle.principalClass.self {
                            print(principalClass);
                            bundles.append(bundle);
                        }
                    }
                }
            }
        }
        catch let error {
            Logger.log("PluginManager: Error checking for bundles, \(error)");
        }
        
        return bundles;
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
        
        Logger.log(bundles);
    }
}

protocol Plugin {
    var name : String { get };
    var description : String { get };
    var version : String { get };
}
