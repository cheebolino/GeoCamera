//
//  ContentView.swift
//  GeoCamera
//
//  Created by Cheeba on 12.10.2022.
//

import SwiftUI

struct ContentView: View {
    
    @State var elevations: [String : Float] = [:]
    
    @StateObject var camera = CameraModel()
    @StateObject var locationManager = LocationManager()
    @StateObject var motionManager = MotionManager()
    
    var userLatitude: String {
        return String(format: "%.3f", locationManager.lastLocation?.coordinate.latitude ?? 0)
    }
    
    var userLongitude: String {
        return String(format: "%.3f", locationManager.lastLocation?.coordinate.longitude ?? 0)
    }
    
    var userAltitude: String {
        return String(format: "%.1f", locationManager.lastLocation?.altitude ?? 0)
//        return "\(locationManager.lastLocation?.altitude ?? 0)"
    }
    
    var userHeading: String {
        return String(format: "%.1f", locationManager.lastHeading?.trueHeading ?? 0)
//        return "\(locationManager.lastHeading?.trueHeading ?? 0)"
    }
    
    var userPitch: String {
        return String(format: "%.1f", devicePitch)
//        return "\(motionManager.pitch)"
    }
    
    var userRoll: String {
        return "\(motionManager.roll)"
    }
    
    var userDistance: String {
        if devicePitch > 90 {
            return "inf"
        }
        return String(format: "%.0f", Double(userElevationAboveGround)/Double(cos(devicePitch/57.2957795)) )
    }
    
    var userGroundLevel: String {
        let latlng = "\(userLatitude),\(userLongitude)"
        
        if elevations[latlng] != nil {
            return String(elevations[latlng]!)
        }
        
        Task {
            await loadElevation(latlng: latlng)
        }
        
        return String(elevations[latlng] ?? 0)
    }
    
    var userElevationAboveGround: Float {
        return Float(locationManager.lastLocation?.altitude ?? 0) - Float(userGroundLevel)!
    }
    
    var devicePitch: Double {
        switch UIDevice.current.orientation {
        case .portrait:
            return motionManager.pitch * 57.2957795
        case .landscapeLeft:
            return -motionManager.roll * 57.2957795
        case .landscapeRight:
            return motionManager.roll * 57.2957795
        default:
            return 0
        }
    }
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            Circle().frame(width: 10, height: 10)
            
            VStack {
                HStack {
                    VStack {
                        Text(userLatitude)
                        Text(userLongitude)
                    }
                    Spacer()
                    VStack {
                        Text(userAltitude)
                        Text(userGroundLevel)
                        Text(String(format: "%.1f", userElevationAboveGround))
                    }
                }
                
                Spacer()
                
                Text("\(userDistance) m")
                
//                Spacer()
                
                HStack {
                    Text(userHeading)
                    Spacer()
                    Text(userPitch)
                    //Text(userRoll)
                }
                
            }.padding(20)
            
        }
        .onAppear() {
            camera.Check()
        }
    }
    
    func loadElevation(latlng: String) async {
        guard let url = URL(string: "https://api.opentopodata.org/v1/aster30m?locations=\(latlng)") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let openTopoResponse = try JSONDecoder().decode(OpenTopoResponce.self, from: data)
            
            elevations[latlng] = openTopoResponse.results.first?.elevation
        } catch {
            print("Invalid data")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct OpenTopoResponce: Decodable {
    var results: [OpenTopoResult]
}

struct OpenTopoResult: Decodable {
    var dataset: String
    var elevation: Float
    var location: [String:Float]
}
