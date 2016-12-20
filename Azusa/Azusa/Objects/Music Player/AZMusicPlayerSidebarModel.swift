//
//  AZMusicPlayerSidebarModel.swift
//  Azusa
//
//  Created by Ushio on 12/19/16.
//

import Cocoa

/// The protocol for music player sidebar items
protocol AZMusicPlayerSidebarItem {
    /// The title of this section
    var title : String { get };
    
    /// Returns the identifier of the cell to create for this item
    ///
    /// - Returns: The identifier of the cell to create for this item
    func cellIdentifier() -> String;
}

/// Represents a section of items in a music player sidebar
class AZMusicPlayerSidebarSection: AZMusicPlayerSidebarItem {
    
    // MARK: - Variables
    
    let title : String;
    
    /// The items in this section
    var items : [AZMusicPlayerSidebarSectionItem];
    
    
    // MARK: - Functions
    
    func cellIdentifier() -> String {
        return "HeaderCell";
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(title : String, items : [AZMusicPlayerSidebarSectionItem]) {
        self.title = title;
        self.items = items;
    }
}

/// Represents an item in the sidebar of a music player
class AZMusicPlayerSidebarSectionItem: AZMusicPlayerSidebarItem {
    
    // MARK: - Variables
    
    let title : String;
    
    /// The icon for this sidebar item
    let icon : NSImage;
    
    
    // MARK: - Functions
    
    func cellIdentifier() -> String {
        return "DataCell";
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(title : String, icon : NSImage) {
        self.title = title;
        self.icon = icon;
    }
}
