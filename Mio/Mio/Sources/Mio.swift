//
//  Mio.swift
//  Mio
//
//  Created by Ushio on 2/14/17.
//

import Foundation
import Yui

public class Mio: Plugin {
    public var name : String {
        return "Mio";
    }
    
    public var version : String {
        return "0.1";
    }
    
    public var description : String {
        return "MPD plugin for Azusa";
    }
    
    public func getMusicSource(settings : [String : Any]) -> MusicSource {
        return MIMusicSource(settings: settings);
    }
    
    required public init() {
        Logger.log("Mio: Loaded");
    }
}
