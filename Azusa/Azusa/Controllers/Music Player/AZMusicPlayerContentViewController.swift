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
    
    /// The current displaying `AZAlbumDetailsView` in the albums collection view
    var currentAlbumDetailsView : AZAlbumDetailsView? = nil;
    
    /// The top constraint for `currentAlbumDetailsView`
    private var currentAlbumDetailsViewTopConstraint : NSLayoutConstraint? = nil;
    
    /// The constraint for centering the X position of the popup triangle of the current album details view relative to the selected album
    private var currentAlbumDetailsViewPopupTriangleCenterConstraint : NSLayoutConstraint? = nil;
    
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Setup the album collection view layout
        (self.albumsCollectionView.collectionViewLayout as? AZExpandableCollectionViewLayout)?.sectionInset = EdgeInsets(top: 30, left: 30, bottom: 30, right: 30);
        (self.albumsCollectionView.collectionViewLayout as? AZExpandableCollectionViewLayout)?.itemSize = NSSize(width: 200, height: 240);
        
        // Observe the album collection view's selection
        albumsCollectionView.addObserver(self, forKeyPath: "selectionIndexPaths", options: [.new], context: nil);
        
        // Set the album collection view's expansion view display and close closures
        (albumsCollectionView.collectionViewLayout as? AZExpandableCollectionViewLayout)?.displayExpansionItem = { onNewRow, collectionViewItem, index in
            // Create the album details view if it doesn't exist already
            if(self.currentAlbumDetailsView == nil) {
                self.currentAlbumDetailsView = self.newAlbumDetailsView();
                
                self.albumsCollectionView.superview!.addSubview(self.currentAlbumDetailsView!);
                
                // Move the album details view down to it's desired position so the animation doesn't start from 0,0
                self.currentAlbumDetailsView!.setFrameOrigin(NSPoint(x: 0, y: collectionViewItem.view.frame.origin.y + AZAlbumDetailsView.height - 50));
                
                self.albumsCollectionView.superview!.addConstraints([NSLayoutConstraint(item: self.currentAlbumDetailsView!, attribute: .leading, relatedBy: .equal, toItem: self.albumsCollectionView.superview!, attribute: .leading, multiplier: 1, constant: 0),
                                                                     NSLayoutConstraint(item: self.currentAlbumDetailsView!, attribute: .trailing, relatedBy: .equal, toItem: self.albumsCollectionView.superview!, attribute: .trailing, multiplier: 1, constant: 0)]);
            }
            
            // Readjust the album details view's constraints
            self.readjustAlbumDetailsViewConstraints(with: collectionViewItem);
            
            // Make sure the album details view is visible
            self.currentAlbumDetailsView!.isHidden = false;
            
            // Display the album in the details view
            self.currentAlbumDetailsView!.display(album: self.albumsCollectionViewItems[index], fade: !onNewRow);
        }
        
        (albumsCollectionView.collectionViewLayout as? AZExpandableCollectionViewLayout)?.closeExpansionItem = {
            // Close the album details view
            self.currentAlbumDetailsView?.removeFromSuperview();
            self.currentAlbumDetailsView = nil;
            self.currentAlbumDetailsViewTopConstraint = nil;
        }
        
        // REMOVE ME
        // For testing only
        let testMpd : MIMPD = MIMPD(address: "127.0.0.1", port: 6600, musicDirectory: "/Volumes/Storage/macOS/Music/");
        _ = testMpd.connect();
        
        try! testMpd.getAllAlbums().forEach { album in
            albumsCollectionViewItems.append(album);
        }
        
        albumsCollectionView.reloadData();
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "selectionIndexPaths") {
            // Animate the collection view expansion view expanding/unexpanding
            NSAnimationContext.runAnimationGroup({ (context) in
                context.allowsImplicitAnimation = true;
                context.duration = 0.15;
                
                // Don't allow reuse of selected items so their visual states are kept
                self.albumsCollectionView.selectionIndexPaths.forEach {
                    self.albumsCollectionView.item(at: $0)?.identifier = "";
                }
                
                albumsCollectionView.collectionViewLayout!.invalidateLayout();
                self.view.window?.layoutIfNeeded();
            }, completionHandler: nil);
        }
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        
        self.albumsCollectionView.collectionViewLayout?.invalidateLayout();
    }
    
    /// Readjusts the current album details view's top and center X constraints relative to `collectionViewItem`
    ///
    /// - Parameter collectionViewItem: The `NSCollectionViewItem` to constraint to
    func readjustAlbumDetailsViewConstraints(with collectionViewItem : NSCollectionViewItem) {
        if(self.currentAlbumDetailsView != nil) {
            if(self.albumsCollectionView.selectionIndexPaths.count == 1) {
                collectionViewItem.identifier = "";
                
                // Create the top constraint
                if(self.currentAlbumDetailsViewTopConstraint != nil) {
                    self.albumsCollectionView.superview!.removeConstraint(self.currentAlbumDetailsViewTopConstraint!);
                }
                
                self.currentAlbumDetailsViewTopConstraint = NSLayoutConstraint(item: self.currentAlbumDetailsView!, attribute: .top, relatedBy: .equal, toItem: collectionViewItem.view, attribute: .bottom, multiplier: 1, constant: 0);
                
                self.albumsCollectionView.superview!.addConstraint(self.currentAlbumDetailsViewTopConstraint!);
                
                
                // Create the popup triangle center X constraint
                if(self.currentAlbumDetailsViewPopupTriangleCenterConstraint != nil) {
                    self.albumsCollectionView.superview!.removeConstraint(self.currentAlbumDetailsViewPopupTriangleCenterConstraint!);
                }
                
                self.currentAlbumDetailsViewPopupTriangleCenterConstraint = NSLayoutConstraint(item: self.currentAlbumDetailsView!.popupTriangle, attribute: .centerX, relatedBy: .equal, toItem: collectionViewItem.view, attribute: .centerX, multiplier: 1, constant: 0);
                
                self.albumsCollectionView.superview!.addConstraint(self.currentAlbumDetailsViewPopupTriangleCenterConstraint!);
                
                self.albumsCollectionView.collectionViewLayout?.invalidateLayout();
            }
        }
    }
    
    /// Instantiates a new `AZAlbumDetailsView` from the `AZAlbumDetailsView` nib and returns it
    ///
    /// - Returns: The instantiated `AZAlbumDetailsView`
    private func newAlbumDetailsView() -> AZAlbumDetailsView! {
        /// The top level objects of the `AZAlbumDetailsView` nib
        var topLevelObjects : NSArray = [];
        
        // Load the nib and top level objects
        NSNib(nibNamed: "AZAlbumDetailsView", bundle: nil)?.instantiate(withOwner: nil, topLevelObjects: &topLevelObjects);
        
        /// The `AZAlbumDetailsView` to return
        var albumDetailsView : AZAlbumDetailsView? = nil;
        
        // Get the album details view from the nib
        topLevelObjects.forEach {
            if let newAlbumDetailsView = $0 as? AZAlbumDetailsView {
                albumDetailsView = newAlbumDetailsView;
                albumDetailsView!.translatesAutoresizingMaskIntoConstraints = false;
            }
        }
        
        // Return the new album details view
        return albumDetailsView;
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
        
        // Recreate the album details view's constraints if this is the current seleted item and the only selected item
        if(self.albumsCollectionView.selectionIndexPaths.count == 1 && indexPath ==  self.albumsCollectionView.selectionIndexPaths.first) {
            self.currentAlbumDetailsView?.isHidden = false;
            self.readjustAlbumDetailsViewConstraints(with: albumsCollectionViewItem);
        }
        
        // Return the created item
        return albumsCollectionViewItem;
    }
}

extension AZMusicPlayerContentViewController: NSCollectionViewDelegateFlowLayout {
    
    // A fix for when an expanded item gets resized out of the viewport
    // Hides the album details view from the user when scrolled out and re-attaches it when the item becomes visible 
    
    func collectionView(_ collectionView: NSCollectionView, didEndDisplaying item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        if(self.albumsCollectionView.selectionIndexPaths.count == 1 && indexPath ==  self.albumsCollectionView.selectionIndexPaths.first) {
            self.currentAlbumDetailsView?.isHidden = true;
            self.albumsCollectionView.collectionViewLayout?.invalidateLayout();
        }
    }
}
