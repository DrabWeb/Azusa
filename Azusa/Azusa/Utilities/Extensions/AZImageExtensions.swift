//
//  AZImageExtensions.swift
//  Azusa
//
//  Created by Ushio on 12/14/16.
//

import Cocoa

extension NSImage {
    /// Gets the size of this image
    ///
    /// - Returns: The size in pixels of this image
    var pixelSize : NSSize {
        return autoreleasepool { () -> CGSize in
            if let cgImage : CGImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                return NSSize(width: cgImage.width, height: cgImage.height);
            }
            
            return NSSize.zero;
        }
    }
    
    /// Resizes this image to fit a box with the given size as width and height
    ///
    /// - Parameter size: The width and height of the box to resize to fit in
    /// - Returns: The resized image
    func resizedTo(fit size : Int) -> NSImage {
        /// The pixel size of this image
        let pixelSize : NSSize = self.pixelSize;
        
        // If the height is greater than the width...
        if(pixelSize.height > pixelSize.width) {
            /// The aspect ratio of this image
            let aspectRatio : CGFloat = pixelSize.width / pixelSize.height;
            
            /// Then new width for this image
            let width : CGFloat = aspectRatio * CGFloat(size);
            
            // Return the resized image
            return self.resizedTo(NSSize(width: CGFloat(size), height: width));
        }
        // If the width is greater than the height...
        else if(pixelSize.width > pixelSize.height) {
            /// The aspect ratio of this image
            let aspectRatio : CGFloat = pixelSize.height / pixelSize.width;
            
            /// Then new height for this image
            let height : CGFloat = aspectRatio * CGFloat(size);
            
            // Return the resized image
            return self.resizedTo(NSSize(width: CGFloat(size), height: height));
        }
        // If the width and height are equal...
        else {
            // Return the resized image
            return self.resizedTo(NSSize(width: size, height: size));
        }
    }
    
    /// Scales this image by the given factor
    ///
    /// - Parameter factor: The factor to scale by
    /// - Returns: The resized image
    func resizedByFactor(_ factor : CGFloat) -> NSImage {
        /// The pixel size of this image
        let pixelSize : NSSize = self.pixelSize;
        
        // Return the resized image
        return self.resizedTo(NSSize(width: pixelSize.width * factor, height: pixelSize.height * factor));
    }
    
    /// Scales this image to the given size and returns it
    ///
    /// - Parameter newSize: The new size for this image
    /// - Returns: The resized image
    func resizedTo(_ resizedSize : NSSize) -> NSImage {
        /// The resized image to return
        let resizedImage : NSImage = NSImage(size: resizedSize);
        
        // Lock drawing focus
        resizedImage.lockFocus();
        
        // Set the source image's size
        self.size = resizedSize;
        
        // Set image interpolation to the best quality
        NSGraphicsContext.current()!.imageInterpolation = NSImageInterpolation.high;
        
        // Draw `sourceImage` into `resizedImage`
        self.draw(at: NSZeroPoint, from: NSRect(x: 0, y: 0, width: pixelSize.width, height: pixelSize.height), operation: .copy, fraction: 1);
        
        // Unlock drawing focus
        resizedImage.unlockFocus();
        
        // Return `resizedImage`
        return resizedImage;
    }
}
