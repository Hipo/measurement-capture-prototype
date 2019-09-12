//
//  UIImage+Base64String.swift
//  BauerFitPrototype
//
//  Created by Eray on 12.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import UIKit

extension UIImage {
    var toBase64String: String? {
        return self.jpegData(compressionQuality: 1.0)?.base64EncodedString(options: .endLineWithLineFeed)
    }

//    func base64Representation(_ completion: @escaping (String?) -> Void) {
//        DispatchQueue.global(qos: .background).sync {
//            guard let data = self.jpegData(compressionQuality: 1.0) else {
//                DispatchQueue.main.async {
//                    completion(nil)
//                }
//
//                return
//            }
//
//            let base64String = data.base64EncodedString(options: .endLineWithLineFeed)
//            let resultBase64String = base64String.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//
//            DispatchQueue.main.async {
//                completion(resultBase64String)
//            }
//        }
//    }
}

