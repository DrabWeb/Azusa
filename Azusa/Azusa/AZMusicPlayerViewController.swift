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
        // If we are currently darkening...
        if(darkening) {
            // If the darkening is not from the playlist button...
            if(titlebarContainer.subviews.last != titlebarPlaylistButton) {
                // Darken and open the playlist
                darken(withTitlebarItemAbove: titlebarPlaylistButton);
                openPlaylist();
            }
            // If the darkening is from the playlist button...
            else {
                // Undarken
                undarken();
            }
        }
        // If we aren't currently darkening...
        else {
            // Darken and open the playlist
            darken(withTitlebarItemAbove: titlebarPlaylistButton);
            openPlaylist();
        }
    }
    
    /// The button in the titlebar for opening the search view
    @IBOutlet weak var titlebarSearchButton: NSButton!
    
    /// When the user presses 'titlebarSearchButton'...
    @IBAction func titlebarSearchButtonPressed(_ sender: NSButton) {
        // If we are currently darkening...
        if(darkening) {
            // If the darkening is not from the search button...
            if(titlebarContainer.subviews.last != titlebarSearchButton) {
                // Darken and open search
                darken(withTitlebarItemAbove: titlebarSearchButton);
                openSearch();
            }
            // If the darkening is from the search button...
            else {
                // Undarken
                undarken();
            }
        }
        // If we aren't currently darkening...
        else {
            // Darken and open search
            darken(withTitlebarItemAbove: titlebarSearchButton);
            openSearch();
        }
    }
    
    /// The image view in 'topContainer' that shows the cover image blurred
    @IBOutlet weak var coverImageBlurredImageView: AZAspectFillImageView!
    
    /// The container for the cover image display, also does the shadow
    @IBOutlet weak var coverImageContainer: NSView!
    
    /// The image view for displaying the cover image, child of 'coverImageContainer'
    @IBOutlet weak var coverImageImageView: AZAspectFillImageView!
    
    /// The label for showing the artist of the current song
    @IBOutlet weak var currentSongArtistLabel: NSTextField!
    
    /// The label for showing the title of the current song
    @IBOutlet weak var currentSongTitleLabel: NSTextField!
    
    /// The container for progress views
    @IBOutlet weak var progressContainer: NSView!
    
    /// The label that shows the current position of the current song
    @IBOutlet weak var progressCurrentTimeLabel: NSTextField!
    
    /// The label that shows the length of the current song
    @IBOutlet weak var progressSongLengthLabel: NSTextField!
    
    /// The slider for showing the current position in the song and allowing the user to scrub
    @IBOutlet weak var progressSlider: NSSlider!
    
    @IBAction func progressSliderMoved(_ sender: NSSlider) {
        
    }
    
    /// The container view for the playback controls
    @IBOutlet weak var playbackControlsContainer: NSView!
    
    /// The skip previous playback control button
    @IBOutlet weak var playbackControlsSkipPreviousButton: NSButton!
    
    @IBAction func playbackControlsSkipPreviousButtonPressed(_ sender: NSButton) {
        
    }
    
    /// The play/pause playback control button
    @IBOutlet weak var playbackControlsPausePlayButton: NSButton!
    
    @IBAction func playbackControlsPausePlayButtonPressed(_ sender: NSButton) {
        
    }
    
    /// The skip next playback control button
    @IBOutlet weak var playbackControlsSkipNextButton: NSButton!
    
    @IBAction func playbackControlsSkipNextButtonPressed(_ sender: NSButton) {
        
    }
    
    /// The toggle random mode playback control button
    @IBOutlet weak var playbackControlsRandomButton: NSButton!
    
    @IBAction func playbackControlsRandomButtonPressed(_ sender: NSButton) {
        
    }
    
    /// The loop mode playback control button
    @IBOutlet weak var playbackControlsLoopButton: NSButton!
    
    @IBAction func playbackControlsLoopButtonPressed(_ sender: NSButton) {
        
    }
    
    /// The favourite song playback control button
    @IBOutlet weak var playbackControlsFavouriteButton: NSButton!
    
    @IBAction func playbackControlsFavouriteButtonPressed(_ sender: NSButton) {
        
    }
    
    /// The view that darkens the content of the window when using darkening
    @IBOutlet weak var contentDarken: AZColoredView!
    
    /// The view that darkens the titlebar when using darkening
    @IBOutlet weak var titlebarDarken: AZColoredView!
    
    /// Are we currently darkening the window?
    var darkening : Bool = false;
    
    /// The amount to darken when doing darkening(0 to 1)
    let darkenAmount : CGFloat = 0.5;
    
    /// The length of the darken fade animation
    let darkenAnimationDuration : CGFloat = 0.25;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
    }
    
    /// Opens the playlist view
    func openPlaylist() {
        print("Playlist");
    }
    
    /// Opens the search view
    func openSearch() {
        print("Search");
    }
    
    /// Darkens the window, and if withTitlebarItemAbove is passed either 'titlebarPlaylistButton' or 'titlebarSearchButton' it will keep that view above the darken
    func darken(withTitlebarItemAbove: NSView?) {
        // Print that we are darkening
//        print("AZMusicPlayerViewController: Darkening view with titlebar item \"\(withTitlebarItemAbove)\" above");
        
        // If 'withTitlebarItemAbove' isn't nil...
        if(withTitlebarItemAbove != nil) {
            /// Readjust the titlebar subviews so that darken is moved above all, than the given item above darken
            titlebarContainer.addSubview(titlebarDarken, positioned: .above, relativeTo: nil);
            titlebarContainer.addSubview(withTitlebarItemAbove!, positioned: .above, relativeTo: titlebarDarken);
        }
        // If 'withTitlebarItemAbove' is nil...
        else {
            // Move darken above all other subviews
            titlebarContainer.addSubview(titlebarDarken, positioned: .above, relativeTo: nil);
        }
        
        // If we aren't already darkening...
        if(!darkening) {
            /// The animation for fading in the darken views
            let darkenFade : CABasicAnimation = CABasicAnimation(keyPath: "opacity");
            
            // Set the animation duration
            darkenFade.duration = CFTimeInterval(darkenAnimationDuration);
            
            // Set the from value to 0
            darkenFade.fromValue = 0;
            
            // Set the to value to darkenAmount
            darkenFade.toValue = darkenAmount;
            
            // Add the animation to the darken views
            self.contentDarken.layer?.add(darkenFade, forKey: "animateContents");
            self.titlebarDarken.layer?.add(darkenFade, forKey: "animateContents");
            
            // Set the alpha values so they stay post-animation
            self.contentDarken.layer?.opacity = Float(darkenAmount);
            self.titlebarDarken.layer?.opacity = Float(darkenAmount);
        }
        
        // Say we are darkening the window
        self.darkening = true;
    }
    
    /// Stops darkening this window
    func undarken() {
        // If we are currently darkening...
        if(darkening) {
            // Print that we are undarkening
//            print("AZMusicPlayerViewController: Undarkening");
            
            /// The animation for fading out the darken views
            let undarkenFade : CABasicAnimation = CABasicAnimation(keyPath: "opacity");
            
            // Set the animation duration
            undarkenFade.duration = CFTimeInterval(darkenAnimationDuration);
            
            // Set the from value to darkenAmount
            undarkenFade.fromValue = darkenAmount;
            
            // Set the to value to 0
            undarkenFade.toValue = 0;
            
            // Add the animation to the darken views
            self.contentDarken.layer?.add(undarkenFade, forKey: "animateContents");
            self.titlebarDarken.layer?.add(undarkenFade, forKey: "animateContents");
            
            // Set the alpha values so they stay post-animation
            self.contentDarken.layer?.opacity = 0;
            self.titlebarDarken.layer?.opacity = 0;
            
            // Say we aren't darkening
            self.darkening = false;
        }
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
