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
    }
}
