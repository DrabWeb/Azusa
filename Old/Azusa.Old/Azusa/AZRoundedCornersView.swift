//
//  AZRoundedCornersView.swift
//  Azusa
//
//  Created by Ushio on 11/23/16.
//

import Cocoa

class AZRoundedCornersView: NSView {

    /// The radius for the corners of this view
    @IBInspectable var cornerRadius : CGFloat = 5;
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        self.layer?.cornerRadius = self.cornerRadius;
        self.layer?.masksToBounds = true;
    }
}
