//
//  SidebarItems.swift
//  Azusa
//
//  Created by Ushio on 2/10/17.
//

import Cocoa

class LibrarySidebarSection: SidebarSection {
    init() {
        super.init(title: "Library", items: [
            ArtistsSidebarItem(),
            AlbumsSidebarItem(),
            SongsSidebarItem(),
            GenresSidebarItem()
        ]);
    }
}

class ArtistsSidebarItem: SidebarItem {
    init() {
        super.init(title: "Artists", icon: NSImage(named: "NSHomeTemplate")!);
    }
}

class AlbumsSidebarItem: SidebarItem {
    init() {
        super.init(title: "Albums", icon: NSImage(named: "NSHomeTemplate")!);
    }
}

class SongsSidebarItem: SidebarItem {
    init() {
        super.init(title: "Songs", icon: NSImage(named: "NSHomeTemplate")!);
    }
}

class GenresSidebarItem: SidebarItem {
    init() {
        super.init(title: "Genres", icon: NSImage(named: "NSHomeTemplate")!);
    }
}
