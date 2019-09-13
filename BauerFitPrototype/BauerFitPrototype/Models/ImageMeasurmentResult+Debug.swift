//
//  Result+a.swift
//  BauerFitPrototype
//
//  Created by Eray on 13.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Magpie

extension ImageMeasurementResult {
    class Debug: Model {
        let frontEdge: String?
        let frontOutput: String?
        let frontOverlayed: String?
        let sideEdge: String?
        let sideOutput: String?
        let sideOverlayed: String?

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            frontEdge = try container.decodeIfPresent(String.self, forKey: .frontEdge)
            frontOutput = try container.decodeIfPresent(String.self, forKey: .frontOutput)
            frontOverlayed = try container.decodeIfPresent(String.self, forKey: .frontOverlayed)
            sideEdge = try container.decodeIfPresent(String.self, forKey: .sideEdge)
            sideOutput = try container.decodeIfPresent(String.self, forKey: .sideOutput)
            sideOverlayed = try container.decodeIfPresent(String.self, forKey: .sideOverlayed)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encodeIfPresent(frontEdge, forKey: .frontEdge)
            try container.encodeIfPresent(frontOutput, forKey: .frontOutput)
            try container.encodeIfPresent(frontOverlayed, forKey: .frontOverlayed)
            try container.encodeIfPresent(sideEdge, forKey: .sideEdge)
            try container.encodeIfPresent(sideOutput, forKey: .sideOutput)
            try container.encodeIfPresent(sideOverlayed, forKey: .sideOverlayed)
        }
    }
}

extension ImageMeasurementResult.Debug {
    enum CodingKeys: String, CodingKey {
        case frontEdge = "front_edge"
        case frontOutput = "front_output"
        case frontOverlayed = "front_overlayed"
        case sideEdge = "side_edge"
        case sideOutput = "side_output"
        case sideOverlayed = "side_overlayed"
    }
}
