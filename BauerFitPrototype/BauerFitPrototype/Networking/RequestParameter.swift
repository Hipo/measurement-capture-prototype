//
//  RequestParameter.swift
//  BauerFitPrototype
//
//  Created by Eray on 12.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Foundation

import Magpie

/// <note> The cases should be added conforming the alphabetical order.
enum RequestParameter: String, JSONBodyRequestParameter {
    case age        = "age"
    case frontImage = "front_image"
    case gender     = "gender"
    case height     = "height"
    case sideImage  = "side_image"
}
