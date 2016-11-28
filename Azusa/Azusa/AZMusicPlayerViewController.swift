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
            // If the playlist isn't already open...
            if(!playlistOpen) {
                // Darken and open the playlist
                darken(withTitlebarItemAbove: titlebarPlaylistButton);
                openPlaylist();
            }
            // If the playlist is already open...
            else {
                // Undarken and close the playlist
                undarken();
                closePlaylist();
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
            // If search isn't already open...
            if(!searchOpen) {
                // Darken and open search
                darken(withTitlebarItemAbove: titlebarSearchButton);
                openSearch();
            }
            // If search is already open...
            else {
                // Undarken and close search
                undarken();
                closeSearch();
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
    
    /// Are we currently dragging the progress slider?
    var draggingProgressSlider : Bool = false;
    
    @IBAction func progressSliderMoved(_ sender: NSSlider) {
        /// The current event of the application
        let curentEvent : NSEvent = NSApplication.shared().currentEvent!;
        
        /// Was the dragging on the slider just ended?
        let endingDrag : Bool = curentEvent.type == NSEventType.leftMouseUp;
        
        // If we ended dragging...
        if(endingDrag) {
            // Seek to the set time
            self.mpd.seek(to: Int(sender.intValue), completionHandler: nil);
            
            // Say we aren't dragging the progress slider
            draggingProgressSlider = false;
        }
        // If we are still dragging...
        else {
            // Set the position label
            self.progressCurrentTimeLabel.stringValue = MIUtilities.secondsToDisplayTime(Int(sender.intValue));
            
            // Say we are dragging the progress slider
            draggingProgressSlider = true;
        }
    }
    
    /// The container view for the playback controls
    @IBOutlet weak var playbackControlsContainer: NSView!
    
    /// The skip previous playback control button
    @IBOutlet weak var playbackControlsSkipPreviousButton: NSButton!
    
    @IBAction func playbackControlsSkipPreviousButtonPressed(_ sender: NSButton) {
        // Skip to the previous song
        self.mpd.skipPrevious(completionHandler: nil);
    }
    
    /// The play/pause playback control button
    @IBOutlet weak var playbackControlsPausePlayButton: NSButton!
    
    @IBAction func playbackControlsPausePlayButtonPressed(_ sender: NSButton) {
        // Pause/play MPD based on this button
        self.mpd.setPaused(to: ((sender.state == 1) ? true : false), completionHandler: nil);
    }
    
    /// The skip next playback control button
    @IBOutlet weak var playbackControlsSkipNextButton: NSButton!
    
    @IBAction func playbackControlsSkipNextButtonPressed(_ sender: NSButton) {
        // Skip to the next song
        self.mpd.skipNext(completionHandler: nil);
    }
    
    /// The toggle random mode playback control button
    @IBOutlet weak var playbackControlsRandomButton: NSButton!
    
    @IBAction func playbackControlsRandomButtonPressed(_ sender: NSButton) {
        // Update MPD's random mode
        self.mpd.setRandomMode(to: ((playbackControlsRandomButton.state == 1) ? true : false), completionHandler: nil);
    }
    
    /// The loop mode playback control button
    @IBOutlet weak var playbackControlsLoopButton: NSButton!
    
    /// The current loop mode the user has selected
    var currentLoopMode : MILoopMode = MILoopMode.off;
    
    @IBAction func playbackControlsLoopButtonPressed(_ sender: NSButton) {
        // Switch loop modes
        switch(currentLoopMode) {
            case .off:
                self.setLoop(mode: .playlist);
                break;
            
            case .playlist:
                self.setLoop(mode: .song);
                break;
            
            case .song:
                self.setLoop(mode: .off);
                break;
        }
    }
    
    /// Changes the loop button to match the given mode
    func displayLoop(mode : MILoopMode) {
        // Switch on the mode and act accordingly
        switch(mode) {
            case .off:
                playbackControlsLoopButton.image = #imageLiteral(resourceName: "AZLoopOff");
                break;
            
            case .playlist:
                playbackControlsLoopButton.image = #imageLiteral(resourceName: "AZLoopPlaylist");
                break;
            
            case .song:
                playbackControlsLoopButton.image = #imageLiteral(resourceName: "AZLoopSong");
                break;
        }
        
        // Set currentLoopMode to the given loop mode
        currentLoopMode = mode;
    }
    
    /// Sets the loop mode to the given mode and updates the loop button to match
    func setLoop(mode : MILoopMode) {
        // Display the given loop mode
        displayLoop(mode: mode);
        
        // Update the MPD loop mode
        self.mpd.setLoopMode(to: currentLoopMode, completionHandler: nil);
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
    
    /// The container view for the playlist view controller
    @IBOutlet weak var playlistContainerView: NSView!
    
    /// The view controller for the playlist view of this music player
    var playlistViewController : AZPlaylistViewController? = nil;
    
    /// The container view for the search view controller
    @IBOutlet weak var searchContainerView: NSView!
    
    /// The view controller for the search view of this music player
    var searchViewController : AZSearchViewController? = nil;
    
    /// Is the playlist open?
    var playlistOpen : Bool = false;
    
    // Is search open?
    var searchOpen : Bool = false;
    
    /// The MPD server to use
    var mpd : MIMPD = MIMPD(address: "127.0.0.1", port: 6600, musicDirectory: "/Volumes/Storage/macOS/Music/");
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Connect to the MPD server
        mpd.connect({ socket in
            // Display the current MPD info
            self.displayCurrent();
            
            // Set the progress listener
            self.mpd.socketConnection.progressListener = { progress in
                self.display(progress: progress);
            };
        });
        
        // Subscribe to the player, options and playlist events
        _ = self.mpd.socketConnection.subscribeTo(events: [.player, .options, .playlist], with: { eventType in
            self.displayCurrent();
        });
        
        // Subscribe to the playlist and player events
        _ = self.mpd.socketConnection.subscribeTo(events: [.playlist, .player], with: { eventType in
            // If the playlist is open...
            if(self.playlistOpen) {
                // Clear the current playlist view
                self.playlistViewController?.displayPlaylist(playlist: []);
                
                // Display the current playlist
                self.mpd.getPlaylist(log: true, completionHandler: { playlist in
                    self.playlistViewController?.displayPlaylist(playlist: playlist);
                });
            }
        });
    }
    
    override func viewWillAppear() {
        super.viewWillAppear();
        
        // Get the search and playlist view controllers
        self.playlistViewController = self.childViewControllers[0] as? AZPlaylistViewController;
        self.searchViewController = self.childViewControllers[1] as? AZSearchViewController;
    }
    
    /// The last timer created by 'close(Playlist/Search)' for doing post-animation stuff
    private var lastCloseAnimationTimer : Timer? = nil;
    
    /// Opens the playlist view
    func openPlaylist() {
        // Display the current playlist
        self.mpd.getPlaylist(log: true, completionHandler: { playlist in
            self.playlistViewController?.displayPlaylist(playlist: playlist);
        });
        
        // Cancel 'lastCloseAnimationTimer' in case the user is spamming the button or something
        lastCloseAnimationTimer?.invalidate();
        lastCloseAnimationTimer = nil;
        
        // Move the the playlist view to the top
        self.view.addSubview(playlistContainerView, positioned: .above, relativeTo: nil);
        
        // If search is open...
        if(searchOpen) {
            // Show the playlist container
            playlistContainerView.isHidden = false;
            
            // Hide the view and move it to the bottom of the subviews
            searchContainerView.isHidden = true;
            self.view.addSubview(searchContainerView, positioned: .below, relativeTo: nil);
            
            // Say search isn't open
            searchOpen = false;
        }
        // If search isn't open...
        else {
            // Set the opacity of the playlist container to 0(just in case there's a split second where you can see pre-animation)
            playlistContainerView.layer?.opacity = 0;
            
            // Show the playlist container
            playlistContainerView.isHidden = false;
            
            // Create the slide animation
            let playlistSlide : CABasicAnimation = CABasicAnimation(keyPath: "position.y");
            playlistSlide.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut);
            playlistSlide.duration = CFTimeInterval(0.5);
            playlistSlide.fromValue = -(playlistContainerView.frame.height);
            playlistSlide.toValue = 0;
            
            // Add the animation to the playlist container
            self.playlistContainerView.layer?.add(playlistSlide, forKey: "animateContents");
        }
        
        // Set the alpha value so we can actually see the view
        self.playlistContainerView.layer?.opacity = 1;
        
        // Say the playlist is open
        playlistOpen = true;
    }
    
    /// Closes the playlist view
    func closePlaylist() {
        // Create the slide animation
        let playlistSlide : CABasicAnimation = CABasicAnimation(keyPath: "position.y");
        playlistSlide.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        playlistSlide.duration = CFTimeInterval(0.3);
        playlistSlide.fromValue = 0;
        playlistSlide.toValue = -(playlistContainerView.frame.height);
        
        // Add the animation to the playlist container
        self.playlistContainerView.layer?.add(playlistSlide, forKey: "animateContents");
        
        // Wait until the animation is over
        lastCloseAnimationTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(0.25), repeats: false, block: { timer in
            // Hide the playlist container
            self.playlistContainerView.isHidden = true;
            
            // Move the playlist container to the back again
            self.view.addSubview(self.playlistContainerView, positioned: .below, relativeTo: nil);
        });
        
        // Say the playlist is closed
        playlistOpen = false;
    }
    
    /// Opens the search view
    func openSearch() {
        // Cancel 'lastCloseAnimationTimer' in case the user is spamming the button or something
        lastCloseAnimationTimer?.invalidate();
        lastCloseAnimationTimer = nil;
        
        // Move the the search view to the top
        self.view.addSubview(searchContainerView, positioned: .above, relativeTo: nil);
        
        // If the playlist is open...
        if(playlistOpen) {
            // Show the search container
            searchContainerView.isHidden = false;
            
            // Hide the view and move it to the bottom of the subviews
            playlistContainerView.isHidden = true;
            self.view.addSubview(playlistContainerView, positioned: .below, relativeTo: nil);
            
            // Say the playlist isn't open
            playlistOpen = false;
        }
        // If the playlist isn't open...
        else {
            // Set the opacity of the search container to 0(just in case there's a split second where you can see pre-animation)
            searchContainerView.layer?.opacity = 0;
            
            // Show the search container
            searchContainerView.isHidden = false;
            
            // Create the slide animation
            let searchSlide : CABasicAnimation = CABasicAnimation(keyPath: "position.y");
            searchSlide.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut);
            searchSlide.duration = CFTimeInterval(0.5);
            searchSlide.fromValue = -(searchContainerView.frame.height);
            searchSlide.toValue = 0;
            
            // Add the animation to the search container
            self.searchContainerView.layer?.add(searchSlide, forKey: "animateContents");
        }
        
        // Set the alpha value so we can actually see the view
        self.searchContainerView.layer?.opacity = 1;
        
        // Say search is open
        searchOpen = true;
    }
    
    // Closes the search view
    func closeSearch() {
        // Create the slide animation
        let searchSlide : CABasicAnimation = CABasicAnimation(keyPath: "position.y");
        searchSlide.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        searchSlide.duration = CFTimeInterval(0.3);
        searchSlide.fromValue = 0;
        searchSlide.toValue = -(searchContainerView.frame.height);
        
        // Add the animation to the search container
        self.searchContainerView.layer?.add(searchSlide, forKey: "animateContents");
        
        // Wait until the animation is over
        lastCloseAnimationTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(0.25), repeats: false, block: { timer in
            // Hide the search container
            self.searchContainerView.isHidden = true;
            
            // Move the search container to the back again
            self.view.addSubview(self.searchContainerView, positioned: .below, relativeTo: nil);
        });
        
        // Say search is closed
        searchOpen = false;
    }
    
    /// Darkens the window, and if withTitlebarItemAbove is passed either 'titlebarPlaylistButton' or 'titlebarSearchButton' it will keep that view above the darken
    func darken(withTitlebarItemAbove: NSView?) {
        // Print that we are darkening
//        print("AZMusicPlayerViewController: Darkening view with titlebar item \"\(withTitlebarItemAbove)\" above");
        
        // Move the darken view to the front
        self.view.addSubview(contentDarken, positioned: .above, relativeTo: nil);
        
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
            
            // Move the darken view to the back
            self.view.addSubview(contentDarken, positioned: .above, relativeTo: nil);
        }
    }
    
    /// Displays all the current info from MPD(song, status, cover, etc.)
    func displayCurrent() {
        /// Get the current song and status
        self.mpd.getCurrentSongAndStatus(completionHandler: { currentSong, status in
            // Display the current song and status
            self.display(song: currentSong);
            self.display(status: status);
        });
    }
    
    // The last displayed progress by display(progress:)
    var lastDisplayedProgress : Int = -1;
    
    /// Displays the given progress(in seconds) in the progress view
    func display(progress : Int) {
        // Update the progress view
        progressCurrentTimeLabel.stringValue = MIUtilities.secondsToDisplayTime(progress);
        progressSlider.intValue = Int32(progress);
        
        // Set lastDisplayedProgress
        self.lastDisplayedProgress = progress;
    }
    
    /// The last displayed status by display(status:)
    var lastDisplayedStatus : MIStatus? = nil;
    
    /// Displays the values from the given MIStatus object
    func display(status : MIStatus) {
        // Update the random and loop buttons
        playbackControlsRandomButton.state = (status.randomMode) ? 1 : 0;
//        playbackControlsRandomButton.image = (status.randomMode) ? #imageLiteral(resourceName: "AZRandomOn") : #imageLiteral(resourceName: "AZRandomOff");
        self.displayLoop(mode: status.getLoopMode);
        
        // Display the progress
        self.display(progress: Int(status.timeElapsed));
        
        // Update the pause/play button
        playbackControlsPausePlayButton.state = (status.playingState == .play) ? 0 : 1;
        playbackControlsPausePlayButton.image = (status.playingState == .play) ? #imageLiteral(resourceName: "AZPause") : #imageLiteral(resourceName: "AZPlay");
        
        // Set lastDisplayedStatus
        self.lastDisplayedStatus = status;
    }
    
    /// The last displayed song by display(song:)
    var lastDisplayedSong : MISong? = nil;
    
    /// Displays the values from the given MISong object
    func display(song : MISong) {
        // Display the cover image
        display(coverImage: song.coverImage);
        
        // Update the labels
        currentSongTitleLabel.stringValue = song.displayTitle;
        currentSongArtistLabel.stringValue = song.displayArtist;
        
        // Update the progress view
        progressSongLengthLabel.stringValue = MIUtilities.secondsToDisplayTime(song.length);
        progressSlider.maxValue = Double((song.length <= 0) ? 1 : song.length);
        
        // If lastDisplayedSong isn't nil...
        if(lastDisplayedSong != nil) {
            // If the last displayed song's path isn't the same as the given song...
            if(song.file != lastDisplayedSong!.file) {
                // Display the song's cover image
                display(coverImage: song.coverImage);
            }
        }
        
        // Set lastDisplayedSong
        self.lastDisplayedSong = song;
    }
    
    /// The last displayed cover image by display(coverImage:)
    var lastDisplayedCoverImage : NSImage? = nil;
    
    /// Displays the given NSImage as the cover image for this music player
    func display(coverImage : NSImage) {
        // Set the cover image view's image to the passed cover image
        coverImageImageView.setAspectFillImage(coverImage);
        
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
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(0.1), repeats: false, block: { _ in
            // Set the blurred image view's image to the given image
            self.coverImageBlurredImageView.setAspectFillImage(coverImage);
        });
        
        // Set lastDisplayedCoverImage
        self.lastDisplayedCoverImage = coverImage;
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
