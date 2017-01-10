//
//  AZMusicPlayerViewController.swift
//  Azusa
//
//  Created by Ushio on 12/10/16.
//

import Foundation
import AppKit

/// The view controller for a music player in Azusa
class AZMusicPlayerViewController: NSSplitViewController, NSToolbarDelegate, NSUserNotificationCenterDelegate {
    
    // MARK: - Properties
    
    /// The window for this view controller
    var window : WAYWindow! = nil;
    
    /// The toolbar for this music player
    var toolbar : AZMusicPlayerToolbarView! = nil;
    
    /// The current `AZQueueViewController` for the popup queue view(if there is one)
    private weak var queuePopupViewController : AZQueueViewController? = nil;
    
    /// The last displayed `AZPlayerStatus` by this music player
    private var lastDisplayedStatus : AZPlayerStatus? = nil;
    
    /// The last sent song changed notification
    private var lastSongChangedNotification : NSUserNotification? = nil;
    
    /// The `AZMusicPlayer` for this music player
    var musicPlayer : AZMusicPlayer = MIMusicPlayer(settings: ["address": "127.0.0.1", "port": 6600, "musicDirectory": "/Volumes/Storage/macOS/Music/"]);
    
    /// The `Timer` for looping and always updating the progress in the status view
    weak var progressTimer : Timer? = nil;
    
    /// The last items that were right clicked in the queue popup
    private var lastQueueContextMenuItems : [AZSong] = [];
    
    
    // MARK: - Toolbar Actions
    
    /// Called when the user presses `toolbarSkipPreviousButton`
    func toolbarSkipPreviousPressed(sender : NSButton) {
        // Skip to the previous song in the queue
        self.skipPrevious();
    }
    
    /// Called when the user presses `toolbarPausePlayButton`
    func toolbarPausePlayPressed(sender : NSButton) {
        // Toggle the paused state
        self.togglePaused();
    }
    
    /// Called when the user presses `toolbarSkipNextButton`
    func toolbarSkipNextPressed(sender : NSButton) {
        // Skip to the next song in the queue
        self.skipNext();
    }
    
    /// Called when the user moves `toolbarVolumeSlider`
    func toolbarVolumeSliderMoved(sender : NSSlider) {
        // Set the volume
        self.setVolume(Int(sender.intValue));
    }
    
    /// Called when the user presses `toolbarQueueButton`
    func toolbarQueuePressed(sender : NSButton) {
        // Open the queue popup
        openQueuePopup();
    }
    
    /// Called when text is entered into `toolbarSearchField`
    func toolbarSearchFieldEntered(sender : NSSearchField) {
        
    }
    
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Run setup
        self.setup();
        
