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
    
    var representedSong : Song? {
        return _representedSong;
    }
    
    override var backgroundStyle: NSBackgroundStyle {
        didSet {
            switch backgroundStyle {
            case .dark:
                titleLabel.textColor = NSColor.alternateSelectedControlTextColor;
                artistAlbumLabel.textColor = NSColor.alternateSelectedControlTextColor
                break;
                
            case .light:
                titleLabel.textColor = NSColor.labelColor;
                artistAlbumLabel.textColor = NSColor.secondaryLabelColor;
                break;
                
            default:
                break;
            }
        }
    }
    
    // MARK: Private Properties
    
    private var _representedSong : Song? = nil;
    
    @IBOutlet private weak var coverImageView: NSImageView!
    @IBOutlet private weak var titleLabel: NSTextField!
    @IBOutlet private weak var artistAlbumLabel: NSTextField!
    
    @IBOutlet private weak var removeButton : NSButton!
    @IBAction private func removeButton(_ sender: NSButton) {
        
    }
    
    override func mouseEntered(with event: NSEvent) {
        removeButton.alphaValue = 1;
    }
    
    override func mouseExited(with event: NSEvent) {
        removeButton.alphaValue = 0;
    }
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil));
        removeButton.alphaValue = 0;
    }
}
