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
    
    /// Scrolls the expansion view and it's item into the viewport, does nothing if no items are expanded
    func scrollToExpansion() {
        // If there's only one item selected...
        if(self.collectionView!.selectionIndexPaths.count == 1) {
            // Scroll to the expansion view and it's item
            self.collectionView?.scrollToVisible(NSRect(x: 0, y: selectedItemY, width: self.collectionView?.bounds.width ?? 0, height: expansionHeight + self.itemSize.height));
        }
    }
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        // Return the adjusted attributes
        return self.adjustLayoutAttributes(attributes: super.layoutAttributesForElements(in: rect));
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        /// The layout attributes for this item from super
        var attribute : NSCollectionViewLayoutAttributes? = super.layoutAttributesForItem(at: indexPath);
        
        // Adjust the attributes
        if(attribute != nil) {
            attribute = self.adjustLayoutAttributes(attributes: [attribute!])[0];
        }
        
        // Return the attributes
        return attribute;
    }
    
    /// Adjusts the given collection view layout attributes to fit the expandable view
    ///
    /// - Parameter attributes: The attributes to adjust
    /// - Returns: The adjusted attributes
    private func adjustLayoutAttributes(attributes : [NSCollectionViewLayoutAttributes]) -> [NSCollectionViewLayoutAttributes] {
        /// `attributes`, adjusted
        let adjustedAttributes : [NSCollectionViewLayoutAttributes] = attributes;
        
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
                adjustedAttributes.filter({ $0.frame.origin.y > selectedItemY }).forEach { attribute in
                    attribute.frame.origin = NSPoint(x: attribute.frame.origin.x, y: attribute.frame.origin.y + expansionHeight);
                }
                
                // Display the expansion item, but only if the selection is on a new item
                if(previousSelectionIndexPaths.first != firstSelectionIndexPath) {
                    if let selectedItem = self.collectionView?.item(at: firstSelectionIndexPath) {
                        displayExpansionItem?(onNewRow, selectedItem, firstSelectionIndexPath.item);
                        
                        // Scroll to the expansion view and it's item
                        scrollToExpansion();
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
        
        // Return the adjusted attributes
        return adjustedAttributes;
    }
}
