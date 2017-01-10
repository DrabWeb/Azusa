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
    @IBOutlet weak var background : NSBox!
    
    /// The separator line for the left of this status view
    @IBOutlet weak var leftSeparator : NSBox!
    
    /// The separator line for the right of this status view
    @IBOutlet weak var rightSeparator : NSBox!
    
    /// The image view for displaying the cover art
    @IBOutlet weak var coverImageView : AZAspectFillImageView!
    
    /// The progress bar slider
    @IBOutlet weak var progressBar : NSSlider!
    
    /// Called when the user moves the progress bar
    @IBAction func progressBarMoved(_ sender : NSSlider) {
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
            self.elapsedTimeLabel.stringValue = AZMusicUtilities.secondsToDisplayTime(Int(sender.intValue));
            
            // Update the duration label if `lastDisplayedStatus` exists
            if(self.lastDisplayedStatus != nil) {
                self.durationTimeLabel.stringValue = "-\(AZMusicUtilities.secondsToDisplayTime(lastDisplayedStatus!.currentSong.duration - Int(sender.intValue)))";
            }
        }
    }
    
    /// The label for showing the title of the current song
    @IBOutlet weak var songTitleLabel : NSTextField!
    
    /// The label for showing the artist and album, with format `Artist — Album`
    @IBOutlet weak var artistAlbumLabel : NSTextField!
    
    /// The label for the elapsed time in the current song
    @IBOutlet weak var elapsedTimeLabel : NSTextField!
    
    /// The label for the duration of the current song(either `-xx:xx` or `xx:xx`)
    @IBOutlet weak var durationTimeLabel : NSTextField!
    
    /// The last `AZPlayerStatus` displayed by `display(status:)`
    var lastDisplayedStatus : AZPlayerStatus? = nil;
    
    /// The handler for seek events from `progressBar`, passed the time in seconds to seek to
    var seekHandler : ((Int) -> ())? = nil;
    
    /// The current `AZSong` this `AZToolbarStatusView` is displaying
    private var currentSong : AZSong? = nil;
    
    
    // MARK: - Functions
    
    /// Displays the values of the given `AZPlayerStatus` in this status view
    func display(status : AZPlayerStatus) {
        AZLogger.log("AZToolbarStatusView: Displaying status \(status)", level: .full);
        
        // Set `currentSong`
        self.currentSong = status.currentSong;
        
        // Display the status info
        if(self.lastDisplayedStatus == nil || self.lastDisplayedStatus!.currentSong != status.currentSong) {
            status.currentSong.getThumbnailImage({ thumbnailImage in
                self.coverImageView.image = thumbnailImage;
            });
        }
        
        self.songTitleLabel.stringValue = status.currentSong.displayTitle;
        self.artistAlbumLabel.stringValue = "\(status.currentSong.displayArtist) — \(status.currentSong.displayAlbum)";
        self.display(elapsed: status.timeElapsed);
        
        // Set `lastDisplayedStatus`
        self.lastDisplayedStatus = status;
    }
    
    /// Displays the given elapsed time and updates the duration to match `currentSong`
    ///
    /// - Parameters:
    ///   - elapsed: The elapsed time to display
    func display(elapsed : Int) {
        // Display the given values
        self.progressBar.intValue = Int32(elapsed);
        self.progressBar.maxValue = Double(currentSong?.duration ?? 0);
        
        self.elapsedTimeLabel.stringValue = AZMusicUtilities.secondsToDisplayTime(elapsed);
        self.durationTimeLabel.stringValue = "-\(AZMusicUtilities.secondsToDisplayTime((self.currentSong?.duration ?? 0) - elapsed))";
    }
    
    /// Initializes this view with all it's subviews and layout
    func initialize() {
        /// The appearance of the window this view is in, defaults to vibrant light if the window is nil
        let windowAppearance : NSAppearance = (self.window?.appearance ?? NSAppearance(named: NSAppearanceNameVibrantLight)!);
        
        // Update the different views based on the appearance of the window
        if(windowAppearance == NSAppearance(named: NSAppearanceNameVibrantDark)!) {
            (self.progressBar.cell as? AZProgressBarCell)?.backgroundColor = NSColor(white: 1, alpha: 0.1);
            (self.progressBar.cell as? AZProgressBarCell)?.progressColor = NSColor(white: 1, alpha: 0.1);
        }
        else {
            (self.progressBar.cell as! AZProgressBarCell).backgroundColor = NSColor(white: 188 / 256, alpha: 1.0);
            (self.progressBar.cell as! AZProgressBarCell).progressColor = NSColor(white: 112 / 256, alpha: 1.0);
            self.background.fillColor = NSColor(white: 1, alpha: 0.4);
            
            [leftSeparator, rightSeparator].forEach {
                $0!.fillColor = NSColor(white: 0, alpha: 0.2);
            }
            
            [artistAlbumLabel, elapsedTimeLabel, durationTimeLabel].forEach {
                $0!.textColor = NSColor(white: 0, alpha: 0.35);
            }
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
