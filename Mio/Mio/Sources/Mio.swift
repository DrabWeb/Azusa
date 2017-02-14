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
    
    public var description : String {
        return "MPD plugin for Azusa";
    }
    
    public var version : String {
        return "0.1";
    }
    
    required public init() {
        Logger.log("Mio: Initiated");
    }
}