        // Set the notification center's delegate
        NSUserNotificationCenter.default.delegate = self;
    }
    
    override func toggleSidebar(_ sender: Any?) {
        // Toggle the collapsed state of the sidebar
        self.splitViewItems[0].animator().isCollapsed = !self.splitViewItems[0].isCollapsed;
    }
    
    /// Displays the given `AZPlayerStatus` in the toolbar of this music player
    ///
    /// - Parameter status: The `AZPlayerStatus` to display
    func display(status : AZPlayerStatus) {
        AZLogger.log("AZMusicPlayerViewController: Displaying status \(status)", level: .full);
        
        // Update the toolbar items
        self.toolbar.pausePlayButton.state = ((status.playingState == .playing) ? 1 : 0);
        self.toolbar.pausePlayButton.image = ((toolbar.pausePlayButton.state == 0) ? #imageLiteral(resourceName: "AZPlay") : #imageLiteral(resourceName: "AZPause"));
        self.toolbar.volumeSlider.intValue = Int32(status.volume);
        
        // Display `status` in `toolbarStatusItem`
        self.toolbar.statusView.display(status: status);
        
        /// The last displayed `AZSong`
        let lastDisplayedSong : AZSong? = self.lastDisplayedStatus?.currentSong;
        
        // If `lastDisplayedSong` isnt nil...
        if(lastDisplayedSong != nil) {
            // If the current song isn't the last displayed song...
            if(status.currentSong != lastDisplayedSong!) {
                // If the player is playing and the current song isn't an empty one...
                if((status.playingState == .playing) && !status.currentSong.isEmpty()) {
                    // Get the cover image for the current song
                    status.currentSong.getThumbnailImage({ thumbnailImage in
                        /// The notification to show the current song
                        let songChangedNotification : NSUserNotification = NSUserNotification();
                        
                        // Set the private keys for iTunes like behaviour, custom app icon image, no border around the identity image, and show the skip button even though it's a banner
                        songChangedNotification.setValue(thumbnailImage, forKey: "_identityImage");
                        songChangedNotification.setValue(true, forKey: "_showsButtons");
                        
                        // Set the title and informative text
                        songChangedNotification.title = status.currentSong.displayTitle;
                        songChangedNotification.informativeText = "\(status.currentSong.displayArtist) — \(status.currentSong.displayAlbum)";
                        
                        // Create the skip button
                        songChangedNotification.hasActionButton = true;
                        songChangedNotification.actionButtonTitle = "Skip";
                        
                        // Remove the previous song changed notification(if there is one)
                        if(self.lastSongChangedNotification != nil) {
                            NSUserNotificationCenter.default.removeDeliveredNotification(self.lastSongChangedNotification!);
                        }
                        
                        // Deliver the notification
                        NSUserNotificationCenter.default.deliver(songChangedNotification);
                        
                        // Set `lastSongChangedNotification`
                        self.lastSongChangedNotification = songChangedNotification;
                    });
                }
            }
        }
        
        // Set `lastDisplayedStatus`
        self.lastDisplayedStatus = status;
    }
    
    /// Sets up everything related to `musicPlayer`; connection, event listeners, etc.
    func setupMusicPlayer() {
        // Connect the music player
        musicPlayer.connect({ successful in
            
            // Add the event subscribers
            
            // Add the player/queue event subscriber for status updating
            self.musicPlayer.eventSubscriber.add(subscription: AZEventSubscription(events: [.player, .queue], performer: { event in
                // Display the current status
                self.displayCurrentStatus();
                
                // Display the current queue
                self.displayCurrentQueue();
            }));
            
            // Add the volume event subscriber for status updating
            self.musicPlayer.eventSubscriber.add(subscription: AZEventSubscription(events: [.volume], performer: { event in
                // Display the current status
                self.displayCurrentStatus();
            }));
            
            
            // Start the progress loop
            self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
                // Get the current elapsed time and display it
                self.musicPlayer.getElapsed({ elapsed in
                    self.toolbar.statusView.display(elapsed: elapsed);
                });
            });
        });
    }
    
    /// Displays the current status from `musicPlayer`
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    private func displayCurrentStatus(completionHandler : (() -> ())? = nil) {
        // Get the current player status
        self.musicPlayer.getPlayerStatus({ playerStatus in
            // Display the current player status
            self.display(status: playerStatus);
            
            // Call the completion handler
            completionHandler?();
        });
    }
    
    /// Displays the current queue in `queuePopupViewController`(if it exists)
    ///
    /// - Parameter completionHandler: The completion handler to call when the operation finishes(optional)
    private func displayCurrentQueue(completionHandler : (() -> ())? = nil) {
        // If `queuePopupViewController` isn't nil(checking here so we don't waste time getting the queue for nothing)...
        if(self.queuePopupViewController != nil) {
            // Get the current queue
            self.musicPlayer.getQueue(completionHandler: { queue, currentPosition in
                // Display it in `queuePopupViewController`
                self.queuePopupViewController?.display(queue: queue, current: currentPosition);
                
                // Call the completion handler
                completionHandler?();
            });
        }
        // If `queuePopupViewController` is nil....
        else {
            // Just call the completion handler now
            completionHandler?();
        }
    }
    
    /// Opens the queue popup, closing the current open one if there is one
    func openQueuePopup() {
        // Close any already open queue popups
        if(self.queuePopupViewController != nil) {
            self.dismissViewController(queuePopupViewController!);
        }
        
        /// The new `AZQueueViewController` to display
        let newQueueViewController : AZQueueViewController = self.storyboard!.instantiateController(withIdentifier: "queueViewController") as! AZQueueViewController;
        
        // Display `AZQueueViewController` as a popup relative to `toolbarQueueButton`
        self.presentViewController(newQueueViewController, asPopoverRelativeTo: self.toolbar.queueButton.bounds, of: self.toolbar.queueButton, preferredEdge: .maxY, behavior: .transient);
    }
    
    override func viewWillAppear() {
        super.viewWillAppear();
        
        // Do the initial status display(called here so we're sure all the toolbar items are loaded)
        self.displayCurrentStatus();
    }
    
    /// Creates a new `AZMusicPlayerToolbarView` and attaches it to this view
    func createToolbar() {
        /// The top level items of the newly loaded `AZMusicPlayerToolbarView` nib
        var topLevelItems : NSArray = [];
        
        // Load the `AZMusicPlayerToolbarView` nib into `topLevelItems`
        Bundle.main.loadNibNamed("AZMusicPlayerToolbarView", owner: nil, topLevelObjects: &topLevelItems);
        
        // Get the titlebar view of this window, and if it isn't nil...
        if let titlebarView = self.window.standardWindowButton(.closeButton)?.superview {
            // Get the `AZMusicPlayerToolbarView` from `topLevelItems`
            topLevelItems.forEach {
                if let toolbarView = ($0 as? AZMusicPlayerToolbarView) {
                    // Add the toolbar to this window
                    self.toolbar = toolbarView;
                    titlebarView.addSubview(toolbar);
                    toolbarView.setFrameSize(NSSize(width: titlebarView.frame.size.width, height: 45));
                    
                    // Setup the toolbar item actions
                    self.toolbar.previousButton.action = #selector(AZMusicPlayerViewController.toolbarSkipPreviousPressed(sender:));
                    self.toolbar.pausePlayButton.action = #selector(AZMusicPlayerViewController.toolbarPausePlayPressed(sender:));
                    self.toolbar.nextButton.action = #selector(AZMusicPlayerViewController.toolbarSkipNextPressed(sender:));
                    self.toolbar.volumeSlider.action = #selector(AZMusicPlayerViewController.toolbarVolumeSliderMoved(sender:));
                    self.toolbar.queueButton.action = #selector(AZMusicPlayerViewController.toolbarQueuePressed(sender:));
                    self.toolbar.searchField.action = #selector(AZMusicPlayerViewController.toolbarSearchFieldEntered(sender:));
                    
                    self.toolbar.statusView.seekHandler = { position in
                        self.musicPlayer.seek(to: position, completionHandler: nil);
                    }
                }
            }
        }
    }
    
    /// Sets up this view controller(styling, init, etc.)
    func setup() {
        // Get the window of this view controller
        self.window = (NSApp.windows.last! as! WAYWindow);
        
        // Style the window
        self.window.styleMask.insert(NSWindowStyleMask.fullSizeContentView);
        self.window.titleVisibility = .hidden;
        self.window.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
        self.window.titleBarHeight = 45;
        self.window.trafficLightButtonsTopMargin = 0;
        self.window.trafficLightButtonsLeftMargin = 12;
        
        // Set the sidebar's maximum size
        self.splitViewItems[0].maximumThickness = 500;
        
        // Set the content view's minimum size
        self.splitViewItems[1].minimumThickness = 100;
        
        // Setup the music player
        self.setupMusicPlayer();
        
        // Create the toolbar
        createToolbar();
    }
    
    override func presentViewController(_ viewController: NSViewController, asPopoverRelativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge, behavior: NSPopoverBehavior) {
        super.presentViewController(viewController, asPopoverRelativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, behavior: behavior);
        
        // If the view controller to present is an `AZQueueViewController`...
        if let queueViewController = (viewController as? AZQueueViewController) {
            // Set `queuePopupViewController` to the view controller to present
            queuePopupViewController = queueViewController;
            
            // Set `queuePopupViewController`'s window
            queuePopupViewController!.window = self.window;
            
            // Set the queue action handlers
            
            queuePopupViewController!.queueTableViewPrimaryHandler = { tableView, selectedSongs, event in
                // If the first item in `selectedSongs` isn't nil...
                if let selectedSong = selectedSongs.first {
                    // Play `selectedSong`
                    self.musicPlayer.playSongInQueue(selectedSong, completionHandler: nil);
                }
            };
            
            queuePopupViewController!.queueTableViewSecondaryHandler = { tableView, selectedSongs, event in
                // Set `lastQueueContextMenuItems`
                self.lastQueueContextMenuItems = selectedSongs;
                
                // If at least one song was selected...
                if(selectedSongs.count > 0) {
                    /// The context menu to display
                    let contextMenu : NSMenu = NSMenu();
                    
                    // Add the context menu items
                    
                    // Add the selected item count item and separator
                    contextMenu.addItem(withTitle: "\(selectedSongs.count) song\((selectedSongs.count == 1) ? "" : "s")", action: nil, keyEquivalent: "");
                    contextMenu.addItem(NSMenuItem.separator());
                    
                    contextMenu.addItem(withTitle: "Play", action: #selector(AZMusicPlayerViewController.queuePlay), keyEquivalent: "");
                    contextMenu.addItem(withTitle: "Play Next", action: #selector(AZMusicPlayerViewController.queuePlayNext), keyEquivalent: "");
                    contextMenu.addItem(withTitle: "Remove From Queue", action: #selector(AZMusicPlayerViewController.queueRemoveFromQueue), keyEquivalent: "");
                    
                    // Display the context menu
                    NSMenu.popUpContextMenu(contextMenu, with: event, for: self.queuePopupViewController!.view);
                    
                    // Clear `lastQueueContextMenuItems`
                    self.lastQueueContextMenuItems.removeAll();
                }
            };
            
            queuePopupViewController!.queueTableViewRemoveHandler = { tableView, selectedSongs, event in
                // Remove `selectedSongs` from the queue
                self.musicPlayer.removeFromQueue(selectedSongs, completionHandler: nil);
            };
            
            queuePopupViewController!.shuffleHandler = {
                // Shuffle the queue
                self.shuffleQueue();
            };
            
            queuePopupViewController!.clearHandler = {
                // Clear the queue
                self.clearQueue();
            };
            
            // Display the current queue
            self.displayCurrentQueue();
        }
    }
    
    override func dismissViewController(_ viewController: NSViewController) {
        super.dismissViewController(viewController);
        
        // If the view controller to dismiss is `queuePopupViewController`...
        if(viewController == self.queuePopupViewController) {
            // Remove `queuePopupViewController`
            self.queuePopupViewController = nil;
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        // If the clicked button was the skip button...
        if((notification.activationType == .actionButtonClicked) && notification.actionButtonTitle == "Skip") {
            // Skip to the next song
            self.skipNext();
        }
    }
    
    
    // MARK: - Music Player Functions
    
    /// Toggles the paused state of `musicPlayer`
    func togglePaused() {
        // Toggle pause on the music player
        self.musicPlayer.togglePaused(completionHandler: nil);
    }
    
    /// Stops playback for `musicPlayer`
    func stopPlayback() {
        // Stop playback for the music player
        self.musicPlayer.stop(completionHandler: nil);
    }
    
    /// Skips to the next song of `musicPlayer`
    func skipNext() {
        // Skip to the next song
        self.musicPlayer.skipNext(completionHandler: nil);
    }
    
    /// Skips to the previous song of `musicPlayer`
    func skipPrevious() {
        // Skip to the next song
        self.musicPlayer.skipPrevious(completionHandler: nil);
    }
    
    /// Increases the volume of `musicPlayer` by 5
    func increaseVolume() {
        // Add 5 to the current volume
        self.musicPlayer.setRelativeVolume(to: 5, completionHandler: nil);
    }
    
    /// Decreases the volume of `musicPlayer` by 5
    func decreaseVolume() {
        // Subtract 5 from the current volume
        self.musicPlayer.setRelativeVolume(to: -5, completionHandler: nil);
    }
    
    /// Sets the volume of this music player to the given value
    ///
    /// - Parameter volume: The volume to set to
    func setVolume(_ volume : Int) {
        // Set the volume
        self.musicPlayer.setVolume(to: volume, completionHandler: nil);
    }
    
    /// Jumps to and starts playing the first song in the queue
    func jumpToFirstSong() {
        // Jump to the first song
        self.musicPlayer.seek(to: 0, trackPosition: 0, completionHandler: nil);
        
        // Make sure the player is playing
        self.musicPlayer.setPaused(false, completionHandler: nil);
    }
    
    /// Shuffles the current queue
    func shuffleQueue() {
        // Shuffle the queue
        self.musicPlayer.shuffleQueue(completionHandler: nil);
    }
    
    /// Clears the current queue
    func clearQueue() {
        // Clear the queue
        self.musicPlayer.clearQueue(completionHandler: nil);
    }
    
    
    // MARK: - Queue Context Menu Actions
    
    /// Called by the queue popup when "Play" is selected in the context menu
    @objc private func queuePlay() {
        // Tell the music player to play the first song in `lastQueueContextMenuItems`
        self.musicPlayer.playSongInQueue(lastQueueContextMenuItems.first!, completionHandler: nil);
    }
    
    /// Called by the queue popup when "Play Next" is selected in the context menu
    @objc private func queuePlayNext() {
        // Tell the music player to play the songs in `lastQueueContextMenuItems` next
        self.musicPlayer.moveAfterCurrent(lastQueueContextMenuItems, completionHandler: nil);
    }
    
    /// Called by the queue popup when "Remove From Queue" is selected in the context menu
    @objc private func queueRemoveFromQueue() {
        // Tell the music player to remove the songs in `lastQueueContextMenuItems` from the queue
        self.musicPlayer.removeFromQueue(lastQueueContextMenuItems, completionHandler: nil);
    }
}
