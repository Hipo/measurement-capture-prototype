//
//  ImageMeasurmentResult.swift
//  BauerFitPrototype
//
//  Created by Eray on 12.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Magpie

class ImageMeasurementResult: Model {
    let debug: Debug?
    let request: FitRequest?
    let measurements: Measurements?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        debug = try container.decodeIfPresent(Debug.self, forKey: .debug)
        request = try container.decodeIfPresent(FitRequest.self, forKey: .request)
        measurements = try container.decodeIfPresent(Measurements.self, forKey: .measurements)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(debug, forKey: .debug)
        try container.encodeIfPresent(request, forKey: .request)
        try container.encodeIfPresent(measurements.self, forKey: .measurements)
    }
}

extension ImageMeasurementResult {
    enum CodingKeys: String, CodingKey {
        case debug = "debug"
        case request = "fit_request"
        case measurements = "measurements"
    }
}
