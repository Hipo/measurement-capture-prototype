//
//  ShareViewController.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-03.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Foundation
import Kingfisher
import UIKit

class ShareViewController: UIViewController {
    var fitAPI = FitAPI()
    var loadingIndicatorOverlayView: UIView?
    var draft: ImageMeasurementDraft
    
    init(draft: ImageMeasurementDraft) {
        self.draft = draft
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinit share controller")
    }

    private func openResultsScreen(with result: ImageMeasurementResult) {
        let controller = MeasurementResultsViewController(result: result)

        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ShareViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let frontPhotoView = UIImageView(frame: .zero)
        
        frontPhotoView.image = draft.frontPhoto
        frontPhotoView.contentMode = .scaleAspectFit
        frontPhotoView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(frontPhotoView)
        
        frontPhotoView.layer.borderColor = UIColor.black.cgColor
        frontPhotoView.layer.borderWidth = 3
        
        NSLayoutConstraint.activate([
            frontPhotoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            frontPhotoView.heightAnchor.constraint(equalTo: frontPhotoView.widthAnchor, multiplier: 1.5),
            frontPhotoView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -15.0),
            frontPhotoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120.0),
        ])
        
        let sidePhotoView = UIImageView(frame: .zero)

        sidePhotoView.image = draft.sidePhoto
        sidePhotoView.contentMode = .scaleAspectFit
        sidePhotoView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(sidePhotoView)
        
        NSLayoutConstraint.activate([
            sidePhotoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            sidePhotoView.heightAnchor.constraint(equalTo: frontPhotoView.widthAnchor, multiplier: 1.5),
            sidePhotoView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 15.0),
            sidePhotoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120.0),
            ])
        
        sidePhotoView.layer.borderColor = UIColor.black.cgColor
        sidePhotoView.layer.borderWidth = 3
        
        let buttonSize = CGSize(width: 132.0, height: 66.0)
        let shareButton = UIButton(frame: .zero)

        shareButton.backgroundColor = .white
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setTitle("SHARE", for: .normal)
        shareButton.setTitleColor(.black, for: .normal)

        view.addSubview(shareButton)

        shareButton.layer.borderColor = UIColor.black.cgColor
        shareButton.layer.borderWidth = 3

        NSLayoutConstraint.activate([
            shareButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
            shareButton.heightAnchor.constraint(equalToConstant: buttonSize.height),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.topAnchor.constraint(equalTo: sidePhotoView.bottomAnchor, constant: buttonSize.height),
        ])

        shareButton.addTarget(self, action: #selector(shareResults(_:)), for: .touchUpInside)
        
        let measureButton = UIButton(frame: .zero)
        
        measureButton.backgroundColor = .white
        measureButton.translatesAutoresizingMaskIntoConstraints = false
        measureButton.setTitle("CALCULATE", for: .normal)
        measureButton.setTitleColor(.black, for: .normal)
        
        view.addSubview(measureButton)
        
        measureButton.layer.borderColor = UIColor.black.cgColor
        measureButton.layer.borderWidth = 3
        
        NSLayoutConstraint.activate([
            measureButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
            measureButton.heightAnchor.constraint(equalToConstant: buttonSize.height),
            measureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            measureButton.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: buttonSize.height / 2),
        ])
        
        measureButton.addTarget(self, action: #selector(calculateMeasurements(_:)), for: .touchUpInside)

        let resetButton = UIButton(frame: .zero)

        resetButton.backgroundColor = .white
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("RESET", for: .normal)
        resetButton.setTitleColor(.black, for: .normal)

        view.addSubview(resetButton)

        resetButton.layer.borderColor = UIColor.black.cgColor
        resetButton.layer.borderWidth = 3

        NSLayoutConstraint.activate([
            resetButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
            resetButton.heightAnchor.constraint(equalToConstant: buttonSize.height),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.topAnchor.constraint(equalTo: measureButton.bottomAnchor, constant: buttonSize.height / 2),
        ])

        resetButton.addTarget(self, action: #selector(popToRootViewController), for: .touchUpInside)
    }

    @objc func calculateMeasurements(_ sender: UIButton) {
        showLoadingIndicator()

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let draft = self?.draft else {
                return
            }
            
//            #if DEBUG
//            let targetImageSize = CGSize(width: 450, height: 800)
//
//            draft.frontPhoto = img("sample-front.png").resizeAndCrop(toTargetSize: targetImageSize)
//            draft.sidePhoto = img("sample-side.png").resizeAndCrop(toTargetSize: targetImageSize)
//            #endif

            self?.fitAPI.requestImageMeasurements(with: draft) { result in
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoadingIndicator()
                    
                    switch result {
                    case let .success(result):
                        self?.openResultsScreen(with: result)
                    case let .failure(error):
                        switch error {
                        case .badRequest:
                            self?.showError(withTitle: "Failed to Measure",
                                            message: "We were unable to extract measurements from these photos. Please make sure your subject is positioned properly in front of a solid background with contrasting clothes. Tap Reset and try again.")
                        default:
                            self?.showError(withTitle: "Network Error",
                                            message: error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    @objc func shareResults(_ sender: UIButton) {
        guard let frontPhoto = draft.frontPhoto,
            let sidePhoto = draft.sidePhoto else {
            return
        }
        
        var activityItems = [frontPhoto, sidePhoto]
        
        if let frontDepthPhoto = draft.frontDepthPhoto {
            activityItems.append(frontDepthPhoto)
        }
        
        if let sideDepthPhoto = draft.sideDepthPhoto {
            activityItems.append(sideDepthPhoto)
        }

        let ac = UIActivityViewController(activityItems: activityItems,
                                          applicationActivities: nil)
        
        present(ac, animated: true)
    }

    private func showError(withTitle title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)

        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
}

extension ShareViewController: LoadingIndicatorDisplayable { }
