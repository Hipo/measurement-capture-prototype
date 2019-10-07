//
//  CameraController.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-03.
//  Copyright © 2019 Hipo. All rights reserved.
//

import AVFoundation
import UIKit


protocol CameraControllerDelegate: class {
  func videoCapture(_ capture: CameraController,
                    didCaptureVideoFrame: CVPixelBuffer?,
                    timestamp: CMTime)
}


class CameraController: NSObject {
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition?
    
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    private lazy var videoDataOutput = AVCaptureVideoDataOutput()
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    var photoCaptureCompletionBlock: ((UIImage?, UIImage?, Error?) -> Void)?
    
    weak var delegate: CameraControllerDelegate?
}

extension CameraController {
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
            
            self.captureSession?.sessionPreset = .high
        }
        
        func configureCaptureDevices() throws {
            let deviceTypes: [AVCaptureDevice.DeviceType] = [
                .builtInDualCamera,
                .builtInTrueDepthCamera,
                .builtInTelephotoCamera,
                .builtInWideAngleCamera
            ]

            let session = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                           mediaType: AVMediaType.video,
                                                           position: .unspecified)

            let cameras = session.devices.compactMap { $0 }
            
            guard !cameras.isEmpty else {
                throw CameraControllerError.noCamerasAvailable
            }

            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }

                if camera.position == .back {
                    if let rearCamera = self.rearCamera,
                        rearCamera.deviceType == .builtInWideAngleCamera {
                        continue
                    }
                    
                    self.rearCamera = camera

                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)
                    
                } else {
                    throw CameraControllerError.inputsAreInvalid
                }
                
                self.currentCameraPosition = .front
            } else {
                throw CameraControllerError.noCamerasAvailable
            }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            let photoOutput = AVCapturePhotoOutput()
            
            photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])],
                                                      completionHandler: nil)
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                
                if photoOutput.isDepthDataDeliverySupported {
                    photoOutput.isDepthDataDeliveryEnabled = true
                }
                
                self.photoOutput = photoOutput
            }

            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try self.configureVideoOutput()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func configureVideoOutput() throws {
        guard let captureSession = self.captureSession else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")

        videoDataOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCMPixelFormat_32BGRA]

        if !captureSession.canAddOutput(videoDataOutput) {
          throw CameraControllerError.captureSessionIsMissing
        }

        captureSession.addOutput(videoDataOutput)
        
        videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(previewLayer, at: 0)

        previewLayer.frame = view.frame
        
        self.previewLayer = previewLayer
    }
    
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition,
            let captureSession = self.captureSession,
            captureSession.isRunning else {
                throw CameraControllerError.captureSessionIsMissing
        }
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            
            guard let rearCameraInput = self.rearCameraInput, captureSession.inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            }
                
            else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        func switchToRearCamera() throws {
            
            guard let frontCameraInput = self.frontCameraInput, captureSession.inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
    func captureImage(completion: @escaping (UIImage?, UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else {
            completion(nil, nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        
        guard let photoOutput = self.photoOutput else {
            completion(nil, nil, CameraControllerError.invalidOperation)
            return
        }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        settings.flashMode = self.flashMode
        
        if photoOutput.isDepthDataDeliveryEnabled {
            settings.isDepthDataDeliveryEnabled = true
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)

        self.photoCaptureCompletionBlock = completion
    }
    
    func stopSession() {
        captureSession?.stopRunning()
    }
    
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photo: AVCapturePhoto,
                            error: Error?) {
        
        guard let completionBlock = self.photoCaptureCompletionBlock else {
            return
        }
        
        if let error = error {
            completionBlock(nil, nil, error)
            
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            completionBlock(nil, nil, CameraControllerError.unknown)
            
            return
        }
        
        let image = UIImage(data: imageData)
        
        if let depthData = photo.depthData,
            let depthImage = UIImage(pixelBuffer: depthData.depthDataMap) {
            
            completionBlock(image, depthImage, nil)
            return
        }
        
        completionBlock(image, nil, nil)
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            
        delegate?.videoCapture(self, didCaptureVideoFrame: imageBuffer,
                               timestamp: timestamp)
    }

}

extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}
