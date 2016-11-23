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
//        self.layer = CALayer();
        self.layer?.contentsGravity = kCAGravityResizeAspectFill;
        self.layer?.contents = self.image;
//        self.wantsLayer = true;
    }
}
