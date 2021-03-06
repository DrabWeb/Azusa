//
//  MusicPlayerSplitViewController.swift
//  Azusa
//
//  Created by Ushio on 2/8/17.
//

import Cocoa

class MusicPlayerSplitViewController: NSSplitViewController {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var sidebarController : SidebarController? {
        return sidebarItem.viewController as? SidebarController
    }
    
    var contentController : ContentController? {
        return contentItem.viewController as? ContentController
    }
    
    // MARK: Private Properties
    
    @IBOutlet private weak var sidebarItem: NSSplitViewItem!
    @IBOutlet private weak var contentItem: NSSplitViewItem!
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    override func toggleSidebar(_ sender: Any?) {
        sidebarItem.isCollapsed = !sidebarItem.isCollapsed;
    }
    
    // MARK: Private methods
    
}
