//
//  CaptureProfile.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-03.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Foundation
import UIKit


public enum Gender {
    case male
    case female
}

struct CaptureProfile {
    let gender: Gender
    
    var frontPhoto: UIImage?
    var sidePhoto: UIImage?
}
