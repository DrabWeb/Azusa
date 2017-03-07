//
//  PluginsPreferencesCellView.swift
//  Azusa
//
//  Created by Ushio on 2/14/17.
//

import Cocoa
import Yui

class PluginsPreferencesCellView: NSTableCellView {

    // MARK: - Properties
    
    // MARK: Public Properties
    
    var representedPlugin : PluginInfo? {
        return _representedPlugin;
    }
    
    // MARK: Private Properties
    
    private var _representedPlugin : PluginInfo? = nil;
    
    @IBOutlet private weak var statusImageView: NSImageView!
    @IBOutlet private weak var nameLabel: NSTextField!
    @IBOutlet private weak var versionLabel: NSTextField!
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    func display(plugin : PluginInfo) {
        _representedPlugin = plugin;
        
        nameLabel.stringValue = plugin.name;
        versionLabel.stringValue = "v\(plugin.version)";
        statusImageView.image = NSImage(named: plugin.enabled ? "NSStatusAvailable" : "NSStatusNone")!;
    }
}
