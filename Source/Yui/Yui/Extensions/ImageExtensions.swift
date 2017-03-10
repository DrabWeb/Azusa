//
//  ImageExtensions.swift
//  Yui
//
//  Created by Ushio on 2/12/17.
//

import Cocoa

extension NSImage {
    /// Saves this image to the given path
    ///
    /// - Parameters:
    ///   - filePath: The path to save to
    ///   - fileType: The file type to use
    func save(to filePath : String, as fileType : NSBitmapImageFileType) {
        if let data = bitmapImageRep().representation(using: fileType, properties: [:]) {
            do {
                try data.write(to: URL(fileURLWithPath: filePath), options: []);
            }
            catch let error {
                Logger.logError("NSImage: Failed to save image to \(filePath), \(error)");
            }
        }
    }
    
    func bitmapImageRep() -> NSBitmapImageRep {
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(self.pixelSize.width), pixelsHigh: Int(self.pixelSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSDeviceRGBColorSpace, bytesPerRow: 0, bitsPerPixel: 0)
        else {
            preconditionFailure();
        }
        
        NSGraphicsContext.saveGraphicsState();
        NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: rep));
        self.draw(at: NSPoint.zero, from: NSRect.zero, operation: .sourceOver, fraction: 1.0);
        NSGraphicsContext.restoreGraphicsState();
        
        return rep;
    }
    
    /// Gets the size of this image
    ///
    /// - Returns: The size in pixels of this image
    var pixelSize : NSSize {
        if let cgImage : CGImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            return NSSize(width: cgImage.width, height: cgImage.height);
        }
        
        return NSSize.zero;
    }
    
    /// Resizes this image to fit a box with the given size as width and height
    ///
    /// - Parameter size: The width and height of the box to resize to fit in
    /// - Returns: The resized image
    func resizedTo(fit size : Int) -> NSImage {
        let pixelSize : NSSize = self.pixelSize;
        
        if(pixelSize.height == pixelSize.width) {
            return self.resizedTo(NSSize(width: size, height: size));
        }
        else {
            let aspectRatio : CGFloat = pixelSize.height / pixelSize.width;
            let width : CGFloat = aspectRatio * CGFloat(size);
            
            return self.resizedTo(NSSize(width: CGFloat(size), height: width));
        }
    }
    
    /// Scales this image by the given factor
    ///
    /// - Parameter factor: The factor to scale by
    /// - Returns: The resized image
    func resizedByFactor(_ factor : CGFloat) -> NSImage {
        let pixelSize : NSSize = self.pixelSize;
        
        return self.resizedTo(NSSize(width: pixelSize.width * factor, height: pixelSize.height * factor));
    }
    
    /// Scales this image to the given size and returns it
    ///
    /// - Parameter newSize: The new size for this image
    /// - Returns: The resized image
    func resizedTo(_ resizedSize : NSSize) -> NSImage {
        let resizedImage : NSImage = NSImage(size: resizedSize);
        
        resizedImage.lockFocus();
        
        self.size = resizedSize;
        NSGraphicsContext.current()!.imageInterpolation = NSImageInterpolation.high;
        self.draw(at: NSZeroPoint, from: NSRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height), operation: .overlay, fraction: 1);
        
        resizedImage.unlockFocus();
        
        return resizedImage;
    }
}
