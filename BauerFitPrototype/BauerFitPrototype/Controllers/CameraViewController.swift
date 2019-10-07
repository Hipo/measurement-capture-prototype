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
import Vision
import CoreMedia
import CoreML


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
            evaluateCameraCaptureState()
        }
    }
    
    let predictionZones = [
        PredictionZone(predictionRect: CGRect(x: 0.4, y: 0.04, width: 0.2, height: 0.1), pointType: .top),
        PredictionZone(predictionRect: CGRect(x: 0.05, y: 0.44, width: 0.2, height: 0.1), pointType: .leftWrist),
        PredictionZone(predictionRect: CGRect(x: 0.76, y: 0.44, width: 0.2, height: 0.1), pointType: .rightWrist),
        PredictionZone(predictionRect: CGRect(x: 0.21, y: 0.83, width: 0.2, height: 0.1), pointType: .leftAnkle),
        PredictionZone(predictionRect: CGRect(x: 0.60, y: 0.83, width: 0.2, height: 0.1), pointType: .rightAnkle),
    ]
    
    typealias EstimationModel = model_cpm
    var postProcessor: HeatmapPostProcessor = HeatmapPostProcessor()
    var mvfilters: [MovingAverageFilter] = []
    var request: VNCoreMLRequest?
    var faceDetectionRequest: VNDetectFaceRectanglesRequest?
    let visionModel: VNCoreMLModel
    
    var phonePositionError = ""
    var phoneInCorrectPosition = false {
        didSet {
            evaluateCameraCaptureState()
        }
    }
    
    var faceDetected = false {
        didSet {
            evaluateCameraCaptureState()
        }
    }
    
    var allZonesDetected = false {
        didSet {
            evaluateCameraCaptureState()
        }
    }
    
    let motionManager = CMMotionManager()
    
    var cameraCaptureButton: UIButton?
    var silhouetteView: UIImageView?
    var errorLabel: UILabel?

    override var prefersStatusBarHidden: Bool { return true }
    
    init(draft: ImageMeasurementDraft) {
        self.draft = draft
        
        guard let visionModel = try? VNCoreMLModel(for: EstimationModel().model) else {
            fatalError("cannot load the ml model")
        }
        
        self.visionModel = visionModel
        
        super.init(nibName: nil, bundle: nil)
        
        startDeviceMotionUpdates()
        
        let request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
        
        request.imageCropAndScaleOption = .scaleFill

        self.request = request
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { [weak self] (request, error) in
            if error != nil {
                print("FaceDetection error: \(String(describing: error)).")
            }
            
            guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
                let results = faceDetectionRequest.results as? [VNFaceObservation] else {
                    return
            }
            
            self?.faceDetected = (results.count > 0)
        })
        
        self.faceDetectionRequest = faceDetectionRequest

        cameraController.delegate = self
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
        silhouetteView.isHidden = !faceDetected
        silhouetteView.tintColor = .white
        
        view.addSubview(silhouetteView)
        
        NSLayoutConstraint.activate([
            silhouetteView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0),
            silhouetteView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50.0),
            silhouetteView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        self.silhouetteView = silhouetteView
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        for zone in predictionZones {
            zone.errorView.frame = CGRect(x: zone.predictionRect.origin.x * width,
                                          y: zone.predictionRect.origin.y * height,
                                          width: zone.predictionRect.size.width * width,
                                          height: zone.predictionRect.size.height * height)
            
            
            view.addSubview(zone.errorView)
        }
        
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
        
        errorLabel = statusLabel
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
                
                UIApplication.shared.isIdleTimerDisabled = true
            case .side:
                strongSelf.draft.sidePhoto = image.resizeAndCrop(toTargetSize: targetImageSize)
                //strongSelf.draft.sideDepthPhoto = depthImage

                // Move to share screen
                let shareViewController = ShareViewController(draft: strongSelf.draft)
                
                strongSelf.navigationController?.pushViewController(shareViewController, animated: true)
                
                strongSelf.cameraController.stopSession()
                strongSelf.motionManager.stopDeviceMotionUpdates()

                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    
    func updateInterfaceWithMotionData(motionData: CMDeviceMotion) {
        if !isViewLoaded {
            return
        }
        
        if -motionData.gravity.y <= 0.8 {
            phonePositionError = "Keep your phone upright"
        } else if -motionData.gravity.y >= 1.2 {
            phonePositionError = "Keep your phone upright"
        } else if motionData.gravity.z <= -0.2 {
            phonePositionError = "Tilt backwards"
        } else if motionData.gravity.z >= 0.2 {
            phonePositionError = "Tilt forwards"
        } else {
            phonePositionError = ""
        }
        
        phoneInCorrectPosition = (-motionData.gravity.y > 0.9 && -motionData.gravity.y < 1.1)
                                    && (motionData.gravity.z > -0.1 && motionData.gravity.z < 0.1)
    }
    
    func evaluateCameraCaptureState() {
        DispatchQueue.main.async {
            if self.captureMode != .front {
                for zone in self.predictionZones {
                    zone.errorView.isHidden = true
                }
            }
            
            if !self.faceDetected && self.captureMode == .front {
                self.silhouetteView?.isHidden = true
                
                for zone in self.predictionZones {
                    zone.errorView.isHidden = true
                }
                
                self.errorLabel?.text = "Position subject in view"

                self.setCameraCaptureEnabled(enabled: false)
                
                return
            } else if !self.phoneInCorrectPosition {
                self.silhouetteView?.isHidden = false
                self.errorLabel?.text = self.phonePositionError
                
                for zone in self.predictionZones {
                    zone.errorView.isHidden = !(self.captureMode == .front)
                }

                self.setCameraCaptureEnabled(enabled: false)
                
                return
            } else if !self.allZonesDetected && self.captureMode == .front {
                self.silhouetteView?.isHidden = false
                self.errorLabel?.text = "Position head, wrists, ankles in zones"
                
                for zone in self.predictionZones {
                    zone.errorView.isHidden = false
                }
                
                self.setCameraCaptureEnabled(enabled: false)
                
                return
            }
            
            self.errorLabel?.text = ""
            self.setCameraCaptureEnabled(enabled: true)
        }
    }
    
    func setCameraCaptureEnabled(enabled: Bool) {
        cameraCaptureButton?.isEnabled = enabled
        cameraCaptureButton?.alpha = enabled ? 1.0 : 0.5
    }
}

