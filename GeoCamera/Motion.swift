//
//  Motion.swift
//  GeoCamera
//
//  Created by Cheeba on 25.10.2022.
//

import Foundation
import CoreMotion

class MotionManager: NSObject, ObservableObject {
    
    private let motionManager = CMMotionManager()
    @Published var pitch = 0.0
    @Published var roll = 0.0
    
    override init() {
        super.init()
        
        motionManager.deviceMotionUpdateInterval = 1/60
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                
                if let motionData = motionData {
                    self.pitch = motionData.attitude.pitch
                    self.roll  = motionData.attitude.roll
                }
            }
        }
    }
    
    
}
