//
//  AZMusicPlayerTitlebarView.swift
//  Azusa
//
//  Created by Ushio on 11/26/16.
//

import Cocoa

class AZMusicPlayerTitlebarView: AZGradientView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        // Style the gradient
        self.startColor = NSColor(calibratedWhite: 0, alpha: 0.4);
        self.endColor = NSColor(calibratedWhite: 0, alpha: 0);
        self.angle = 270;
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event);
        
        // Drag the window with the drag event
        self.window?.performDrag(with: event);
    }
}
