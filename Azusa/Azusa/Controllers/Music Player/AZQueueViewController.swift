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
    
    /// The window to use for scaling the popup to maximum this window's size
    var window : NSWindow? = nil;
    
    /// The visual "tabs" for this queue view
    @IBOutlet weak var tabs: NSSegmentedControl!
    
    /// Called when the selected tab for `tabs` is changed
    @IBAction func tabsSelectionChanged(_ sender: NSSegmentedControl) {
        // Show the appropriate view
        self.showItemsForSelectedTab();
    }
    
    /// The label for showing how many songs are in the queue in the current section(up next/history)
    @IBOutlet weak var songCountLabel: NSTextField!
    
    /// The button for shuffling the current queue
    @IBOutlet weak var shuffleButton: NSButton!
    
    /// Called when `shuffleButton` is pressed
    @IBAction func shuffleButtonPressed(_ sender: NSButton) {
        // Call the shuffle handler
        self.shuffleHandler?();
    }
    
    /// The button for clearing the current queue
    @IBOutlet weak var clearButton: NSButton!
    
    /// Called when `clearButton` is pressed
    @IBAction func clearButtonPressed(_ sender: NSButton) {
        // Call the clear handler
        self.clearHandler?();
    }
    
    /// The scroll view for `queueTableView`
    @IBOutlet weak var queueTableViewScrollView: NSScrollView!
    
    /// The table view for showing queue items
    @IBOutlet weak var queueTableView: AZQueueTableView!
    
    /// The items for `queueTableView`
    var queueTableViewItems : [AZSong] = [];
    
    /// The last set queue by `display(queue:current:)`
    private var currentQueue : [AZSong] = [];
    
    /// Was `storeUpNext` called?
    private var storedUpNext : Bool = false;
    
    /// The up next of `currentQueue`
    private var currentUpNext : [AZSong] = [];
    
    /// Was `storeHistory` called?
    private var storedHistory : Bool = false;
    
    /// The history of `currentQueue`
    private var currentHistory : [AZSong] = [];
    
    /// The last set current song position by `display(queue:current:)`
    private var currentSongPosition : Int = -1;
    
    /// The closure to call when the user either double clicks or presses enter in `queueTableView`, normally plays the clicked track
    ///
    /// Passed `queueTableView`, the selected `AZSong`s and the event
    var queueTableViewPrimaryHandler : ((AZQueueTableView, [AZSong], NSEvent) -> ())? = nil;
    
    /// The closure to call when the user right clicks in `queueTableView`, normally shows a context menu
    ///
    /// Passed `queueTableView`, the selected `AZSong`s and the event
    var queueTableViewSecondaryHandler : ((AZQueueTableView, [AZSong], NSEvent) -> ())? = nil;
    
    /// The closure to call when the user selects songs and presses backspace/delete in `queueTableView`, should remove the selected songs from the queue
    ///
    /// Passed `queueTableView`, the selected `AZSong`s and the event
    var queueTableViewRemoveHandler : ((AZQueueTableView, [AZSong], NSEvent) -> ())? = nil;
    
    /// The closure to call when the user presses the "shuffle" button
    var shuffleHandler : (() -> ())? = nil;
    
    /// The closure to call when the user presses the "clear" button
    var clearHandler : (() -> ())? = nil;
    
    
    // MARK: - Functions
    
    override func keyDown(with event: NSEvent) {
        // Switch on the keycode and act appropriately
        switch(event.keyCode) {
            // Left arrow
            case 123:
                self.tabs.selectSegment(withTag: (tabs.selectedSegment == 1) ? 0 : 1);
                self.tabsSelectionChanged(self.tabs);
                break;
            
            // Right arrow
            case 124:
                self.tabs.selectSegment(withTag: (tabs.selectedSegment == 1) ? 0 : 1);
                self.tabsSelectionChanged(self.tabs);
                break;
            
            default:
                super.keyDown(with: event);
                break;
        }
    }
    
    /// Displays the given array of `AZSong`s in this queue view
    ///
    /// - Parameters:
    ///   - queue: The array of `AZSong`s to display
    ///   - current: The position of the current playing song in the queue
    func display(queue : [AZSong], current : Int) {
        AZLogger.log("AZQueueViewController: Displaying queue with \(queue.count) songs, current is #\(current)");
        AZLogger.log("AZQueueViewController: Queue items: \"\(queue)\", current: #\(current)", level: .high);
        
        // Reset `storedUpNext` and `storedHistory`
        storedUpNext = false;
        storedHistory = false;
        
        // Set `currentQueue` and `currentSongPosition`
        self.currentQueue = queue;
        self.currentSongPosition = current;
      
        // Show the appropriate view
        self.showItemsForSelectedTab();
      
        // Make the queue table view the first responder
        self.view.window?.makeFirstResponder(self.queueTableView);
        
        // Set the `queueTableView` action handlers
        self.queueTableView.primaryHandler = self.queueTableViewPrimaryHandler;
        self.queueTableView.secondaryHandler = self.queueTableViewSecondaryHandler;
        self.queueTableView.removeHandler = self.queueTableViewRemoveHandler;
    }
    
    /// Displays the songs from `currentUpNext` in `queueTableView`
    func displayUpNext() {
        AZLogger.log("AZQueueViewController: Displaying up next with \(self.currentUpNext.count) songs");
        
        if(!storedUpNext) {
            storeUpNext();
        }
        
        // Set the table view to display `currentUpNext`
        self.queueTableViewItems = self.currentUpNext;
        
        // Update the song count label
        self.songCountLabel.stringValue = "\(queueTableViewItems.count) song\((queueTableViewItems.count == 1) ? "" : "s")";
        
        // Update `preferredContentSize`
        self.updatePreferredContentSize();
        
        // Update the queue table view
        self.queueTableView.reloadData();
    }
    
    /// Displays the songs from `currentHistory` in `queueTableView`
    func displayHistory() {
        AZLogger.log("AZQueueViewController: Displaying history with \(self.currentHistory.count) songs");
        
        if(!storedHistory) {
            storeHistory();
        }
        
        // Set the table view to display `currentHistory`
        self.queueTableViewItems = self.currentHistory;
        
        // Update the song count label
        self.songCountLabel.stringValue = "\(queueTableViewItems.count) song\((queueTableViewItems.count == 1) ? "" : "s")";
        
        // Update `preferredContentSize`
        self.updatePreferredContentSize();

        // Update the queue table view
        self.queueTableView.reloadData();
    }
    
    /// Gets the up next of `currentQueue` and stores it in `currentUpNext`
    private func storeUpNext() {
        // Clear `currentUpNext`
        currentUpNext.removeAll();
        
        // If there is any songs in `currentQueue`, the current song isn't the last and `currentSongPosition` is greater than -1...
        if(!currentQueue.isEmpty && (currentSongPosition != (currentQueue.count - 1)) && currentSongPosition > -1) {
            // For every song in `currentQueue` after the current song...
            for index in (currentSongPosition + 1)...(currentQueue.count - 1) {
                // Add the current song to `currentUpNext`
                currentUpNext.append(currentQueue[index]);
            }
        }
        // If `currentSongPosition` is `-1` and `currentQueue` isn't empty(for handling if the queue is set but no song has been played)...
        else if(!currentQueue.isEmpty && self.currentSongPosition == -1) {
            // Set `currentUpNext` to `currentQueue`
            self.currentUpNext = currentQueue;
        }
        
        storedUpNext = true;
    }
    
    /// Gets the history of `currentQueue` and stores it in `currentHistory`
    private func storeHistory() {
        // Clear `currentHistory`
        currentHistory.removeAll();
        
        // If there is any songs in `currentQueue`, the current song isn't the first and `currentSongPosition` is greater than -1...
        if(!currentQueue.isEmpty && (currentSongPosition != 0) && currentSongPosition > -1) {
            // For every song in `currentQueue` up to the current song...
            for index in 0...(currentSongPosition - 1) {
                // Add the current song to `currentHistory`
                currentHistory.append(currentQueue[index]);
            }
        }
        
        // Reverse `currentHistory` to have the oldest queue songs on the bottom
        self.currentHistory.reverse();
        
        storedHistory = true;
    }
    
    /// Updates `preferredContentSize` to match `queueTableViewItems`
    private func updatePreferredContentSize() {
        /// The height of all the items in `queueTableViewItems`, plus the height of the other elements in the popup
        var queueTableViewItemsHeight : Int = ((queueTableViewItems.count * 49) + 92);
        
        /// The max height this popup can be, set to the height of `window`(defaults to 550) minus 50
        let maxHeight : Int = (Int(self.window?.frame.height ?? 550) - 50);
        
        // Make sure `queueTableViewItemsHeight` isn't larger than `maxHeight`
        if(queueTableViewItemsHeight > maxHeight) {
            queueTableViewItemsHeight = maxHeight;
        }
        
        // Set the preferred content size
        self.preferredContentSize = NSSize(width: 330, height: queueTableViewItemsHeight);
    }
    
    /// Shows the different views(up next/history) based on the selected tab from `tabs`
    func showItemsForSelectedTab() {
        // Show up next/history based on the selected tab
        switch(self.tabs.selectedSegment) {
            case 0:
                self.displayUpNext();
                break;
            
            case 1:
                self.displayHistory();
                break;
            
            default:
                break;
        }
    }
    
    deinit {
        self.currentQueue = [];
        self.currentUpNext = [];
        self.currentHistory = [];
        self.queueTableViewItems = [];
        
        self.clearHandler = nil;
        self.shuffleHandler = nil;
        self.queueTableViewRemoveHandler = nil;
        self.queueTableViewPrimaryHandler = nil;
        self.queueTableViewRemoveHandler = nil;
    }
}


// MARK: - Extensions

extension AZQueueViewController: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        // Return the amount of items in `queueTableViewItems`
        return self.queueTableViewItems.count;
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Instantiate a new cell for this column, and if it isn't nil...
        if let cellView : AZQueueTableCellView = tableView.make(withIdentifier: "Main Column", owner: nil) as? AZQueueTableCellView {
            // Display the song at `row` in `cellView`
            cellView.display(song: self.queueTableViewItems[row]);
            
            // Don't reuse cells
            cellView.identifier = nil;
            
            // Return the modified cell view
            return cellView;
        }
        
        // Default to returning nil
        return nil;
    }
}

extension AZQueueViewController: NSTableViewDelegate {
    
}
