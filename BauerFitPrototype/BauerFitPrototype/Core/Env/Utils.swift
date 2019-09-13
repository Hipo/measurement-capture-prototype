//
//  Utils.swift
//  BauerFitPrototype
//
//  Created by Eray on 13.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import UIKit

func img(_ named: String) -> UIImage {
    guard let image = UIImage(named: named) else {
        fatalError("No image found: '\(named)'")
    }
    return image
}

func asyncMain(execute: @escaping () -> Void) {
    DispatchQueue.main.async(execute: execute)
}

func asyncBackground(execute: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async(execute: execute)
}

func asyncAfter(_ duration: TimeInterval, execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration, execute: execute)
}
