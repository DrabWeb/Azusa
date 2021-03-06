//
//  AZQueueTableCellView.swift
//  Azusa
//
//  Created by Ushio on 12/12/16.
//

import Cocoa

class AZQueueTableCellView: NSTableCellView {

    // MARK: - Properties
    
    /// The image view for displaying the cover art of this song
    @IBOutlet weak var coverImageView: AZAspectFillImageView!
    
    /// The label for showing the title of this song
    @IBOutlet weak var titleLabel: NSTextField!
    
    /// The label for showing the artist and album of this song, format "Artist — Album"
    @IBOutlet weak var artistAlbumLabel: NSTextField!
    
    /// The `AZSong` this cell represents
    var representedSong : AZSong? = nil;
    
    
    // MARK: - Functions
    
    override func prepareForReuse() {
        super.prepareForReuse();
        
        // Reset the image view's image
        self.coverImageView?.image = #imageLiteral(resourceName: "AZDefaultCover");
    }
    
    /// Displays the given `AZSong` in this cell
    ///
    /// - Parameter song: The `AZSong` to display
    func display(song : AZSong) {
        // Set the represented song of this cell
        self.representedSong = song;
        
        // Display the song's values
        song.getThumbnailImage({ thumbnailImage in
            self.coverImageView.image = thumbnailImage;
        });
    
        self.titleLabel.stringValue = song.displayTitle;
        self.artistAlbumLabel.stringValue = "\(song.displayArtist) — \(song.displayAlbum)";
    }
    
    deinit {
        self.coverImageView.image = nil;
        self.representedSong = nil;
    }
}
