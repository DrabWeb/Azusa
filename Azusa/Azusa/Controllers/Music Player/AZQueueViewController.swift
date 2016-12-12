//
//  AZQueueViewController.swift
//  Azusa
//
//  Created by Ushio on 12/12/16.
//

import Foundation
import AppKit

/// The view controller for the queue popup of `AZMusicPlayerViewController`
class AZQueueViewController: NSViewController {
    
    // MARK: - Properties
    
    /// The visual "tabs" for this queue view
    @IBOutlet weak var tabs: NSSegmentedControl!
    
    /// Called when the selected tab for `tabs` is changed
    @IBAction func tabsSelectionChanged(_ sender: NSSegmentedControl) {
        
    }
    
    /// The label for showing how many songs are in the queue in the current section(up next/history)
    @IBOutlet weak var songCountLabel: NSTextField!
    
    /// The button for clearing the current queue section
    @IBOutlet weak var clearButton: NSButton!
    
    /// Called when `clearButton` is pressed
    @IBAction func clearButtonPressed(_ sender: NSButton) {
        
    }
}
