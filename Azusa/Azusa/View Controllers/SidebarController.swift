//
//  SidebarController.swift
//  Azusa
//
//  Created by Ushio on 2/9/17.
//

import Cocoa

class SidebarController: NSViewController {

    // MARK: - Properties
    
    // MARK: Public Properties
    
    var sections : [SidebarSection] = [
        SidebarSection(title: "Library", items: [
            SidebarItem(title: "Artists", icon: NSImage(named: "NSHomeTemplate")!),
            SidebarItem(title: "Albums", icon: NSImage(named: "NSHomeTemplate")!),
            SidebarItem(title: "Songs", icon: NSImage(named: "NSHomeTemplate")!),
            SidebarItem(title: "Genres", icon: NSImage(named: "NSHomeTemplate")!)
        ]),
        SidebarSection(title: "Playlists", items: [])
        ] {
        didSet {
            contentOutlineView.reloadData();
        }
    };
    
    var librarySection : SidebarSection {
        return sections[0];
    }
    
    var playlistsSection : SidebarSection {
        return sections[1];
    }
    
    // MARK: Private Properties
    
    @IBOutlet internal weak var contentOutlineView: NSOutlineView!
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    func expandAll() {
        contentOutlineView.expandItem(nil, expandChildren: true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        expandAll();
    }
}

// MARK: - NSOutlineViewDelegate
extension SidebarController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        // TODO: Implement changing between sections from the sidebar
//        if let selected = contentOutlineView.item(atRow: contentOutlineView.selectedRow) as? SidebarItem {
//            
//        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        // Section headers have a different size
        if item is SidebarSection {
            return 17;
        }
        else {
            return 22;
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let section = item as? SidebarSection {
            return section.items.count;
        }
        else {
            return sections.count;
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // Only sections are collapsible
        return item is SidebarSection;
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let section = item as? SidebarSection {
            return section.items[index];
        }
        else {
            return sections[index];
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return item;
    }
}

// MARK: - NSOutlineViewDataSource
extension SidebarController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let genericSidebarItem = item as? SidebarItemBase {
            if let cellView = outlineView.make(withIdentifier: genericSidebarItem.cellIdentifier(), owner: self) as? NSTableCellView {
                if let textField = cellView.textField {
                    textField.stringValue = genericSidebarItem.title;
                }
                
                if let imageView = cellView.imageView {
                    if let sidebarItem = genericSidebarItem as? SidebarItem {
                        imageView.image = sidebarItem.icon;
                        imageView.image?.isTemplate = true;
                    }
                }
                
                return cellView;
            }
        }
        
        return nil;
    }
    
    
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        // Only allow non-section headers to be selected
        return !self.outlineView(outlineView, isGroupItem: item);
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        // Sections are groups
        return item is SidebarSection;
    }
}
