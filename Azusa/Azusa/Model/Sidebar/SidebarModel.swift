//
//  SidebarModel.swift
//  Azusa
//
//  Created by Ushio on 2/10/17.
//

import Cocoa;

protocol SidebarItemBase {
    
    var title : String { get };
    
    /// The identifier of the cell to create for this item
    func cellIdentifier() -> String;
}

class SidebarSection: SidebarItemBase {
    
    let title : String;
    var items : [SidebarItem];
    
    func cellIdentifier() -> String {
        return "HeaderCell";
    }
    
    init(title : String, items : [SidebarItem]) {
        self.title = title;
        self.items = items;
    }
}

class SidebarItem: SidebarItemBase {
    
    let title : String;
    let icon : NSImage;
    
    func cellIdentifier() -> String {
        return "DataCell";
    }
    
    init(title : String, icon : NSImage) {
        self.title = title;
        self.icon = icon;
    }
}
