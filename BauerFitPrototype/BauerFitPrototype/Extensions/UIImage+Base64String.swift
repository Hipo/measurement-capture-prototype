//
//  UIImage+Base64String.swift
//  BauerFitPrototype
//
//  Created by Eray on 12.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Kingfisher
import UIKit

extension UIImage {
    func base64String(withHeight height: CGFloat) -> String? {
        let ratio = height / size.height
        let width = size.width * ratio
        let scaledSize = CGSize(width: width, height: height)
        let scale = width / height

        let processor = DownsamplingImageProcessor(size: scaledSize)

        guard
            let processedImage = processor.process(item: .image(self), options: [.scaleFactor(scale)]),
            let processedData = processedImage.jpegData(compressionQuality: 1.0)
            else {
                return nil
        }

        let base64String = processedData.base64EncodedString()

        return base64String
    }
}

