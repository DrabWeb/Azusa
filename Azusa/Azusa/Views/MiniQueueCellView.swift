//
//  MiniQueueCellView.swift
//  Azusa
//
//  Created by Ushio on 2/14/17.
//

import Cocoa
import Yui

class MiniQueueCellView: NSTableCellView {
    // MARK: - Properties
    
    // MARK: Public Properties
    
    @IBOutlet weak var coverImageView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var artistAlbumLabel: NSTextField!
    
    @IBAction func removeButton(_ sender: NSButton) {
        
    }
    
    var representedSong : Song? {
        return _representedSong;
    }
    
    // MARK: Private Properties
    
    private var _representedSong : Song? = nil;
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    func display(song : Song) {
        _representedSong = song;
        
        ArtworkCache.global.getArt(of: song, withSize: .thumb, completion: { thumbnail in
            self.coverImageView.image = thumbnail;
        });
        
        titleLabel.stringValue = song.displayTitle;
        artistAlbumLabel.stringValue = "\(song.displayArtist) - \(song.displayAlbum)";
    }
}
