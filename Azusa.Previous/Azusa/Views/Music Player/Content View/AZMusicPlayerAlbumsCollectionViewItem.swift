//
//  AZMusicPlayerAlbumsCollectionViewItem.swift
//  Azusa
//
//  Created by Ushio on 1/10/17.
//

import Cocoa

/// The view for items in the albums collection view of a music player
class AZMusicPlayerAlbumsCollectionViewItem: NSCollectionViewItem {

    /// MARK: - Properties
    
    /// The constraint for the top edge of the image view
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    
    /// The selection box for this collection view item
    @IBOutlet weak var selectionBox: AZSelectionBox!
    
    /// The header label of this item
    @IBOutlet weak var headerLabel: NSTextField!
    
    /// The sub-header label of this item
    @IBOutlet weak var subHeaderLabel: NSTextField!
    
    /// The `AZAlbum` this item represents
    var representedAlbum : AZAlbum? {
        didSet {
            // Only display the item if the view is loaded
            guard isViewLoaded else { return };
            
            // Display the model's data
            self.representedAlbum!.getThumbnailImage({ thumbnail in
                self.imageView!.image = thumbnail;
            });
            
            self.headerLabel.stringValue = representedAlbum!.displayName;
            self.subHeaderLabel.stringValue = representedAlbum!.displayArtists(shorten: true);
        }
    }
    
    override var highlightState: NSCollectionViewItemHighlightState {
        willSet {
            if(newValue == .forSelection) {
                selectionBox.isHidden = false;
            }
            if(newValue == .forDeselection || (newValue == .none && !isSelected)) {
                selectionBox.isHidden = true;
            }
        }
    }
    
    override var isSelected : Bool {
        willSet {
            selectionBox.isHidden = !newValue;
        }
    }
    
    
    // MARK: - Functions
    
    override func prepareForReuse() {
        super.prepareForReuse();
        
        // Reset the image view's image
        self.imageView?.image = #imageLiteral(resourceName: "AZDefaultCover");
    }
}
