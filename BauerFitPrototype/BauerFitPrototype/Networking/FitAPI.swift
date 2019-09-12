//
//  API.swift
//  BauerFitPrototype
//
//  Created by Eray on 12.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Magpie

class FitAPI: Magpie {
    
    @available(*, unavailable)
    required init(
        base: String,
        networking: Networking,
        networkMonitor: NetworkMonitor? = nil
        ) {
        fatalError("init(base:networking:networkMonitor:) has not been implemented")
    }

    init() {
        let serverSchema = "http"
        let serverHost = "fitapi.hipolabs.com"
        let fitApiBase = "\(serverSchema)://\(serverHost)/api"

        super.init(base: fitApiBase, networking: AlamofireNetworking())
    }
}

extension FitAPI {
    @discardableResult
    func requestImageMeasurements(
        with draft: ImageMeasurementDraft,
        then handler: @escaping Endpoint.DefaultResultHandler<ImageMeasurementResult>
        ) -> EndpointOperatable {
        return Endpoint(path: "/fit/")
            .httpMethod(.post)
            .httpBody(draft)
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
