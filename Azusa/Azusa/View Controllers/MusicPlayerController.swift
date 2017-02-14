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
    
    var musicSource : MusicSource!
    
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
        
        // REMOVEME: This is only for making PluginManager call it's init
        PluginManager.global;
        
        initialize();
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
