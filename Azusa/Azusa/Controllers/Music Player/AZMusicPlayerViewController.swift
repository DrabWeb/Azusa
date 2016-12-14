//
//  AZMusicPlayerViewController.swift
//  Azusa
//
//  Created by Ushio on 12/10/16.
//

import Foundation
import AppKit

/// The view controller for a music player in Azusa
class AZMusicPlayerViewController: NSSplitViewController, NSToolbarDelegate {
    
    // MARK: - Properties
    
    /// The window for this view controller
    var window : NSWindow? = nil;
    
    /// The current `AZQueueViewController` for the popup queue view(if there is one)
    var queuePopupViewController : AZQueueViewController? = nil;
    
    
    // MARK: - Toolbar Items
    
    /// The toolbar button for skipping to the previous song
    var toolbarSkipPreviousButton: NSButton? = nil;
    
    /// The toolbar button for pausing/playing
    var toolbarPausePlayButton: NSButton? = nil;
    
    /// The toolbar button for skipping to the next song
    var toolbarSkipNextButton: NSButton? = nil;
    
    /// The toolbar slider for controlling the volume
    var toolbarVolumeSlider: NSSlider? = nil;
    
    /// The `AZToolbarStatusView` item for the toolbar of this music player
    var toolbarStatusItem : AZToolbarStatusView? = nil;
    
    /// The toolbar button for displaying the queue popup
    var toolbarQueueButton: NSButton? = nil;
    
    /// The toolbar search field for searching for songs
    var toolbarSearchField: NSSearchField? = nil;
    
    /// The `AZMusicPlayer` for this music player
    var musicPlayer : AZMusicPlayer = MIMusicPlayer(settings: ["address": "127.0.0.1", "port": 6600, "musicDirectory": "/Volumes/Storage/macOS/Music/"]);
    
    /// The `Timer` for looping and always updating the progress in the status view
    weak var progressTimer : Timer? = nil;
    
    
    // MARK: - Toolbar Actions
    
    /// Called when the user presses `toolbarSkipPreviousButton`
    @IBAction func toolbarSkipPreviousPressed(sender : NSButton) {
        // Skip to the previous song in the queue
        self.musicPlayer.skipPrevious(completionHandler: nil);
    }
    
    /// Called when the user presses `toolbarPausePlayButton`
    @IBAction func toolbarPausePlayPressed(sender : NSButton) {
        // Toggle pause on the music player
        self.musicPlayer.togglePaused(completionHandler: { playing in
            // Update the pause/play button to match the playing state
            sender.state = (playing ? 1 : 0);
        })
    }
    
    /// Called when the user presses `toolbarSkipNextButton`
    @IBAction func toolbarSkipNextPressed(sender : NSButton) {
        // Skip to the next song in the queue
        self.musicPlayer.skipNext(completionHandler: nil);
    }
    
    /// Called when the user moves `toolbarVolumeSlider`
    @IBAction func toolbarVolumeSliderMoved(sender : NSSlider) {
        // Set the volume
        self.musicPlayer.setVolume(to: Int(sender.intValue), completionHandler: nil);
    }
    
    /// Called when the user presses `toolbarQueueButton`
    @IBAction func toolbarQueuePressed(sender : NSButton) {
        
    }
    
    /// Called when text is entered into `toolbarSearchField`
    @IBAction func toolbarSearchFieldEntered(sender : NSSearchField) {
        
    }
    
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Run setup
        self.setup();
    }
    
    /// Displays the given `AZPlayerStatus` in the toolbar of this music player
    ///
    /// - Parameter status: The `AZPlayerStatus` to display
    func display(status : AZPlayerStatus) {
        AZLogger.log("AZMusicPlayerViewController: Displaying status \(status)", level: .full);
        
        // Update the toolbar items
        self.toolbarPausePlayButton?.state = ((status.playingState == .playing) ? 1 : 0);
        self.toolbarVolumeSlider?.intValue = Int32(status.volume);
        
        // Display `status` in `toolbarStatusItem`
        self.toolbarStatusItem?.display(status: status);
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
            
            
            // Start the progress loop
            self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
                // Get the current elapsed time and display it
                self.musicPlayer.getElapsed({ elapsed in
                    self.toolbarStatusItem?.display(elapsed: elapsed);
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
                self.queuePopupViewController!.display(queue: queue, current: currentPosition);
                
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
    
    override func viewWillAppear() {
        super.viewWillAppear();
        
        // Get all the toolbar items
        for(_, currentItem) in self.window!.toolbar!.items.enumerated() {
            switch(currentItem.itemIdentifier) {
                case "Previous":
                    self.toolbarSkipPreviousButton = (currentItem.view as! NSButton);
                    break;
                
                case "PausePlay":
                    self.toolbarPausePlayButton = (currentItem.view as! NSButton);
                    break;
                
                case "Next":
                    self.toolbarSkipNextButton = (currentItem.view as! NSButton);
                    break;
                
                case "Volume":
                    self.toolbarVolumeSlider = (currentItem.view as! NSSlider);
                    break;
                
                case "Status":
                    self.toolbarStatusItem = (currentItem.view as! AZToolbarStatusView);
                    
                    // Set the toolbar status item's seek event handler
                    self.toolbarStatusItem!.seekHandler = { to in
                        // Seek to the seek time
                        self.musicPlayer.seek(to: to, completionHandler: nil);
                    }
                    
                    break;
                
                case "Queue":
                    self.toolbarQueueButton = (currentItem.view as! NSButton);
                    break;
                
                case "Search":
                    self.toolbarSearchField = (currentItem.view as! NSSearchField);
                    break;
                
                default:
                    break;
            }
        }
        
        // Do the initial status display(called here so we're sure all the toolbar items are loaded)
        self.displayCurrentStatus();
    }
    
    /// Sets up this view controller(styling, init, etc.)
    func setup() {
        // Get the window of this view controller
        self.window = NSApp.windows.last!;
        
        // Style the window
        self.window!.styleMask.insert(NSWindowStyleMask.fullSizeContentView);
        self.window!.titleVisibility = .hidden;
        self.window!.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
        
        // Setup the music player
        self.setupMusicPlayer();
    }
    
    override func presentViewController(_ viewController: NSViewController, asPopoverRelativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge, behavior: NSPopoverBehavior) {
        super.presentViewController(viewController, asPopoverRelativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, behavior: behavior);
        
        // If the view controller to present is an `AZQueueViewController`...
        if let queueViewController = (viewController as? AZQueueViewController) {
            // Set `queuePopupViewController` to the view controller to present
            queuePopupViewController = queueViewController;
            
            // Set `queuePopupViewController`'s window
            queuePopupViewController!.window = self.window;
            
            // Set the primary, secondary and remove handlers
            queuePopupViewController!.queueTableViewPrimaryHandler = { tableView, selectedSongs, event in
                // If the first item in `selectedSongs` isn't nil...
                if let selectedSong = selectedSongs.first {
                    // Play `selectedSong`
                    self.musicPlayer.playSongInQueue(selectedSong, completionHandler: nil);
                }
            };
            
            queuePopupViewController!.queueTableViewSecondaryHandler = { tableView, selectedSongs, event in
                print("Secondary");
            };
            
            queuePopupViewController!.queueTableViewRemoveHandler = { tableView, selectedSongs, event in
                // Remove `selectedSongs` from the queue
                self.musicPlayer.removeFromQueue(selectedSongs, completionHandler: nil);
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
}
