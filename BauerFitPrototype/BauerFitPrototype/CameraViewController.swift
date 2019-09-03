//
//  CameraViewController.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-03.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Foundation
import UIKit


public enum CaptureMode {
    case front
    case side
}

class CameraViewController: UIViewController {
    
    let cameraController = CameraController()
    var captureProfile: CaptureProfile
    let captureMode: CaptureMode
    
    override var prefersStatusBarHidden: Bool { return true }
    
    init(captureMode: CaptureMode, captureProfile: CaptureProfile) {
        self.captureMode = captureMode
        self.captureProfile = captureProfile
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraPreviewView = UIView(frame: .zero)
        
        cameraPreviewView.backgroundColor = .black
        cameraPreviewView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cameraPreviewView)
        
        NSLayoutConstraint.activate([
            cameraPreviewView.widthAnchor.constraint(equalTo: view.widthAnchor),
            cameraPreviewView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: cameraPreviewView)
        }

        let captureButtonSize: CGFloat = 66.0
        let captureButton = UIButton(frame: .zero)
        
        captureButton.backgroundColor = .white
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(captureButton)
        
        captureButton.layer.borderColor = UIColor.black.cgColor
        captureButton.layer.borderWidth = 3
        captureButton.layer.cornerRadius = captureButtonSize / 2
        
        NSLayoutConstraint.activate([
            captureButton.widthAnchor.constraint(equalToConstant: captureButtonSize),
            captureButton.heightAnchor.constraint(equalToConstant: captureButtonSize),
            captureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30.0),
        ])
        
        captureButton.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
    }
    
    @objc func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            switch self.captureMode {
            case .front:
                self.captureProfile.frontPhoto = image
                
                // Move to side mode
                let cameraViewController = CameraViewController(captureMode: .side,
                                                                captureProfile: self.captureProfile)
                
                self.navigationController?.pushViewController(cameraViewController, animated: true)
            case .side:
                self.captureProfile.sidePhoto = image
                
                // Move to share screen
                let shareViewController = ShareViewController(captureProfile: self.captureProfile)
                
                self.navigationController?.pushViewController(shareViewController, animated: true)
            }
        }
    }
}
