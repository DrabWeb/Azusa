//
//  AZMusicPlayerViewController.swift
//  Azusa
//
//  Created by Ushio on 11/23/16.
//

import Cocoa

class AZMusicPlayerViewController: NSViewController {

    /// The main window of this view controller
    var musicPlayerWindow : NSWindow = NSWindow();
    
    /// The container view for the views in the top of the music player(titlebar, blurred cover image, etc.)
    @IBOutlet weak var topContainer: NSView!
    
    /// The container view for the titlebar(also draws the fade gradient)
    @IBOutlet weak var titlebarContainer: AZGradientView!
    
    /// The button in the titlebar for opening the playlist viewer
    @IBOutlet weak var titlebarPlaylistButton: NSButton!
    
    /// When the user presses 'titlebarPlaylistButton'...
    @IBAction func titlebarPlaylistButtonPressed(_ sender: NSButton) {
        /// REMOVEME: Small display(coverImage:) test
        self.display(coverImage: #imageLiteral(resourceName: "AZExampleCoverHauru"));
    }
    
    /// The button in the titlebar for opening the search view
    @IBOutlet weak var titlebarSearchButton: NSButton!
    
    /// When the user presses 'titlebarSearchButton'...
    @IBAction func titlebarSearchButtonPressed(_ sender: NSButton) {
        /// REMOVEME: Small display(coverImage:) test
        self.display(coverImage: #imageLiteral(resourceName: "AZExampleCoverMoe"));
    }
    
    /// The image view in 'topContainer' that shows the cover image blurred
    @IBOutlet weak var coverImageBlurredImageView: AZAspectFillImageView!
    
    /// The container for the cover image display, also does the shadow
    @IBOutlet weak var coverImageContainer: NSView!
    
    /// The image view for displaying the cover image, child of 'coverImageContainer'
    @IBOutlet weak var coverImageImageView: AZAspectFillImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
    }
    
    /// Displays the given NSImage as the cover image for this music player
    func display(coverImage : NSImage) {
        // Set the cover image view's image to the passed cover image
        coverImageImageView.image = coverImage;
        
        /// The animation for crossfading coverImageBlurredImageView's image
        let coverBlurCrossFade : CABasicAnimation = CABasicAnimation(keyPath: "contents");
        
        // Set the animation duration
        coverBlurCrossFade.duration = 0.25;
        
        /// The CGRect of coverImageBlurredImageView's image
        var fromImageRect : CGRect = NSRect(x: 0, y: 0, width: self.coverImageBlurredImageView.image!.size.width, height: self.coverImageBlurredImageView.image!.size.height);
        
        // Set the from value of the crossfade to the current image
        coverBlurCrossFade.fromValue = self.coverImageBlurredImageView.image!.cgImage(forProposedRect: &fromImageRect, context: nil, hints: nil);
        
        /// The CGRect of coverImage
        var toImageRect : CGRect = NSRect(x: 0, y: 0, width: coverImage.size.width, height: coverImage.size.height);
        
        // Set the to value of the cross fade to the given cover image
        coverBlurCrossFade.toValue = coverImage.cgImage(forProposedRect: &toImageRect, context: nil, hints: nil);
        
        // Add the animation to the blurred image view
        self.coverImageBlurredImageView.layer?.add(coverBlurCrossFade, forKey: "animateContents");
        
        // Set the blurred image view's image to the given image
        self.coverImageBlurredImageView.image = coverImage;
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the window
        musicPlayerWindow = NSApplication.shared().windows.last!;
        
        // Style the window
        musicPlayerWindow.styleMask.insert(NSWindowStyleMask.fullSizeContentView);
        musicPlayerWindow.titlebarAppearsTransparent = true;
        musicPlayerWindow.titleVisibility = .hidden;
        musicPlayerWindow.standardWindowButton(.closeButton)?.superview?.superview?.removeFromSuperview();
        musicPlayerWindow.backgroundColor = NSColor(calibratedWhite: 0.08, alpha: 1);
    }
}
