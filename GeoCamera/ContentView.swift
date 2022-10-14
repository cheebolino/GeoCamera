//
//  ContentView.swift
//  GeoCamera
//
//  Created by Cheeba on 12.10.2022.
//

import SwiftUI
import AVFoundation
import CoreLocation

struct ContentView: View {
    
    @StateObject var camera = CameraModel()
    @StateObject var locationManager = LocationManager()
    
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }
    
    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    
    var userAltitude: String {
        return "\(locationManager.lastLocation?.altitude ?? 0)"
    }
    
    var userHeading: String {
        return "\(locationManager.lastHeading?.trueHeading ?? 0)"
    }
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            VStack {
                Text("\(userLatitude)")
                Text("\(userLongitude)")
                Text("\(userAltitude)")
                Text("\(userHeading)")
            }
            
        }
        .onAppear() {
            camera.Check()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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
        camera.preview.videoGravity = .resize
        
        view.layer.addSublayer(camera.preview)
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var lastHeading: CLHeading?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.first
        print(#function, locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        lastHeading = newHeading
        print(#function, newHeading)
    }
    
}
