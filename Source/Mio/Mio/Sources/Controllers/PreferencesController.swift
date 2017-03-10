//
//  PreferencesController.swift
//  Mio
//
//  Created by Ushio on 2/15/17.
//

import Cocoa
import Yui

public class PreferencesController: PluginPreferencesController {
    
    /// MARK: - Properties
    
    // MARK: Private Properties
    
    private var settings : [String : Any] = [:];
    
    @IBOutlet private weak var addressTextField : NSTextField!
    @IBOutlet private weak var portTextField : NSTextField!
    @IBOutlet private weak var musicDirectoryLabel : NSTextField!
    @IBAction private func musicDirectoryChangeButton(_ sender : NSButton) {
        let openPanel = NSOpenPanel();
        openPanel.canChooseFiles = false;
        openPanel.canChooseDirectories = true;
        
        if openPanel.runModal() == NSModalResponseOK {
            var directory = openPanel.url!.absoluteString.removingPercentEncoding!.replacingOccurrences(of: "file://", with: "");
            directory = directory.substring(to: directory.index(before: directory.endIndex));
            settings[SettingsKey.directory] = directory;
            
            musicDirectoryLabel.stringValue = settings[SettingsKey.directory] as! String;
        }
    }
    
    // MARK: - Methods
    
    // MARK: - Public Methods

    public override func getSettings() -> [String : Any] {
        settings[SettingsKey.address] = addressTextField.stringValue;
        settings[SettingsKey.port] = portTextField.integerValue;
        
        return settings;
    }
    
    public override func display(settings : [String : Any]) {
        self.settings = settings;
        
        addressTextField.stringValue = settings[SettingsKey.address] as? String ?? "127.0.0.1";
        portTextField.stringValue = String(settings[SettingsKey.port] as? Int ?? 6600);
        musicDirectoryLabel.stringValue = settings[SettingsKey.directory] as? String ?? "\(NSHomeDirectory())/Music";
    }
}
