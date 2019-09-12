//
//  ShareViewController.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-03.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Foundation
import UIKit

class ShareViewController: UIViewController {
    
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
            resetButton.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: buttonSize.height),
        ])

        resetButton.addTarget(self, action: #selector(resetCapture(_:)), for: .touchUpInside)
    }
    
    @objc func resetCapture(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func shareResults(_ sender: UIButton) {
        guard let frontPhoto = draft.frontPhoto, let sidePhoto = draft.sidePhoto else {
            return
        }
        
        let ac = UIActivityViewController(activityItems: [frontPhoto, sidePhoto],
                                          applicationActivities: nil)
        
        present(ac, animated: true)
    }
    
}
