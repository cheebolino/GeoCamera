//
//  Camera.swift
//  GeoCamera
//
//  Created by Cheeba on 26.10.2022.
//

import Foundation
import AVFoundation
import SwiftUI

class CameraModel: ObservableObject {
    
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    func Check() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            SetUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.SetUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        case .restricted:
            return
        @unknown default:
            return
        }
    }
    
    func SetUp() {
        //setting up camera
        
        do {
            self.session.beginConfiguration()
            
            let device = AVCaptureDevice.default(for: .video)
            let input = try AVCaptureDeviceInput(device: device!)
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(camera.preview)
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        switch UIDevice.current.orientation {
        case .landscapeRight:
            camera.preview.connection?.videoOrientation = .landscapeLeft
        case .landscapeLeft:
            camera.preview.connection?.videoOrientation = .landscapeRight
        case .portrait:
            camera.preview.connection?.videoOrientation = .portrait
        default:
            break
        }
        
        camera.preview.frame = UIScreen.main.bounds
    }
//
//    override func viewWillLayoutSubviews() {
//        self.previewLayer.frame = self.view.bounds
//        if previewLayer.connection.isVideoOrientationSupported {
//            self.previewLayer.connection.videoOrientation = self.interfaceOrientation(toVideoOrientation: UIApplication.shared.statusBarOrientation)
//        }
//    }

    func interfaceOrientation(toVideoOrientation orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            break
        }

        print("Warning - Didn't recognise interface orientation (\(orientation))")
        return .portrait
    }
}
