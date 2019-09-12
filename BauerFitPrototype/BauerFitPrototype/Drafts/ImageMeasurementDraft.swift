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

    var frontPhoto: UIImage?
    var sidePhoto: UIImage?
    var age: Int?
    var height: Int?
    var gender: Gender?

    func decoded() -> [Pair]? {
        var pairs = [Pair]()

        if let photo = frontPhoto {
            pairs.append(Pair(key: .frontPhoto, value: photo.toBase64String))
        }
        if let photo = sidePhoto {
            pairs.append(Pair(key: .frontPhoto, value: photo.toBase64String))
        }
        if let age = age {
            pairs.append(Pair(key: .age, value: age))
        }
        if let height = height {
            pairs.append(Pair(key: .height, value: height))
        }
        if let gender = gender {
            pairs.append(Pair(key: .gender, value: gender.rawValue))
        }

        return pairs
    }
}
