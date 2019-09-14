//
//  UIImage+ImageOperations.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-13.
//  Copyright © 2019 Hipo. All rights reserved.
//

import UIKit


extension UIImage {
    
    func resizeAndCrop(toTargetSize targetSize: CGSize) -> UIImage {
        let newScale = self.scale
        let originalSize = self.size
        
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        let newSize: CGSize
        var originPoint = CGPoint.zero

        if widthRatio < heightRatio {
            newSize = CGSize(width: floor(originalSize.width * heightRatio), height: floor(originalSize.height * heightRatio))
        } else {
            newSize = CGSize(width: floor(originalSize.width * widthRatio), height: floor(originalSize.height * widthRatio))
        }
        
        if newSize.height != targetSize.height {
            originPoint.y = (targetSize.height - newSize.height) / 2
        }
        
        if newSize.width != targetSize.width {
            originPoint.x = (targetSize.width - newSize.width) / 2
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: originPoint, size: newSize)
        let targetBounds = CGRect(origin: .zero, size: targetSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        let format = UIGraphicsImageRendererFormat()
        
        format.scale = newScale
        format.opaque = true
        
        let newImage = UIGraphicsImageRenderer(bounds: targetBounds, format: format).image() { _ in
            self.draw(in: rect)
        }
        
        return newImage
    }
}
