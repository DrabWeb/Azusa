//
//  MusicPlayerController.swift
//  Azusa
//
//  Created by Ushio on 2/10/17.
//

import Cocoa
import MPD

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
    
    private var window : NSWindow!
    @IBOutlet private weak var playerBarBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        initialize();
        
        let mpd : MIMPD = MIMPD(serverInfo: MIServerInfo(address: "127.0.0.1", port: 6600, directory: "/Volumes/Storage/macOS/Music"));
        if(mpd.connect()) {
            do {
                playerBarController.display(song: try mpd.searchForSongs(with: "Silent Wonderland ~Rem Sleep~", within: MPD_TAG_TITLE, exact: true)[0]);
            }
            catch let error {
                Logger.log(error);
            }
        }
        
        playerBarController.display(playingState: .paused);
        
        playerBarController.onSeek = { position in
            Logger.log("Seek to \(MusicUtilities.displayTime(from: position))");
            self.playerBarController.display(progress: position);
        }
        
        playerBarController.onRepeat = { repeatMode in
            Logger.log("Repeat \(repeatMode)");
            return repeatMode.next();
        }
        
        playerBarController.onPrevious = { playingState in
            Logger.log("Previous \(playingState)");
            return true;
        }
        
        playerBarController.onPausePlay = { playingState in
            Logger.log("Pause/play \(playingState)");
            return playingState.toggle();
        }
        
        playerBarController.onNext = { playingState in
            Logger.log("Next \(playingState)");
            return true;
        }
        
        playerBarController.onShuffle = { shuffling in
            Logger.log("Shuffling \(shuffling)");
            return !shuffling;
        }
        
        playerBarController.onVolumeChanged = { volume in
            Logger.log("Volume \(volume)");
        }
    }
    
    func popInPlayerBar(animate : Bool = true) {
        if !animate {
            playerBarBottomConstraint.constant = 0;
            return;
        }
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.2;
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
            playerBarBottomConstraint.animator().constant = 0;
        }, completionHandler: nil);
    }
    
    func popOutPlayerBar(animate : Bool = true) {
        if !animate {
            playerBarBottomConstraint.constant = -62;
            return;
        }
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.2;
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
    }
}