extension CameraViewController : CameraControllerDelegate {
    
    func videoCapture(_ capture: CameraController,
                      didCaptureVideoFrame pixelBuffer: CVPixelBuffer?,
                      timestamp: CMTime) {
        
        guard let pixelBuffer = pixelBuffer else {
            return
        }
        
        self.predictUsingVision(pixelBuffer: pixelBuffer)
    }
}

extension CameraViewController {

    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = request,
            let faceDetectionRequest = faceDetectionRequest else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        
        try? imageRequestHandler.perform([faceDetectionRequest, request])
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if !faceDetected || self.captureMode != .front {
            return
        }

        guard let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let heatmaps = observations.first?.featureValue.multiArrayValue else {
                return
        }
        
        var predictedPoints = postProcessor.convertToPredictedPoints(from: heatmaps)
        
        /* --------------------- moving average filter ----------------------- */
        if predictedPoints.count != mvfilters.count {
            mvfilters = predictedPoints.map { _ in MovingAverageFilter(limit: 3) }
        }
        
        for (predictedPoint, filter) in zip(predictedPoints, mvfilters) {
            filter.add(element: predictedPoint)
        }
        
        predictedPoints = mvfilters.map { $0.averagedValue() }
        /* =================================================================== */
        
        /* ======================= display the results ======================= */
        DispatchQueue.main.sync {
            var topPointPrediction: PredictedPoint?
            var leftWristPrediction: PredictedPoint?
            var rightWristPrediction: PredictedPoint?
            var leftAnklePrediction: PredictedPoint?
            var rightAnklePrediction: PredictedPoint?
            var finalPoints:[PredictedPoint] = []

            for (index, point) in predictedPoints.enumerated() {
                guard let point = point,
                    let index = PredictedPointType(rawValue: index) else {
                    continue
                }
                
                switch index {
                case .top:
                    topPointPrediction = point
                case .leftAnkle:
                    leftAnklePrediction = point
                case .rightAnkle:
                    rightAnklePrediction = point
                case .leftWrist:
                    leftWristPrediction = point
                case .rightWrist:
                    rightWristPrediction = point
                default:
                    continue
                }
                
                finalPoints.append(point)
            }
            
            //pointsView?.bodyPoints = finalPoints
            
            // TODO: Put together cascading set of rules based on point locations and confidence
            /*
             Things to look for:
             
             * Check confidence in all points --> Cannot see subject
             * Top and left/right ankle should be close to top/bottom edges (within 5%) --> Get closer
             * Middle line should intersect with top and left/right ankle center point (within 5%) --> Position the subject at the center of frame
             * Arms should be spread out --> Spread out arms
             * Legs should be spread out --> Spread out legs
             
             */
            
            guard let topPoint = topPointPrediction,
                let leftWrist = leftWristPrediction,
                let rightWrist = rightWristPrediction,
                let leftAnkle = leftAnklePrediction,
                let rightAnkle = rightAnklePrediction else {
                    return // TODO: Show error (missing points)
            }
            
            for point in finalPoints {
                if point.maxConfidence < 0.8 {
                    return // TODO: Show error (position better)
                }
            }
            
            var matchedZones: [PredictionZone] = []
            
            for zone in predictionZones {
                var positionMatched = false
                
                switch zone.pointType {
                case .top:
                    positionMatched = zone.contains(point: topPoint.maxPoint)
                case .leftWrist:
                    positionMatched = zone.contains(point: leftWrist.maxPoint)
                case .rightWrist:
                    positionMatched = zone.contains(point: rightWrist.maxPoint)
                case .leftAnkle:
                    positionMatched = zone.contains(point: leftAnkle.maxPoint)
                case .rightAnkle:
                    positionMatched = zone.contains(point: rightAnkle.maxPoint)
                default:
                    continue
                }
                
                zone.errorView.showError = !positionMatched
                
                if positionMatched {
                    matchedZones.append(zone)
                }
            }
            
            allZonesDetected = (matchedZones.count == predictionZones.count)
        }
    }
}
