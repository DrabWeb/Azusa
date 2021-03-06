//
//  MiniQueueController.swift
//  Azusa
//
//  Created by Ushio on 2/14/17.
//

import Cocoa
import Yui

class MiniQueueController: NSViewController {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var songs : [Song] = [] {
        didSet {
            refresh();
        }
    }
    
    var onClear : (() -> Void)? = nil;
    
    // MARK: Private Properties
    
    @IBOutlet private weak var tableView : NSTableView!
    @IBOutlet private weak var upNextLabel: NSTextField!
    @IBOutlet private weak var songCountLabel: NSTextField!
    @IBOutlet private weak var clearButton: NSButton!
    @IBOutlet private weak var nothingQueuedLabel: NSTextField!
    @IBOutlet private var songContextMenu: NSMenu!
    
    @IBAction func clearButton(_ sender: NSButton) {
        onClear?();
    }
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad();
        refresh();
    }
    
    // MARK: Private Methods
    
    private func refresh() {
        songCountLabel.stringValue = "\(songs.count) song\(songs.count == 1 ? "" : "s")";
        [upNextLabel, songCountLabel, clearButton].forEach {
            $0.isHidden = songs.count == 0;
        }
        nothingQueuedLabel.isHidden = songs.count != 0;
        tableView.reloadData();
        
        let preferredHeight = CGFloat(Int(tableView.rowHeight + tableView.intercellSpacing.height) * songs.count) + 47;
        let maxHeight = CGFloat(550);
        self.preferredContentSize = NSSize(width: self.view.bounds.width, height: preferredHeight > maxHeight ? maxHeight : preferredHeight);
    }
}

// MARK: - NSTableViewDataSource
extension MiniQueueController: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return songs.count;
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cellView = tableView.make(withIdentifier: "DataColumn", owner: nil) as? MiniQueueCellView {
            cellView.display(song: self.songs[row]);
            return cellView;
        }
        
        return nil;
    }
}

// MARK: - NSTableViewDelegate
extension MiniQueueController: NSTableViewDelegate {
    
}
