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
    
    // MARK: - Properties
    
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
    
    /// The label for showing the artist and album, with format `Artist — Album`
    var artistAlbumLabel : NSTextField? = nil;
    
    /// The label for the elapsed time in the current song
    var elapsedTimeLabel : NSTextField? = nil;
    
    /// The label for the duration of the current song(either `-xx:xx` or `xx:xx`)
    var durationTimeLabel : NSTextField? = nil;
    
    /// The last `AZPlayerStatus` displayed by `display(status:)`
    var lastDisplayedStatus : AZPlayerStatus? = nil;
    
    /// The handler for seek events from `progressBar`, passed the time in seconds to seek to
    var seekHandler : ((Int) -> ())? = nil;
    
    
    // MARK: - Functions
    
    /// Displays the values of the given `AZPlayerStatus` in this status view
    func display(status : AZPlayerStatus) {
        AZLogger.log("AZToolbarStatusView: Displaying status \(status)", level: .full);
        
        // Display the status info
        status.currentSong.getCoverImage({ coverImage in
            self.coverImageView?.setAspectFillImage(coverImage);
        });
        
        self.songTitleLabel?.stringValue = status.currentSong.displayTitle;
        self.artistAlbumLabel?.stringValue = "\(status.currentSong.displayArtist) — \(status.currentSong.displayAlbum)";
        
        self.display(elapsed: status.timeElapsed, duration: status.currentSong.duration);
        
        // Set `lastDisplayedStatus`
        self.lastDisplayedStatus = status;
    }
    
    /// Displays the given elapsed time and progress
    ///
    /// - Parameters:
    ///   - elapsed: The elapsed time to display
    ///   - duration: The duration to display
    func display(elapsed : Int, duration : Int) {
        // Display the given values
        self.progressBar?.maxValue = Double(duration);
        self.progressBar?.intValue = Int32(elapsed);
        
        self.elapsedTimeLabel?.stringValue = AZMusicUtilities.secondsToDisplayTime(elapsed);
        self.durationTimeLabel?.stringValue = "-\(AZMusicUtilities.secondsToDisplayTime(duration - elapsed))";
    }
    
    /// Called when the user moves `progressBar`
    func progressSliderMoved(sender : NSSlider) {
        /// The current event of the application
        let curentEvent : NSEvent = NSApp.currentEvent!;
        
        /// Was the dragging on the slider just ended?
        let endingDrag : Bool = curentEvent.type == .leftMouseUp;
        
        // If we ended dragging...
        if(endingDrag) {
            // Call the seek handler
            self.seekHandler?(Int(sender.intValue));
        }
        // If we are still dragging...
        else {
            // Update the position label
            self.elapsedTimeLabel?.stringValue = AZMusicUtilities.secondsToDisplayTime(Int(sender.intValue));
            
            // Update the duration label if `lastDisplayedStatus` exists
            if(self.lastDisplayedStatus != nil) {
                self.durationTimeLabel?.stringValue = "-\(AZMusicUtilities.secondsToDisplayTime(lastDisplayedStatus!.currentSong.duration - Int(sender.intValue)))";
            }
        }
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
            
            // Setup the progress bar action
            self.progressBar?.target = self;
            self.progressBar?.action = #selector(progressSliderMoved(sender:));
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
