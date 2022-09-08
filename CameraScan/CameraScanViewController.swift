//
//  CameraScanViewController.swift
//  KFoodMenuScan
//
//  Created by yyjweber on 2022/08/16.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, SelectWordViewControllerDelegate {
    
    private lazy var captureDevice = AVCaptureDevice.default(for: .video)
    private var session: AVCaptureSession?
    private var output = AVCapturePhotoOutput()
    
    @IBOutlet weak var scanOverlayImg: UIImageView!
    @IBOutlet weak var scanShutterImg: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addBackButton()
        settingCamera()
    }
    
    private func addBackButton() {
            
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .large)
        let imgObj = UIImage(systemName: "arrow.backward", withConfiguration: imgConfig)
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        let btnBack = UIButton(frame: CGRect(x: -15, y: 0, width: 60, height: 45))
        btnBack.setImage(imgObj, for: .normal)
        btnBack.tintColor = .white
        btnBack.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        containerView.addSubview(btnBack)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
        self.navigationController?.navigationBar.barTintColor = .white

    }
    
    @objc func backAction(_ sender: UIButton) {
        
       self.navigationController?.popViewController(animated: true)
    }
    
    //Camera Settings
    private func settingCamera() {
        
        guard let captureDevice = captureDevice else { return }
        
        do {
            
            let session = AVCaptureSession()
            let input = try AVCaptureDeviceInput(device: captureDevice)
            //let output = AVCapturePhotoOutput()
            
            session.sessionPreset = .photo
            session.addInput(input)
            session.addOutput(output)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill //fullscreen
            previewLayer.frame = view.frame
            view.layer.addSublayer(previewLayer)
            session.startRunning()
            
            
            view.bringSubviewToFront(scanOverlayImg)
            view.bringSubviewToFront(scanShutterImg)
            
            
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchCamera(_:)))
            view.addGestureRecognizer(pinch)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapFocusCamera(_:)))
            view.addGestureRecognizer(tap)
            view.isUserInteractionEnabled = true
            
        } catch {
            
            print(error)
            
        }

    }
    
    @objc func handlePinchCamera(_ pinch: UIPinchGestureRecognizer) {
        
        guard let captureDevice = captureDevice else {return}
            
        var initialScale: CGFloat = captureDevice.videoZoomFactor
        let minAvailableZoomScale = 1.0
        let maxAvailableZoomScale = captureDevice.maxAvailableVideoZoomFactor
        
        do {
            
            try captureDevice.lockForConfiguration()
            if(pinch.state == UIPinchGestureRecognizer.State.began) {
                
                initialScale = captureDevice.videoZoomFactor
                
            } else {
                
                if(initialScale*(pinch.scale) < minAvailableZoomScale) {
                    
                    captureDevice.videoZoomFactor = minAvailableZoomScale
                    
                }
                
                else if(initialScale*(pinch.scale) > maxAvailableZoomScale) {
                    
                    captureDevice.videoZoomFactor = maxAvailableZoomScale
                    
                } else {
                    
                    captureDevice.videoZoomFactor = initialScale * (pinch.scale)
                }
            }
            
            pinch.scale = 1.0
            
        } catch {
            
            return
        }
        captureDevice.unlockForConfiguration()
    }
    
    @objc func tapFocusCamera(_ sender: UITapGestureRecognizer) {
        
        guard let captureDevice = captureDevice else {return}
        
        if (sender.state == .ended) {
            
            let thisFocusPoint = sender.location(in: view)
            let focus_x = thisFocusPoint.x / view.frame.size.width
            let focus_y = thisFocusPoint.y / view.frame.size.height
            
            focusAnimationAt(thisFocusPoint)

            if (captureDevice.isFocusModeSupported(.autoFocus) && captureDevice.isFocusPointOfInterestSupported) {
                
                do {
                    
                    try captureDevice.lockForConfiguration()
                    captureDevice.focusMode = .autoFocus
                    captureDevice.focusPointOfInterest = CGPoint(x: focus_x, y: focus_y)

                    if (captureDevice.isExposureModeSupported(.autoExpose) && captureDevice.isExposurePointOfInterestSupported) {
                        captureDevice.exposureMode = .autoExpose;
                        captureDevice.exposurePointOfInterest = CGPoint(x: focus_x, y: focus_y);
                     }

                    captureDevice.unlockForConfiguration()
                    
                } catch {
                    
                    print(error)
                }
            }
        }
    }
    
    fileprivate func focusAnimationAt(_ point: CGPoint) {
        
        print("zoom in/out start---->>")
        
        let focusView = UIImageView(image: UIImage(systemName: "circle.dotted"))
        focusView.center = point
        view.addSubview(focusView)

        focusView.transform = CGAffineTransform(scaleX: 1, y: 1)

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            
            focusView.transform = CGAffineTransform(scaleX: 3, y: 3)
        
        }) { (success) in
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            
                focusView.alpha = 0.0
            
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func cameraShutterClick(_ sender: Any) {
        
        print("take a picture---->>")

        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.flashMode = .auto
        
        output.capturePhoto(with: photoSettings, delegate: self)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        print("---->> didFinishProcessingPhoto")
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("imageData Error")
            return
        }
        
        let storyBoard = UIStoryboard(name: "SelectWord", bundle: nil)
        guard let controller = storyBoard.instantiateViewController(withIdentifier: "SelectWord") as? SelectWordViewController else {return}
        
        controller.oriImage = UIImage(data: imageData)?.orientationCorrectedImage
        controller.delegate = self
        
        print("++++++++++ width and height after taking a picture")
        print(UIImage(data: imageData)!.size.width)
        print(UIImage(data: imageData)!.size.height)
        
        self.navigationController?.pushViewController(controller, animated: true)
            
        //to save captured photo
        guard error == nil else { print("Error capturing photo: \(error!)"); return }

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
                
            })
        }
    }
    
    func didSelectImage(_ image: UIImage) {
        
        print(">>>> didSelectImage")
        
    }
    
}
