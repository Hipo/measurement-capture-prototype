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
            frontPhotoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            frontPhotoView.heightAnchor.constraint(equalTo: frontPhotoView.widthAnchor, multiplier: 1.5),
            frontPhotoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frontPhotoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120.0),
        ])
        
        let sidePhotoView = UIImageView(frame: .zero)

        sidePhotoView.image = draft.sidePhoto
        sidePhotoView.contentMode = .scaleAspectFit
        sidePhotoView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(sidePhotoView)
        
        NSLayoutConstraint.activate([
            sidePhotoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            sidePhotoView.heightAnchor.constraint(equalTo: frontPhotoView.widthAnchor, multiplier: 1.5),
            sidePhotoView.trailingAnchor.constraint(equalTo: frontPhotoView.leadingAnchor, constant: -15.0),
            sidePhotoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120.0),
            ])
        
        sidePhotoView.layer.borderColor = UIColor.black.cgColor
        sidePhotoView.layer.borderWidth = 3
        
        let sideArmPhotoView = UIImageView(frame: .zero)
        
        sideArmPhotoView.image = draft.sideArmPhoto
        sideArmPhotoView.contentMode = .scaleAspectFit
        sideArmPhotoView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(sideArmPhotoView)
        
        NSLayoutConstraint.activate([
            sideArmPhotoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            sideArmPhotoView.heightAnchor.constraint(equalTo: frontPhotoView.widthAnchor, multiplier: 1.5),
            sideArmPhotoView.leadingAnchor.constraint(equalTo: frontPhotoView.trailingAnchor, constant: 15.0),
            sideArmPhotoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120.0),
            ])
        
        sideArmPhotoView.layer.borderColor = UIColor.black.cgColor
        sideArmPhotoView.layer.borderWidth = 3
        
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
            guard var draft = self?.draft else {
                return
            }
            
            #if DEBUG
            let targetImageSize = CGSize(width: 450, height: 800)
            
            draft.frontPhoto = img("sample-front.png").resizeAndCrop(toTargetSize: targetImageSize)
            draft.sidePhoto = img("sample-side.png").resizeAndCrop(toTargetSize: targetImageSize)
            #endif

            self?.fitAPI.requestImageMeasurements(with: draft) { result in
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoadingIndicator()
                    
                    switch result {
                    case let .success(result):
                        self?.openResultsScreen(with: result)
                    case let .failure(error):
                        self?.show(error) // TODO: Error handling
                    }
                }
            }
        }
    }
    
    @objc func shareResults(_ sender: UIButton) {
        guard let frontPhoto = draft.frontPhoto,
            let sidePhoto = draft.sidePhoto,
            let sideArmPhoto = draft.sideArmPhoto else {
            return
        }
        
        var activityItems = [frontPhoto, sidePhoto, sideArmPhoto]
        
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

    private func show(_ error: Error) {
        let title = "Network Error"
        let message = error.localizedDescription
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)

        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
}

extension ShareViewController: LoadingIndicatorDisplayable { }
