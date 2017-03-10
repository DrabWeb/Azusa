//
//  MusicPlayerController.swift
//  Azusa
//
//  Created by Ushio on 2/10/17.
//

import Cocoa
import Yui

class MusicPlayerController: NSViewController {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var splitViewController : MusicPlayerSplitViewController! {
        return childViewControllers[0] as? MusicPlayerSplitViewController
    }
    
    var playerBarController : PlayerBarController! {
        return childViewControllers[1] as? PlayerBarController;
    }
    
    // MARK: Private Properties
    
    private var musicSource : MusicSource! {
        didSet {
            musicSource.eventManager.add(subscriber: EventSubscriber(events: [.connect, .player, .queue, .options, .database], performer: { event in
                self.musicSource.getPlayerStatus({ status, _ in
                    self.playerBarController.display(status: status);
                    
                    self.playerBarController.canSkipPrevious = status.currentSongPosition != 0;
                    
                    if status.playingState == .stopped || status.currentSong.isEmpty {
                        self.popOutPlayerBar();
                    }
                    else {
                        self.popInPlayerBar();
                    }
                });
                
                // Keep the mini queue updated
                if self.playerBarController.isQueueOpen {
                    self.playerBarController.onQueueOpen?();
                }
            }));
            musicSource.connect(nil);
        }
    }
    
    private var window : NSWindow!
    private weak var playerBarBottomConstraint : NSLayoutConstraint!
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        initialize();
        
        // I don't even
        // Maybe temporary? Creating an IBOutlet to the constraint(or even the player bar) makes the window not appear
        view.constraints.forEach { c in
            if c.identifier == "playerBarBottomConstraint" {
                self.playerBarBottomConstraint = c;
                return;
            }
        }
        
        NotificationCenter.default.addObserver(forName: PreferencesNotification.loaded, object: nil, queue: nil, using: { _ in
            let d = PluginManager.global.defaultPlugin!;
            self.musicSource = d.getPlugin!.getMusicSource(settings: d.settings);
        });
    }
    
    func sourceMenuItemPressed(_ sender : NSMenuItem) {
        let p = (sender.representedObject as! PluginInfo);
        musicSource = p.getPlugin!.getMusicSource(settings: p.settings);
    }
    
    func popInPlayerBar(animate : Bool = true) {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = animate ? 0.2 : 0;
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
            playerBarBottomConstraint.animator().constant = 0;
        }, completionHandler: nil);
    }
    
    func popOutPlayerBar(animate : Bool = true) {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = animate ? 0.2 : 0;
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
            playerBarBottomConstraint.animator().constant = -62;
        }, completionHandler: nil);
    }
    
    // MARK: Private methods
    
    private func initialize() {
        window = NSApp.windows.last!;
        
        window.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
        window.styleMask.insert(NSWindowStyleMask.fullSizeContentView);
        window.titleVisibility = .hidden;
        
        // Set up all the player bar actions
        
        playerBarController.onSeek = { time in
            self.musicSource.seek(to: time, completionHandler: nil);
        };
        
        self.playerBarController.onRepeat = { mode in
            self.musicSource.setRepeatMode(to: mode.next(), completionHandler: nil);
        };
        
        self.playerBarController.onPrevious = { playingState in
            self.musicSource.skipPrevious(completionHandler: nil);
        };
        
        self.playerBarController.onPausePlay = { _ in
            // TODO: Make MusicSource use playing states instead of bools
            self.musicSource.togglePaused(completionHandler: { state, _ in
                self.playerBarController.display(playingState: state ? .playing : .paused);
            });
        };
        
        self.playerBarController.onNext = { playingState in
            self.musicSource.skipNext(completionHandler: nil);
        };
        
        self.playerBarController.onShuffle = {
            self.musicSource.shuffleQueue(completionHandler: nil);
        };
        
        self.playerBarController.onVolumeChanged = { volume in
            self.musicSource.setVolume(to: volume, completionHandler: nil);
        };
        
        self.playerBarController.onQueueOpen = {
            self.musicSource.getQueue(completionHandler: { songs, currentPos, _ in
                // Drop the songs before and the current song so only up next songs are shown
                self.playerBarController.display(queue: Array(songs.dropFirst(currentPos + 1)));
            });
        };
        
        self.playerBarController.onClear = {
            self.musicSource.clearQueue(completionHandler: nil);
        };
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(0.5), repeats: true, block: { _ in
            self.musicSource.getElapsed({ elapsed, _ in
                self.playerBarController.display(progress: elapsed);
            });
        });
    }
}
