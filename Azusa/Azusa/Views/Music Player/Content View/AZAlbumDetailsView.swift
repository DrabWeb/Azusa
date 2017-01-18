//
//  AZAlbumDetailsView.swift
//  Azusa
//
//  Created by Ushio on 1/14/17.
//

import Cocoa

/// The view for displaying the details of an `AZAlbum`
class AZAlbumDetailsView: NSView {
    
    // MARK: - Properties
    
    /// The height for `AZAlbumDetailsView`s
    static var height : CGFloat = 490;
    
    /// The album this view is displaying
    var representedAlbum : AZAlbum? = nil;
    
    
    /// MARK: - IBOutlets
    
    /// The popup triangle for showing which album this view is attached to
    @IBOutlet weak var popupTriangle: AZPopupTriangleView!
    
    /// The image view for displaying the album's cover image
    @IBOutlet weak var coverImageView: AZRoundDarkEdgedImageView!
    
    /// The text field for displaying the duration details of this album(x songs, x minutes)
    @IBOutlet weak var durationDetailsLabel: NSTextField!
    
    /// The label for showing the title of this album
    @IBOutlet weak var albumTitleLabel: NSTextField!
    
     /// The label for showing the artist(s) of this album
    @IBOutlet weak var albumArtistLabel: NSTextField!
    
    /// The label for showing the genre and year of this album(Genre • Year)
    @IBOutlet weak var genreYearLabel: NSTextField!
    
    /// The table view for displaying the songs of this album
    @IBOutlet weak var songsTableView: NSTableView!
    
    
    // MARK: - Functions
    
    override func mouseDown(with event: NSEvent) {
        // Take mouse down so the user can't accidentally deselect collection view items when clicking this view
    }
    
    /// Displays the given album in this view
    ///
    /// - Parameter album: The `AZAlbum` to display
    /// - Parameter fade: Should the album display fade in?
    func display(album : AZAlbum, fade : Bool) {
        AZLogger.log("AZAlbumDetailsView: Displaying album \(album)");
        
        self.representedAlbum = album;
        
        album.getCoverImage({ cover in
            (fade ? self.coverImageView.animator() : self.coverImageView).image = cover;
        });
        
        /// The duration of the album in hours, seconds and minutes
        var durationInHoursMinutesSeconds : (Int, Int, Int) = AZMusicUtilities.hoursMinutesSeconds(from: album.duration);
        
        // Round up the seconds and add them to minutes
        if(durationInHoursMinutesSeconds.2 > 10) {
            durationInHoursMinutesSeconds.1 += 1;
        }
        
        var durationLabel : String = "";
        
        if(durationInHoursMinutesSeconds.0 != 0) {
            durationLabel = "\(durationInHoursMinutesSeconds.0) hour\((durationInHoursMinutesSeconds.0 == 1) ? "" : "s"), \(durationInHoursMinutesSeconds.1) minute\((durationInHoursMinutesSeconds.1 == 1) ? "" : "s")";
        }
        else {
            durationLabel = "\(durationInHoursMinutesSeconds.1) minute\((durationInHoursMinutesSeconds.1 == 1) ? "" : "s")";
        }
        
        self.durationDetailsLabel.stringValue = "\(album.songs.count) song\((album.songs.count > 1) ? "s" : ""), \(durationLabel)";
        self.durationDetailsLabel.toolTip = AZMusicUtilities.secondsToDisplayTime(album.duration);
        
        self.albumTitleLabel.stringValue = album.displayName;
        self.albumArtistLabel.stringValue = album.displayArtists(shorten: false);
        self.genreYearLabel.stringValue = "\(album.displayGenres) • \(album.displayYear)";
        
        songsTableView.reloadData();
    }
}

extension AZAlbumDetailsView: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 31;
    }
}

extension AZAlbumDetailsView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ((self.representedAlbum?.songs.count) ?? 0);
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellData : AZSong? = self.representedAlbum?.songs[row] else {
            return nil;
        }
        
        if(tableColumn?.identifier == "TrackPosition") {
            // Instantiate a new cell for this column, and if it isn't nil...
            if let cellView : NSTableCellView = tableView.make(withIdentifier: "TrackPosition", owner: nil) as? NSTableCellView {
                // Display the song's position
                cellView.textField?.stringValue = "\(row + 1)";
                
                // Return the modified cell view
                return cellView;
            }
        }
        else if(tableColumn?.identifier == "TrackTitle") {
            // Instantiate a new cell for this column, and if it isn't nil...
            if let cellView : NSTableCellView = tableView.make(withIdentifier: "TrackTitle", owner: nil) as? NSTableCellView {
                // Display the song's title
                cellView.textField?.stringValue = cellData!.displayTitle;
                
                // Return the modified cell view
                return cellView;
            }
        }
        else if(tableColumn?.identifier == "TrackDuration") {
            // Instantiate a new cell for this column, and if it isn't nil...
            if let cellView : NSTableCellView = tableView.make(withIdentifier: "TrackDuration", owner: nil) as? NSTableCellView {
                // Display the song's duration
                cellView.textField?.stringValue = AZMusicUtilities.secondsToDisplayTime(cellData!.duration);
                
                // Return the modified cell view
                return cellView;
            }
        }
        
        // Default to returning nil
        return nil;
    }
}
