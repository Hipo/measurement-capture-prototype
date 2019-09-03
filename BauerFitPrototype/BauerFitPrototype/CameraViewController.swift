//
//  CameraViewController.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-03.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Foundation
import UIKit

class CameraViewController: UIViewController {
    
    let cameraController = CameraController()
    
    override var prefersStatusBarHidden: Bool { return true }
}

extension CameraViewController {
    override func viewDidLoad() {
        
        let cameraPreviewView = UIView(frame: .zero)
        
        cameraPreviewView.backgroundColor = .red
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
    }
}
