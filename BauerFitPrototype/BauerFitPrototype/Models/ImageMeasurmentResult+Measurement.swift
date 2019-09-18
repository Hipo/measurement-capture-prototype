//
//  Result+a.swift
//  BauerFitPrototype
//
//  Created by Eray on 13.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Magpie

extension ImageMeasurementResult {
    class Measurements: Model {
        let chestCircumference: Int?
        let chestDepth: Int?
        let chestWidth: Int?
        let hipsCircumference: Int?
        let hipsDepth: Int?
        let hipsWidth: Int?
        let shoulderWidth: Int?
        let waistCircumference: Int?
        let waistDepth: Int?
        let waistWidth: Int?
        let shinLength: Int?

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            chestCircumference = try container.decodeIfPresent(Int.self, forKey: .chestCircumference)
            chestDepth = try container.decodeIfPresent(Int.self, forKey: .chestDepth)
            chestWidth = try container.decodeIfPresent(Int.self, forKey: .chestWidth)
            hipsCircumference = try container.decodeIfPresent(Int.self, forKey: .hipsCircumference)
            hipsDepth = try container.decodeIfPresent(Int.self, forKey: .hipsDepth)
            hipsWidth = try container.decodeIfPresent(Int.self, forKey: .hipsWidth)
            shoulderWidth = try container.decodeIfPresent(Int.self, forKey: .shoulderWidth)
            waistCircumference = try container.decodeIfPresent(Int.self, forKey: .waistCircumference)
            waistDepth = try container.decodeIfPresent(Int.self, forKey: .waistDepth)
            waistWidth = try container.decodeIfPresent(Int.self, forKey: .waistWidth)
            shinLength = try container.decodeIfPresent(Int.self, forKey: .shinLength)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encodeIfPresent(chestCircumference, forKey: .chestCircumference)
            try container.encodeIfPresent(chestDepth, forKey: .chestDepth)
            try container.encodeIfPresent(chestWidth, forKey: .chestWidth)
            try container.encodeIfPresent(hipsCircumference, forKey: .hipsCircumference)
            try container.encodeIfPresent(hipsDepth, forKey: .hipsDepth)
            try container.encodeIfPresent(hipsWidth, forKey: .hipsWidth)
            try container.encodeIfPresent(shoulderWidth, forKey: .shoulderWidth)
            try container.encodeIfPresent(waistCircumference, forKey: .waistCircumference)
            try container.encodeIfPresent(waistDepth, forKey: .waistDepth)
            try container.encodeIfPresent(waistWidth, forKey: .waistWidth)
            try container.encodeIfPresent(shinLength, forKey: .shinLength)
        }
    }
}

extension ImageMeasurementResult.Measurements {
    enum CodingKeys: String, CodingKey {
        case chestCircumference = "chest_circumference"
        case chestDepth = "chest_depth"
        case chestWidth = "chest_width"
        case hipsCircumference = "hips_circumference"
        case hipsDepth = "hips_depth"
        case hipsWidth = "hips_width"
        case shoulderWidth = "shoulder_width"
        case waistCircumference = "waist_circumference"
        case waistDepth = "waist_depth"
        case waistWidth = "waist_width"
        case shinLength = "shin_length"
    }
}

// MARK: - API

extension ImageMeasurementResult.Measurements {
    struct Result {
        let name: String
        let value: Any
    }

    var list: [Result] {
        var array = [Result]()

        if let chestCircumference = chestCircumference {
            array.append(Result(name: "Chest Circumference", value: chestCircumference))
        }
        if let chestDepth = chestDepth {
            array.append(Result(name: "Chest Depth", value: chestDepth))
        }
        if let chestWidth = chestWidth {
            array.append(Result(name: "Chest Width", value: chestWidth))
        }
        if let hipsCircumference = hipsCircumference {
            array.append(Result(name: "Hips Circumference", value: hipsCircumference))
        }
        if let hipsDepth = hipsDepth {
            array.append(Result(name: "Hips Depth", value: hipsDepth))
        }
        if let hipsWidth = hipsWidth {
            array.append(Result(name: "Hips Width", value: hipsWidth))
        }
        if let shoulderWidth = shoulderWidth {
            array.append(Result(name: "Shoulder Width", value: shoulderWidth))
        }
        if let waistCircumference = waistCircumference {
            array.append(Result(name: "Waist Circumference", value: waistCircumference))
        }
        if let waistDepth = waistDepth {
            array.append(Result(name: "Waist Depth", value: waistDepth))
        }
        if let waistWidth = waistWidth {
            array.append(Result(name: "Waist Width", value: waistWidth))
        }
        if let shinLength = shinLength {
            array.append(Result(name: "Shin Length", value: shinLength))
        }

        return array
    }
}
