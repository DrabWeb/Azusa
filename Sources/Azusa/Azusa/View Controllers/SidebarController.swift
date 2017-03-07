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
    
    let sections : [SidebarSection] = [
        LibrarySidebarSection(),
        SidebarSection(title: "Playlists", items: [])
    ];
    
    var librarySection : LibrarySidebarSection {
        return sections[0] as! LibrarySidebarSection;
    }
    
    var playlistsSection : SidebarSection {
        return sections[1];
    }
    
    var onNavigated : ((NavigationDestination) -> Void)?;
    
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

// MARK: - NavigationDestination
enum NavigationDestination {
    case Albums, Artists, Songs, Genres
}

// MARK: - NSOutlineViewDelegate
extension SidebarController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        // TODO: Implement playlist selection handling
        if let selected = contentOutlineView.item(atRow: contentOutlineView.selectedRow) as? SidebarItem {
            switch selected {
                case is ArtistsSidebarItem:
                    onNavigated?(.Artists);
                    break;
                
                case is AlbumsSidebarItem:
                    onNavigated?(.Albums);
                    break;
                
                case is SongsSidebarItem:
                    onNavigated?(.Songs);
                    break;
                
                case is GenresSidebarItem:
                    onNavigated?(.Genres);
                    break;
                
                default:
                    break;
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        // Section headers have a different size
        if item is SidebarSection {
            return 17;
        }
        else {
            return 24;
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
