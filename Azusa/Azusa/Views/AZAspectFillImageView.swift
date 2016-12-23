//
//  AZAspectFillImageView.swift
//  Azusa
//
//  Created by Ushio on 11/23/16.
//

import Cocoa

/// An NSImageView which implements aspect fill
class AZAspectFillImageView: NSImageView {
    
    /// Used for setting the image for aspect filling
    ///
    /// - Parameter image: The image to display
    func setAspectFillImage(_ image : NSImage?) {
        // Set the actual image so it's still accessable
        self.image = image;
        
        // Start the `CATransaction`
        CATransaction.begin();
        
        // Setup the layer with smoothing, scaling, etc.
        self.wantsLayer = true;
        self.layer?.contentsGravity = kCAGravityResizeAspectFill;
        self.layer?.contents = image;
        self.layer?.minificationFilter = kCAFilterLinear;
        self.layer?.rasterizationScale = NSScreen.main()!.backingScaleFactor * 2;
        self.layer?.shouldRasterize = true;
        self.layer?.contentsScale = NSScreen.main()!.backingScaleFactor;
        
        // Commit the `CATransaction`
        CATransaction.commit();
    }
}
