// Copyright (c) 2017, arconsis IT-Solutions GmbH
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// The views and conclusions contained in the software and documentation are those
// of the authors and should not be interpreted as representing official policies,
// either expressed or implied, of the FreeBSD Project.

import Foundation
import CoreMotion
import UIKit

protocol DeviceMotionHandlerDelegate: class {
    
    func didUpdate(gravityDirection: CGVector, angularVelocity: CGFloat)
}

class DeviceMotionHandler {
    
    weak var delegate: DeviceMotionHandlerDelegate?
    
    let motionQueue = OperationQueue()
    let motionManager = CMMotionManager()
    
    func start() {
        motionManager.startDeviceMotionUpdates(to: motionQueue, withHandler: gravityUpdated)
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func gravityUpdated(motion: CMDeviceMotion?, error: Error?) {
        guard let motion = motion else {
            return
        }
        let gravity: CMAcceleration = motion.gravity
        let point = CGPoint(x: gravity.x, y: gravity.y)
        
        DispatchQueue.main.async {
            let orientation = UIApplication.shared.statusBarOrientation
            let gravityPoint = self.adjustedGravityPoint(for: orientation, and: point)
            let gravityDirection = CGVector(dx: gravityPoint.x, dy: 0 - gravityPoint.y)
            let angularVelocity = CGFloat(motion.rotationRate.z * 0.01)
            self.delegate?.didUpdate(gravityDirection: gravityDirection, angularVelocity: angularVelocity)
        }
    }
    
    private func adjustedGravityPoint(for orientation: UIInterfaceOrientation, and point: CGPoint) -> CGPoint {
        var newPoint = point
        if orientation == .landscapeLeft {
            let t = newPoint.x
            newPoint.x = 0 - newPoint.y
            newPoint.y = t
        } else if orientation == .landscapeRight {
            let t = newPoint.x
            newPoint.x = newPoint.y
            newPoint.y = 0 - t
        } else if orientation == .portraitUpsideDown {
            newPoint.x *= -1
            newPoint.y *= -1
        }
        return newPoint
    }
}
