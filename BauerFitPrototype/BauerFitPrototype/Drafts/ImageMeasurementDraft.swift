//
//  ImageMeasurementDraft.swift
//  BauerFitPrototype
//
//  Created by Eray on 12.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Magpie

struct ImageMeasurementDraft: JSONBody {
    typealias Key = RequestParameter

    var frontImage: Pair
    var sideImage: Pair
    var age: Pair
    var height: Pair
    var gender: Pair

    func decoded() -> [Pair]? {
        return [frontImage, sideImage, age, height, gender].compactMap { $0 }
    }
}
