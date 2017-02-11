//
//  ToolbarStatusView.swift
//  Azusa
//
//  Created by Ushio on 2/10/17.
//

import Cocoa

// The view for a `StatusView` inside of a window toolbar
class ToolbarStatusView: NSView {
    override func awakeFromNib() {
        super.awakeFromNib();
        
        let statusView = StatusView.instanceFromNib();
        statusView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable];
        statusView.translatesAutoresizingMaskIntoConstraints = true;
        statusView.frame = NSRect(x: 0, y: 1, width: self.bounds.width, height: self.bounds.height);
        addSubview(statusView);
    }
}
