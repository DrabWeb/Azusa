//
//  AZExtensions.swift
//  Azusa
//
//  Created by Ushio on 11/24/16.
//

import Foundation
import AppKit

extension NSImage {
    /// Returns the pixel size of the passed NSImage
    var pixelSize : NSSize {
        /// The NSBitmapImageRep to the image
        let imageRep : NSBitmapImageRep = (NSBitmapImageRep(data: self.tiffRepresentation!))!;
        
        /// The size of the iamge
        let imageSize : NSSize = NSSize(width: imageRep.pixelsWide, height: imageRep.pixelsHigh);
        
        // Return the image size
        return imageSize;
    }
}
