//
//  PluginsPreferencesController.swift
//  Azusa
//
//  Created by Ushio on 2/14/17.
//

import Cocoa
import Yui

class PluginsPreferencesController: NSViewController {

    // MARK: - Properties
    
    // MARK: - Private Properties
    
    @IBOutlet internal weak var tableView : NSTableView!
    @IBOutlet private weak var preferencesContainerView: NSView!
    
    @IBOutlet private weak var enabledCheckbox: NSButton!
    @IBAction private func enabledCheckbox(_ sender: NSButton) {
        currentPlugin?.toggleEnabled();
        refresh();
        Preferences.global.postUpdatedNotification();
    }
    
    @IBAction func applyButton(_ sender: NSButton) {
        if currentPlugin != nil && currentPlugin?.isEnabled ?? false {
            Preferences.global.pluginSettings[currentPlugin!.bundleIdentifier] = preferencesController!.getSettings();
            Preferences.global.postUpdatedNotification();
        }
    }
    
    @IBAction func makeDefaultButton(_ sender: NSButton) {
        currentPlugin?.makeDefault();
        refresh(recreateSettingsView: false);
        Preferences.global.postUpdatedNotification();
    }
    
    private var preferencesController : PluginPreferencesController? = nil;
    private var currentPlugin : PluginInfo? = nil;
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    override func viewDidAppear() {
        super.viewDidAppear();
        
        // Called here instead of `viewDidLoad` because `viewDidLoad` is also called for child controllers, so there's an infinite loop from creating the plugin's preferences controller
        refresh();
    }
    
    // MARK: Private Methods
    
    internal func refresh(recreateSettingsView : Bool = true) {
        if PluginManager.global.plugins.count > 0 {
            // Refresh the cells without resetting selection and scroll position
            for i in 0...PluginManager.global.plugins.count - 1 {
                (tableView.rowView(atRow: i, makeIfNecessary: false)?.view(atColumn: i) as? PluginsPreferencesCellView)?.display(plugin: PluginManager.global.plugins[i]);
            }
            
            if recreateSettingsView {
                if currentPlugin != nil {
                    display(plugin: currentPlugin!);
                }
                else {
                    display(plugin: PluginManager.global.plugins[tableView.selectedRow < 0 ? 0 : tableView.selectedRow]);
                }
            }
        }
    }
    
    // TODO: Test this with multiple plugins
    internal func display(plugin : PluginInfo) {
        currentPlugin = plugin;
        enabledCheckbox.state = plugin.isEnabled ? NSOnState : NSOffState;
        
        preferencesController?.view.removeFromSuperview();
        preferencesController?.removeFromParentViewController();
        
        if (plugin.isEnabled) {
            preferencesController = plugin.getPlugin!.getPreferencesController();
            self.addChildViewController(preferencesController!);
            
            preferencesContainerView.addSubview(preferencesController!.view);
            preferencesController!.view.frame = preferencesContainerView.bounds;
            preferencesController!.view.autoresizingMask = [.viewWidthSizable, .viewHeightSizable];
            preferencesController!.view.translatesAutoresizingMaskIntoConstraints = true;
            
            preferencesController!.display(settings: currentPlugin!.settings);
        }
    }
}

// MARK: - NSTableViewDataSource
extension PluginsPreferencesController: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return PluginManager.global.plugins.count;
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cellView = tableView.make(withIdentifier: "DataColumn", owner: nil) as? PluginsPreferencesCellView {
            cellView.display(plugin: PluginManager.global.plugins[row]);
            return cellView;
        }
        
        return nil;
    }
}

// MARK: - NSTableViewDelegate
extension PluginsPreferencesController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        refresh();
    }
}
