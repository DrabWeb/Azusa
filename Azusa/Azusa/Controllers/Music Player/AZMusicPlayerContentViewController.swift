//
//  AZMusicPlayerContentViewController.swift
//  Azusa
//
//  Created by Ushio on 1/15/17.
//

import Cocoa

class AZMusicPlayerContentViewController: NSViewController {

    // MARK: - Properties
    
    /// The collection view for displaying the album grid
    @IBOutlet weak var albumsCollectionView: NSCollectionView!
    
    /// The `AZAlbum`s to display in `albumsCollectionView`
    var albumsCollectionViewItems : [AZAlbum] = [];
    
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // REMOVE ME
        // For testing only
        let testMpd : MIMPD = MIMPD(address: "127.0.0.1", port: 6600, musicDirectory: "/Volumes/Storage/macOS/Music/");
        _ = testMpd.connect();
        
        try! testMpd.getAllAlbums().forEach { album in
            albumsCollectionViewItems.append(album);
        }
        
        albumsCollectionView.reloadData();
    }
}


// MARK: - Extensions

extension AZMusicPlayerContentViewController: NSCollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        // The albums collection view only ever has one section
        return 1;
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumsCollectionViewItems.count;
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        /// The `NSCollectionViewItem` instantiated by the collection view from the `AZMusicPlayerAlbumsCollectionViewItem` nib
        let collectionViewItem : NSCollectionViewItem = collectionView.makeItem(withIdentifier: "AZMusicPlayerAlbumsCollectionViewItem", for: indexPath);
        
        // Get `collectionViewItem` as a `AZMusicPlayerAlbumsCollectionViewItem`, and return if it isn't one
        /// `collectionViewItem` as a `AZMusicPlayerAlbumsCollectionViewItem`
        guard let albumsCollectionViewItem : AZMusicPlayerAlbumsCollectionViewItem = collectionViewItem as? AZMusicPlayerAlbumsCollectionViewItem else { return collectionViewItem };
        
        /// The album to display in the item
        let data : AZAlbum = self.albumsCollectionViewItems[indexPath.item];
        
        // Display the album in the item
        albumsCollectionViewItem.representedAlbum = data;
        
        // Return the created item
        return albumsCollectionViewItem;
    }
}
