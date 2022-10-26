//
//  ContentView.swift
//  GeoCamera
//
//  Created by Cheeba on 12.10.2022.
//

import SwiftUI

struct ContentView: View {
    
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
        return String(format: "%.3f", locationManager.lastLocation?.altitude ?? 0)
//        return "\(locationManager.lastLocation?.altitude ?? 0)"
    }
    
    var userHeading: String {
        return String(format: "%.1f", locationManager.lastHeading?.trueHeading ?? 0)
//        return "\(locationManager.lastHeading?.trueHeading ?? 0)"
    }
    
    var userPitch: String {
        return String(format: "%.1f", motionManager.pitch * 57.2957795)
//        return "\(motionManager.pitch)"
    }
    
    var userRoll: String {
        return "\(motionManager.roll)"
    }
    
    var userDistance: String {
        if motionManager.pitch * 57.2957795 > 90 {
            return "inf"
        }
        return String(format: "%.0f", (locationManager.lastLocation?.altitude ?? 0) / cos(motionManager.pitch) )
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
                    Text(userAltitude)
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
    
    func round3digits(number: Float?) -> Float {
        return round((number ?? 0) * 1000) / 1000.0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
