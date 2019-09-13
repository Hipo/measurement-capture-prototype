//
//  UIImage+CVPixelBuffer.swift
//
//  Created by Shuichi Tsutsumi on 2018/08/28.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

import UIKit
import CoreImage


extension UIImage {
    
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let imageRect = CGRect(x: 0, y: 0, width: pixelBufferHeight, height: pixelBufferWidth)
        let ciContext = CIContext.init()
        let rotatedImage = ciImage.oriented(.right)

        guard let cgImage = ciContext.createCGImage(rotatedImage, from: imageRect) else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
    
}
