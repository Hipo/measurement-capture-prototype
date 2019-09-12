//
//  CameraViewController.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-03.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion


public enum CaptureMode {
    case front
    case side
}

class CameraViewController: UIViewController {
    
    let cameraController = CameraController()
    var captureProfile: CaptureProfile
    let captureMode: CaptureMode
    
    let motionManager = CMMotionManager()
    
    var cameraCaptureButton: UIButton?
    
    override var prefersStatusBarHidden: Bool { return true }
    
    init(captureMode: CaptureMode, captureProfile: CaptureProfile) {
        self.captureMode = captureMode
        self.captureProfile = captureProfile
        
        super.init(nibName: nil, bundle: nil)
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { [weak self] (data, error) in
                guard let data = data, error == nil else {
                    return
                }
                
                self?.updateInterfaceWithMotionData(motionData: data)
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinit camera capture for \(captureMode)")
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
        
        let silhouetteView = UIImageView(frame: .zero)
        
        silhouetteView.translatesAutoresizingMaskIntoConstraints = false
        silhouetteView.isUserInteractionEnabled = false
        silhouetteView.contentMode = .scaleAspectFit
        
        switch captureMode {
        case .front:
            switch captureProfile.gender {
            case .female:
                silhouetteView.image = UIImage(named: "woman-front")?.withRenderingMode(.alwaysTemplate)
            case .male:
                silhouetteView.image = UIImage(named: "man-front")?.withRenderingMode(.alwaysTemplate)
            }
        case .side:
            switch captureProfile.gender {
            case .female:
                silhouetteView.image = UIImage(named: "woman-side")?.withRenderingMode(.alwaysTemplate)
            case .male:
                silhouetteView.image = UIImage(named: "man-side")?.withRenderingMode(.alwaysTemplate)
            }
        }
        
        silhouetteView.tintColor = .white
        
        view.addSubview(silhouetteView)
        
        NSLayoutConstraint.activate([
            silhouetteView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0),
            silhouetteView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50.0),
            silhouetteView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])

        let captureButtonSize: CGFloat = 66.0
        let captureButton = UIButton(frame: .zero)
        
        captureButton.backgroundColor = .white
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.isEnabled = false
        captureButton.alpha = 0.5
        
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
        
        cameraCaptureButton = captureButton
    }
    
    @objc func captureImage(_ sender: UIButton) {
        motionManager.stopDeviceMotionUpdates()
        
        cameraCaptureButton?.isEnabled = false
        
        cameraController.captureImage {[weak self] (image, error) in
            guard let image = image, let strongSelf = self else {
                print(error ?? "Image capture error")
                return
            }
            
            switch strongSelf.captureMode {
            case .front:
                strongSelf.captureProfile.frontPhoto = image
                
                // Move to side mode
                let cameraViewController = CameraViewController(captureMode: .side,
                                                                captureProfile: strongSelf.captureProfile)
                
                strongSelf.navigationController?.pushViewController(cameraViewController, animated: true)
            case .side:
                strongSelf.captureProfile.sidePhoto = image
                
                // Move to share screen
                let shareViewController = ShareViewController(captureProfile: strongSelf.captureProfile)
                
                strongSelf.navigationController?.pushViewController(shareViewController, animated: true)
            }
            
            strongSelf.cameraController.stopSession()
        }
    }
    
    func updateInterfaceWithMotionData(motionData: CMDeviceMotion) {
        if !isViewLoaded {
            return
        }
        
        let enabled = (-motionData.gravity.y > 0.9 && -motionData.gravity.y < 1.1)
            && (motionData.gravity.z > -0.1 && motionData.gravity.z < 0.1)
        
        cameraCaptureButton?.isEnabled = enabled
        cameraCaptureButton?.alpha = enabled ? 1.0 : 0.5
    }
}
