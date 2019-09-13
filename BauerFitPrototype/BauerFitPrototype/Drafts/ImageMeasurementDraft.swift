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
    var frontDepthPhoto: UIImage?
    var sideDepthPhoto: UIImage?
    var age: Int?
    var weight: Int?
    var height: Int?
    var gender: Gender?

    func decoded() -> [Pair]? {
        var pairs = [Pair]()

        if let frontPhoto = frontPhoto {
            pairs.append(Pair(key: .frontPhoto, value: frontPhoto.base64String(withHeight: 800)))
        }
        if let sidePhoto = sidePhoto {
            pairs.append(Pair(key: .sidePhoto, value: sidePhoto.base64String(withHeight: 800)))
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

extension ImageMeasurementDraft {
    var descriptionString: String {
        var description = ""

        if frontPhoto != nil {
            description.append("- A Front Photo -\n")
        }
        if sidePhoto != nil {
            description.append("- A Side Photo -\n")
        }
        if let age = age {
            description.append("- Age: \(age) -\n")
        }
        if let height = height {
            description.append("- Height: \(height) -\n")
        }
        if let gender = gender {
            description.append("- Gender: \(gender.rawValue) -")
        }

        return description
    }
}

extension ImageMeasurementDraft: CustomStringConvertible {
    var description: String {
        return descriptionString
    }
}

extension ImageMeasurementDraft: CustomDebugStringConvertible {
    var debugDescription: String {
        return descriptionString
    }
}
