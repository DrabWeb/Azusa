//
//  AZPreferences.swift
//  Azusa
//
//  Created by Ushio on 11/24/16.
//

import Foundation
import AppKit

/// The class for storing user preferences
class AZPreferences : NSObject {
    /// The path to a custom default cover(if any)
    var defaultCoverPath : String = "";
    
    /// Returns the default cover image to use globally
    var defaultCoverImage : NSImage {
        // If 'defaultCoverPath' is set...
        if(defaultCoverPath != "") {
            /// The possible image at defaultCoverPath
            let image : NSImage? = NSImage(contentsOf: URL(fileURLWithPath: defaultCoverPath));
            
            // If there is an image at defaultCoverPath...
            if(image != nil) {
                // Return 'image'
                return image!;
            }
        }
        
        // Default to returning the built in default cover image
        return #imageLiteral(resourceName: "AZDefaultCover");
    }
}
