//
//  UIViewController+ActivityIndicator.swift
//  BauerFitPrototype
//
//  Created by Eray on 12.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import UIKit

protocol LoadingIndicatorDisplayable: class {
    var loadingIndicatorOverlayView: UIView? { get set }
}

extension LoadingIndicatorDisplayable where Self: UIViewController {
     func showLoadingIndicator() {
        let dimmedOverlayView = UIView.init(frame: view.bounds)
        dimmedOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmedOverlayView.alpha = 0.0

        let activityIndicatorView = UIActivityIndicatorView.init(style: .whiteLarge)
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = dimmedOverlayView.center

        DispatchQueue.main.async { [weak self] in
            dimmedOverlayView.addSubview(activityIndicatorView)
            self?.view.addSubview(dimmedOverlayView)

            UIView.animate(withDuration: 0.33) {
                dimmedOverlayView.alpha = 1.0
            }
        }

        loadingIndicatorOverlayView = dimmedOverlayView
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(
                withDuration: 0.33,
                animations: { [weak self] in
                    self?.loadingIndicatorOverlayView?.alpha = 0.0
                },
                completion: { _ in
                    self?.loadingIndicatorOverlayView?.removeFromSuperview()
                    self?.loadingIndicatorOverlayView = nil
                }
            )
        }
    }
}
