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
    
    /// The header label of this item
    @IBOutlet weak var headerLabel: NSTextField!
    
    /// The sub-header label of this item
    @IBOutlet weak var subHeaderLabel: NSTextField!
    
    /// Is this item raised?(showing it's inline album popup)
    var isRaised : Bool = false;
    
    /// The `AZAlbum` this item represents
    var item : AZAlbum? {
        didSet {
            // Only display the item if the view is loaded
            guard isViewLoaded else { return };
            
            // Display the model's data
            self.item!.getThumbnailImage({ thumbnail in
                self.imageView!.image = thumbnail;
            });
            
            self.headerLabel.stringValue = item!.displayName;
            self.subHeaderLabel.stringValue = item!.displayArtists(shorten: true);
        }
    }
    
    override var isSelected : Bool {
        didSet {
            self.setRaised(isSelected);
        }
    }
    
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Do the initial shadow hide
        self.imageView!.superview!.layer!.shadowOpacity = 0;
    }
    
    /// Sets if this item is raised
    ///
    /// - Parameter raised: The value to set
    func setRaised(_ raised : Bool) {
        self.isRaised = raised;
        
        // Setup the shadow opacity animation
        let shadowOpacityAnimation : CABasicAnimation = CABasicAnimation(keyPath: "shadowOpacity");
        shadowOpacityAnimation.fromValue = (self.isRaised) ? 0 : 0.5;
        shadowOpacityAnimation.toValue = (self.isRaised) ? 0.5 : 0;
        shadowOpacityAnimation.duration = 0.075;
        self.imageView!.superview!.layer!.add(shadowOpacityAnimation, forKey: "shadowOpacity");
        
        // Set the animation duration
        NSAnimationContext.current().duration = 0.15;
        
        // Do the animations
        self.imageView!.superview!.layer!.shadowOpacity = (self.isRaised) ? 0.5 : 0;
        self.imageViewTopConstraint.animator().constant = (self.isRaised) ? 0 : 10;
    }
}
