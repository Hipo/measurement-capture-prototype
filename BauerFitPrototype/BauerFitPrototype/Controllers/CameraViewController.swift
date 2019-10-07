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
    var draft: ImageMeasurementDraft
    var captureMode: CaptureMode = .front {
        didSet {
            updateForCaptureMode()
        }
    }
    
    let motionManager = CMMotionManager()
    
    var cameraCaptureButton: UIButton?
    var silhouetteView: UIImageView?
    var tiltStatusLabel: UILabel?

    override var prefersStatusBarHidden: Bool { return true }
    
    init(draft: ImageMeasurementDraft) {
        self.draft = draft
        
        super.init(nibName: nil, bundle: nil)
        
        startDeviceMotionUpdates()
    }
    
    func startDeviceMotionUpdates() {
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
        
        silhouetteView.tintColor = .white
        
        view.addSubview(silhouetteView)
        
        NSLayoutConstraint.activate([
            silhouetteView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0),
            silhouetteView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50.0),
            silhouetteView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        self.silhouetteView = silhouetteView
        
        updateForCaptureMode()

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
        
        let statusLabel = UILabel(frame: .zero)
        
        statusLabel.font = .systemFont(ofSize: 16.0)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 1
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.0),
            statusLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20.0),
            ])
        
        tiltStatusLabel = statusLabel
    }
    
    func updateForCaptureMode() {
        guard let silhouetteView = self.silhouetteView else {
            return
        }
        
        switch captureMode {
        case .front:
            switch draft.gender {
            case .female?:
                silhouetteView.image = UIImage(named: "woman-front")?.withRenderingMode(.alwaysTemplate)
            case .male?:
                silhouetteView.image = UIImage(named: "man-front")?.withRenderingMode(.alwaysTemplate)
            case .none:
                break
            }
        case .side:
            switch draft.gender {
            case .female?:
                silhouetteView.image = UIImage(named: "woman-side")?.withRenderingMode(.alwaysTemplate)
            case .male?:
                silhouetteView.image = UIImage(named: "man-side")?.withRenderingMode(.alwaysTemplate)
            case .none:
                break
            }
//        case .arm:
//            switch draft.gender {
//            case .female?:
//                silhouetteView.image = UIImage(named: "woman-side-arm")?.withRenderingMode(.alwaysTemplate)
//            case .male?:
//                silhouetteView.image = UIImage(named: "man-side-arm")?.withRenderingMode(.alwaysTemplate)
//            case .none:
//                break
//            }
        }
    }
    
    @objc func captureImage(_ sender: UIButton) {
        motionManager.stopDeviceMotionUpdates()

        cameraCaptureButton?.isEnabled = false
        cameraCaptureButton?.alpha = 0.5
        
        cameraController.captureImage {[weak self] (image, depthImage, error) in
            guard let image = image, let strongSelf = self else {
                print(error ?? "Image capture error")
                return
            }
            
            let targetImageSize = CGSize(width: 450, height: 800)
            
            switch strongSelf.captureMode {
            case .front:
                strongSelf.draft.frontPhoto = image.resizeAndCrop(toTargetSize: targetImageSize)
                //strongSelf.draft.frontDepthPhoto = depthImage
                
                strongSelf.captureMode = .side
                strongSelf.startDeviceMotionUpdates()
            case .side:
                strongSelf.draft.sidePhoto = image.resizeAndCrop(toTargetSize: targetImageSize)
                //strongSelf.draft.sideDepthPhoto = depthImage
                
//                strongSelf.captureMode = .arm
//                strongSelf.startDeviceMotionUpdates()
//            case .arm:
//                strongSelf.draft.sideArmPhoto = image.resizeAndCrop(toTargetSize: targetImageSize)
                //strongSelf.draft.sideDepthPhoto = depthImage

                // Move to share screen
                let shareViewController = ShareViewController(draft: strongSelf.draft)
                
                strongSelf.navigationController?.pushViewController(shareViewController, animated: true)
                
                strongSelf.cameraController.stopSession()
                strongSelf.motionManager.stopDeviceMotionUpdates()
            }
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
        
        if -motionData.gravity.y <= 0.8 {
            tiltStatusLabel?.text = "Keep your phone upright"
        } else if -motionData.gravity.y >= 1.2 {
            tiltStatusLabel?.text = "Keep your phone upright"
        } else if motionData.gravity.z <= -0.2 {
            tiltStatusLabel?.text = "Tilt backwards"
        } else if motionData.gravity.z >= 0.2 {
            tiltStatusLabel?.text = "Tilt forwards"
        } else {
            tiltStatusLabel?.text = nil
        }
    }
}
