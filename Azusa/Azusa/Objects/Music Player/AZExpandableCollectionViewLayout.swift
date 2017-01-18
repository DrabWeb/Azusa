//
//  AZExpandableCollectionViewLayout.swift
//  Azusa
//
//  Created by Ushio on 1/15/17.
//

import Cocoa

class AZExpandableCollectionViewLayout: NSCollectionViewFlowLayout {
    
    // MARK: - Properties
    
    /// The height of the view that expands out of the collection view items
    var expansionHeight : CGFloat = AZAlbumDetailsView.height;
    
    /// The closure called for displaying the expansion item
    /// Passed if it's on a new row compared to the previous, the item that triggered the open and the index of the clicked item
    var displayExpansionItem : ((Bool, NSCollectionViewItem, Int) -> ())? = nil;
    
    /// The closure called for closing the expansion item
    var closeExpansionItem : (() -> ())? = nil;
    
    /// The Y position of the current selected item, used for layout
    private var selectedItemY : CGFloat = -1;
    
    /// The index path of the previous selection, used for layout
    private var previousSelectionIndexPaths : Set<IndexPath> = [];
    
    
    // MARK: - Functions
    
    override var collectionViewContentSize: NSSize {
        /// The content size from `NSCollectionViewFlowLayout`
        var contentSize : NSSize = super.collectionViewContentSize;
        
        // If there's only one item selected...
        if(self.collectionView!.selectionIndexPaths.count == 1) {
            // Add the expansion height to the content size so the full collection view is visible
            contentSize = NSSize(width: contentSize.width, height: contentSize.height + expansionHeight);
        }
        
        // Return the content size
        return contentSize;
    }
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        /// The layout attributes from `NSCollectionViewFlowLayout`
        let attributes : [NSCollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect);
        
        // If there's only one item selected...
        if(self.collectionView!.selectionIndexPaths.count == 1) {
            // Get the first selection index path, and if it isn't nil...
            if let firstSelectionIndexPath = self.collectionView?.selectionIndexPaths.first {
                /// Should the expansion view be on a new row compared to the previous?
                var onNewRow : Bool = false;
                
                // Get `selectedItemY`
                if let selectedItemAttribute = super.layoutAttributesForItem(at: firstSelectionIndexPath) {
                    // Set `onNewRow`
                    onNewRow = (selectedItemY != selectedItemAttribute.frame.origin.y);
                    
                    selectedItemY = selectedItemAttribute.frame.origin.y;
                }
                
                // Update the item positions below the expansion view so they are positioned below it
                attributes.filter({ $0.frame.origin.y > selectedItemY }).forEach { attribute in
                    attribute.frame.origin = NSPoint(x: attribute.frame.origin.x, y: attribute.frame.origin.y + expansionHeight);
                }
                
                // Display the expansion item, but only if the selection is on a new item
                if(previousSelectionIndexPaths.first != firstSelectionIndexPath) {
                    if let selectedItem = self.collectionView?.item(at: firstSelectionIndexPath) {
                        displayExpansionItem?(onNewRow, selectedItem, firstSelectionIndexPath.item);
                        
                        // Scroll the expansion view to visible
                        self.collectionView?.scrollToVisible(NSRect(x: 0, y: selectedItemY + (expansionHeight / 2), width: self.collectionView?.bounds.width ?? 0, height: expansionHeight));
                    }
                }
                
                // Fixes an issue where there would be random spaces on some rows
                super.invalidateLayout();
            }
        }
        // If there are no or multiple items selected...
        else if(self.collectionView!.selectionIndexPaths.count == 0 || self.collectionView!.selectionIndexPaths.count > 1) {
            // Close the expansion item
            closeExpansionItem?();
        }
        
        // Set `previousSelectionIndexPaths`
        previousSelectionIndexPaths = self.collectionView!.selectionIndexPaths;
        
        // Return the attributes
        return attributes;
    }
}
