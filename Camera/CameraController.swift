//
//  CameraController.swift
//  Instagram
//
//  Created by zaki kasem  on 2/9/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
import AVFoundation
class CameraController:UIViewController,AVCapturePhotoCaptureDelegate {
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice!
    
    var stillImageOutput: AVCapturePhotoOutput!
    var stillImage: UIImage?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let captureSession = AVCaptureSession()
    let dismissButton :UIButton = {
        let button = UIButton(type:.system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    let capturePhotoButton :UIButton = {
        let button = UIButton(type:.system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupHUD()
        
    }
    
    fileprivate func setupHUD () {
        view.addSubview(capturePhotoButton)
        view.addSubview(dismissButton)
        capturePhotoButton.setAnchor(top: nil, left: nil, right: nil, bottom: view.bottomAnchor, paddingBottom: 24, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 80, width: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dismissButton.setAnchor(top: view.topAnchor, left: nil, right: view.rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 12, paddingTop: 12, height: 50, width: 50)
    }
    @objc func handleCapturePhoto() {
        print("Capturing photo")
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        stillImageOutput.isHighResolutionCaptureEnabled = true
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
    
    fileprivate func setupCaptureSession() {
        stillImageOutput = AVCapturePhotoOutput()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
        // el devices hena b nill 3shan mfish asln iPhone mtwsl
        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
        currentDevice = backFacingCamera
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice ) else{
            return
        }
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(stillImageOutput)
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(cameraPreviewLayer!)
        
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        cameraPreviewLayer?.frame = view.layer.frame
        view.bringSubviewToFront(capturePhotoButton)
        
        captureSession.startRunning()
        
    }
}
