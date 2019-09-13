//
//  Result+a.swift
//  BauerFitPrototype
//
//  Created by Eray on 13.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Magpie

extension ImageMeasurementResult {
    class FitRequest: Model {
        let id: Int?
        let age: Int?
        let frontImage: String?
        let gender: String?
        let height: Double?
        let sideImage: String?

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decodeIfPresent(Int.self, forKey: .id)
            age = try container.decodeIfPresent(Int.self, forKey: .age)
            height = try container.decodeIfPresent(Double.self, forKey: .height)
            gender = try container.decodeIfPresent(String.self, forKey: .gender)
            frontImage = try container.decodeIfPresent(String.self, forKey: .frontImage)
            sideImage = try container.decodeIfPresent(String.self, forKey: .sideImage)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encodeIfPresent(id, forKey: .id)
            try container.encodeIfPresent(age, forKey: .age)
            try container.encodeIfPresent(height, forKey: .height)
            try container.encodeIfPresent(gender, forKey: .gender)
            try container.encodeIfPresent(frontImage, forKey: .frontImage)
            try container.encodeIfPresent(sideImage, forKey: .sideImage)

        }
    }
}

extension ImageMeasurementResult.FitRequest {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case age = "age"
        case frontImage = "front_image"
        case sideImage = "side_image"
        case gender = "gender"
        case height = "height"
    }
}
