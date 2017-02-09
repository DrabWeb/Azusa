//
//  AZMusicPlayerToolbarView.swift
//  Azusa
//
//  Created by Ushio on 1/9/17.
//

import Cocoa

class AZMusicPlayerToolbarView: NSView {
    
    /// The previous song button for this toolbar
    @IBOutlet weak var previousButton: NSButton!
    
    /// The pause/play button for this toolbar
    @IBOutlet weak var pausePlayButton: NSButton!
    
    /// The next song button for this toolbar
    @IBOutlet weak var nextButton: NSButton!
    
    /// The volume slider for this toolbar
    @IBOutlet weak var volumeSlider: NSSlider!
    
    /// The `AZToolbarStatusView` for this toolbar
    @IBOutlet weak var statusView: AZToolbarStatusView!
    
    /// The container for all the views on the right side of this toolbar
    @IBOutlet weak var rightContainer: NSView!
    
    /// The open queue button of this toolbar
    @IBOutlet weak var queueButton: NSButton!
    
    /// The search field of this toolbar
    @IBOutlet weak var searchField: NSSearchField!
    
    override func awakeFromNib() {
        /// The `NSToolbarView` for the `rightContainer` styling
        let toolbarContainer = (NSClassFromString("NSToolbarView") as! NSView.Type).init();
        
        // Setup the toolbar
        toolbarContainer.frame = rightContainer.frame;
        toolbarContainer.subviews[0].removeFromSuperview();
        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false;
        
        // Move the right container into the toolbar
        toolbarContainer.addSubview(rightContainer);
        
        // Add the constraints for the right container
        toolbarContainer.addConstraints([NSLayoutConstraint(item: toolbarContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 45),
                                         NSLayoutConstraint(item: rightContainer, attribute: .leading, relatedBy: .equal, toItem: toolbarContainer, attribute: .leading, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: rightContainer, attribute: .trailing, relatedBy: .equal, toItem: toolbarContainer, attribute: .trailing, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: rightContainer, attribute: .bottom, relatedBy: .equal, toItem: toolbarContainer, attribute: .bottom, multiplier: 1, constant: -2)]);
        
        // Move the toolbar into this view
        self.addSubview(toolbarContainer);
        
        // Add the toolbar constraints
        self.addConstraints([NSLayoutConstraint(item: toolbarContainer, attribute: .leading, relatedBy: .equal, toItem: statusView, attribute: .trailing, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: toolbarContainer, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: toolbarContainer, attribute: .bottom, relatedBy: .equal, toItem: statusView, attribute: .bottom, multiplier: 1, constant: -11)]);
    }
}
