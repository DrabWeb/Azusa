//
//  StatusView.swift
//  Azusa
//
//  Created by Ushio on 2/10/17.
//

import Cocoa

class StatusView: NSView {
    
    @IBOutlet weak var coverView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var artistAlbumLabel: NSTextField!
    @IBOutlet weak var timeInfoLabel: NSTextField!
    @IBOutlet weak var progressSlider: NSSlider!

    class func instanceFromNib() -> StatusView {
        // The world's most advanced operating system™
        var topLevelObjects : NSArray = [];
        NSNib(nibNamed: "StatusView", bundle: nil)!.instantiate(withOwner: self, topLevelObjects: &topLevelObjects);
        
        var statusView : StatusView!
        
        for (_, object) in topLevelObjects.enumerated() {
            switch (object as? NSView)?.identifier ?? "" {
                case "StatusView":
                    statusView = object as! StatusView;
                
                default:
                    break;
            }
        }
        
        return statusView;
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect);
        
        wantsLayer = true;
        layer?.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor;
    }
}
