//
//  Mio.swift
//  Mio
//
//  Created by Ushio on 2/14/17.
//

import Foundation
import Yui

public class Mio: Plugin {
    // MARK: - Methods
    
    // MARK: Public Methods
    
    public func getMusicSource(settings : [String : Any]) -> MusicSource {
        return MIMusicSource(settings: settings);
    }
    
    public func getPreferencesController() -> PluginPreferencesController {
        return NSStoryboard(name: "Preferences", bundle: Bundle(identifier: "drabweb.Mio")).instantiateInitialController() as! PluginPreferencesController;
    }
    
    // MARK: - Init / Deinit
    
    required public init() {
        Logger.log("Mio: Loaded");
    }
}
