//
//  AZAspectFillImageView.swift
//  Azusa
//
//  Created by Ushio on 11/23/16.
//

import Cocoa

class AZAspectFillImageView: NSImageView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    /// Used for setting the image for aspect filling
    func setAspectFillImage(_ image : NSImage) {
        // Set the actual image so it's still accessable
        self.image = image;
        
        // Setup the layer with smoothing, scaling, etc.
        self.wantsLayer = true;
        self.layer?.contentsGravity = kCAGravityResizeAspectFill;
        self.layer?.contents = image;
        self.layer?.minificationFilter = kCAFilterLinear;
        self.layer?.rasterizationScale = NSScreen.main()!.backingScaleFactor * 2;
        self.layer?.shouldRasterize = true;
        self.layer?.contentsScale = NSScreen.main()!.backingScaleFactor;
    }
}
