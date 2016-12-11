//
//  AZToolbarStatusView.swift
//  Azusa
//
//  Created by Ushio on 12/11/16.
//

import Foundation
import AppKit

/// The view for a status toolbar item in a music player window
class AZToolbarStatusView: NSView {
    
    /// The box for having a background on this status view
    var background : NSBox? = nil;
    
    /// The separator line for the left of this status view
    var leftSeparator : NSBox? = nil;
    
    /// The separator line for the right of this status view
    var rightSeparator : NSBox? = nil;
    
    /// The image view for displaying the cover art
    var coverImageView : AZAspectFillImageView? = nil;
    
    /// The progress bar slider
    var progressBar : NSSlider? = nil;
    
    /// The label for showing the title of the current song
    var songTitleLabel : NSTextField? = nil;
    
    /// The label for showing the artist and album, with format `Artist • Album`
    var artistAlbumLabel : NSTextField? = nil;
    
    /// The label for the elapsed time in the current song
    var elapsedTimeLabel : NSTextField? = nil;
    
    /// The label for the duration of the current song(either `-xx:xx` or `xx:xx`)
    var durationTimeLabel : NSTextField? = nil;
    
    // MARK: - Functions
    
    /// Displays the values of the given `AZPlayerStatus` in this status view
    func display(status : AZPlayerStatus) {
        AZLogger.log("AZToolbarStatusView: Displaying status \(status)", level: .full);
        
        // Display the status info
        self.coverImageView?.setAspectFillImage(status.currentSong.coverImage);
        
        self.songTitleLabel?.stringValue = status.currentSong.displayTitle;
        self.artistAlbumLabel?.stringValue = "\(status.currentSong.displayArtist) • \(status.currentSong.displayAlbum)";
        self.elapsedTimeLabel?.stringValue = AZMusicUtilities.secondsToDisplayTime(status.timeElapsed);
        self.durationTimeLabel?.stringValue = "-\(AZMusicUtilities.secondsToDisplayTime(status.currentSong.duration - status.timeElapsed))";
        
        self.progressBar?.maxValue = Double(status.currentSong.duration);
        self.progressBar?.intValue = Int32(status.timeElapsed);
    }
    
    /// Initializes this view with all it's subviews and layout
    func initialize() {
        // Get all the views
        if(self.subviews.count >= 3) {
            self.background = self.subviews[0] as? NSBox;
            self.leftSeparator = self.subviews[1] as? NSBox;
            self.rightSeparator = self.subviews[2] as? NSBox;
            
            self.coverImageView = self.background?.subviews[0].viewWithTag(1) as? AZAspectFillImageView;
            self.progressBar = self.background?.subviews[0].viewWithTag(2) as? NSSlider;
            self.songTitleLabel = self.background?.subviews[0].viewWithTag(3) as? NSTextField;
            self.artistAlbumLabel = self.background?.subviews[0].viewWithTag(4) as? NSTextField;
            self.elapsedTimeLabel = self.background?.subviews[0].viewWithTag(5) as? NSTextField;
            self.durationTimeLabel = self.background?.subviews[0].viewWithTag(6) as? NSTextField;
        }
        
        /// The appearance of the window this view is in, defaults to vibrant light if the window is nil
        let windowAppearance : NSAppearance = (self.window?.appearance ?? NSAppearance(named: NSAppearanceNameVibrantLight)!);
        
        // Update the different views based on the appearance of the window
        if(windowAppearance == NSAppearance(named: NSAppearanceNameVibrantDark)!) {
            (self.progressBar?.cell as? AZProgressBarCell)?.backgroundColor = NSColor(calibratedWhite: 1, alpha: 0.1);
            (self.progressBar?.cell as? AZProgressBarCell)?.progressColor = NSColor(calibratedWhite: 1, alpha: 0.1);
        }
        else {
            (self.progressBar?.cell as? AZProgressBarCell)?.backgroundColor = NSColor(calibratedWhite: 0, alpha: 0.1);
            (self.progressBar?.cell as? AZProgressBarCell)?.progressColor = NSColor(calibratedWhite: 0, alpha: 0.15);
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        self.initialize();
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect);
        
        self.initialize();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
}
