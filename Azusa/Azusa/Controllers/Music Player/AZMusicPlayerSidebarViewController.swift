//
//  AZMusicPlayerSidebarViewController.swift
//  Azusa
//
//  Created by Ushio on 12/19/16.
//

import Cocoa

/// THe view controller for the sidebar of a 
class AZMusicPlayerSidebarViewController: NSViewController {

    /// The outline view for the sidebar of a `AZMusicPlayerViewController`
    @IBOutlet weak var sidebarOutlineView: NSOutlineView!
    
    /// The different sections for the sidebar to display
    var sidebarSections : [AZMusicPlayerSidebarSection] = [
        AZMusicPlayerSidebarSection(title: "Library", items: [
            AZMusicPlayerSidebarSectionItem(title: "Recently Added", icon: NSImage(named: "NSSmartBadgeTemplate")!),
            AZMusicPlayerSidebarSectionItem(title: "Artists", icon: NSImage(named: "NSSmartBadgeTemplate")!),
            AZMusicPlayerSidebarSectionItem(title: "Albums", icon: NSImage(named: "NSSmartBadgeTemplate")!),
            AZMusicPlayerSidebarSectionItem(title: "Songs", icon: NSImage(named: "NSSmartBadgeTemplate")!),
            AZMusicPlayerSidebarSectionItem(title: "Genres", icon: NSImage(named: "NSSmartBadgeTemplate")!)
        ]),
        AZMusicPlayerSidebarSection(title: "Playlists", items: [])
    ];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Expand all the sidebar items
        sidebarOutlineView.expandItem(nil, expandChildren: true);
    }
}

extension AZMusicPlayerSidebarViewController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        // If the item at the selected row is a `AZMusicPlayerSidebarSectionItem`...
        if let selectedSidebarItem = self.sidebarOutlineView.item(atRow: self.sidebarOutlineView.selectedRow) as? AZMusicPlayerSidebarSectionItem {
            
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        // Set the row height depending on if the row is a section header or section item
        if item is AZMusicPlayerSidebarSection {
            return 17;
        }
        else {
            return 22;
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // If the item is a sidebar section...
        if let sidebarSection : AZMusicPlayerSidebarSection = item as? AZMusicPlayerSidebarSection {
            // Return the amount items in the section
            return sidebarSection.items.count;
        }
        // If the item isn't a sidebar section...
        else {
            // Return the amount of sidebar sections
            return sidebarSections.count;
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // Only allow section headers to expand
        return item is AZMusicPlayerSidebarSection;
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        // If the item is a sidebar section...
        if let sidebarSection : AZMusicPlayerSidebarSection = item as? AZMusicPlayerSidebarSection {
            // Return the item in the section at `index`
            return sidebarSection.items[index];
        }
        // If the item isn't a sidebar section...
        else {
            // Remove the sidebar section at `index`
            return sidebarSections[index];
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        // Return the item
        return item;
    }
}

extension AZMusicPlayerSidebarViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        // If the item is a sidebar item...
        if let sidebarItem = item as? AZMusicPlayerSidebarItem {
            // If the created cell view for the item isn't nil...
            if let cellView : NSTableCellView = outlineView.make(withIdentifier: sidebarItem.cellIdentifier(), owner: self) as? NSTableCellView {
                // Get the text field of the cell, and if it isn't nil...
                if let textField = cellView.textField {
                    // Set the text field's string value to the item's title
                    textField.stringValue = sidebarItem.title;
                }
                
                // Get the image view of the cell, and if it isn't nil...
                if let imageView = cellView.imageView {
                    // If the item is a sidebar section item...
                    if let sidebarSectionItem = sidebarItem as? AZMusicPlayerSidebarSectionItem {
                        // Set the image view's image to the sidebar item's icon
                        imageView.image = sidebarSectionItem.icon;
                        
                        // Make sure the image is template
                        imageView.image?.isTemplate = true;
                    }
                }
                
                // Return the updated cell
                return cellView;
            }
        }
        
        // Default to nil
        return nil;
    }
    
    
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        // Only allow non-section headers to be selected
        return !self.outlineView(outlineView, isGroupItem: item);
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        // Return if the item is a section header
        return item is AZMusicPlayerSidebarSection;
    }
}
