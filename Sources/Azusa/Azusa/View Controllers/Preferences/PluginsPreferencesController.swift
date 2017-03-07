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
    
    private var preferencesController : PluginPreferencesController? = nil;
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    override func viewDidAppear() {
        super.viewDidAppear();
        
        // Called here instead of `viewDidLoad` because did load is also called for child controllers, so there's an infinite loop
        refresh();
    }
    
    // MARK: Private Methods
    
    internal func refresh() {
        display(plugin: PluginManager.global.plugins[tableView.selectedRow < 0 ? 0 : tableView.selectedRow]);
    }
    
    // TODO: Test this with multiple plugins
    internal func display(plugin : PluginInfo) {
        preferencesController?.view.removeFromSuperview();
        preferencesController?.removeFromParentViewController();
        preferencesController = plugin.plugin.init().getPreferencesController();
        
        self.addChildViewController(preferencesController!);
        
        preferencesContainerView.addSubview(preferencesController!.view);
        preferencesController!.view.frame = preferencesContainerView.bounds;
        preferencesController!.view.autoresizingMask = [.viewWidthSizable, .viewHeightSizable];
        preferencesController!.view.translatesAutoresizingMaskIntoConstraints = true;
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
