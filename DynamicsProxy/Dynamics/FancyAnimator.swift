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
import UIKit

class FancyAnimator {
    
    private var animator: UIDynamicAnimator?
    private var gravity: UIGravityBehavior?
    private var itemBehavior: UIDynamicItemBehavior?
    private var collision: UICollisionBehavior?
    
    private weak var containerView: UIView?
    private weak var animatedView: UIView?
    private var proxyView: DynamicProxyItem
    
    private let deviceMotionHandler = DeviceMotionHandler()
    
    init(containerView: UIView, animatedView: UIView) {
        self.containerView = containerView
        self.animatedView = animatedView
        self.proxyView = DynamicProxyItem(view: animatedView)
        deviceMotionHandler.delegate = self
    }
    
    func start() {
        setup()
        deviceMotionHandler.start()
    }
    
    func reset() {
        deviceMotionHandler.stop()
        animator?.removeAllBehaviors()
        animateToOriginialPosition()
        guard let animatedView = animatedView else {
            return
        }
        self.proxyView = DynamicProxyItem(view: animatedView)
    }
    
    private func setup() {
        guard let container = containerView else {
            return
        }
        animator = UIDynamicAnimator(referenceView: container)
        
        gravity = UIGravityBehavior()
        gravity?.gravityDirection = CGVector(dx: 0, dy: 2)
        
        collision = UICollisionBehavior()
        collision?.translatesReferenceBoundsIntoBoundary = true
        
        itemBehavior = UIDynamicItemBehavior()
        itemBehavior?.friction = 0.1;
        itemBehavior?.elasticity = 0.5
        
        configureBehaviorActions()
        applyBehaviors()
    }
    
    private func configureBehaviorActions() {
        guard let gravity = gravity, let collision = collision, let itemBehavior = itemBehavior else {
            return
        }
        [gravity, collision, itemBehavior].forEach { behavior in
            behavior.action = {
                self.applyProxyTransformToRealView()
            }
        }
    }
    
    private func applyBehaviors() {
        guard let gravity = gravity, let collision = collision, let itemBehavior = itemBehavior else {
            return
        }
        gravity.addItem(proxyView)
        collision.addItem(proxyView)
        itemBehavior.addItem(proxyView)
        animator?.addBehavior(gravity)
        animator?.addBehavior(collision)
        animator?.addBehavior(itemBehavior)
    }
    
    private func animateToOriginialPosition() {
        UIView.animate(withDuration: 0.2) {
            self.animatedView?.transform = .identity
        }
    }
    
    private func applyProxyTransformToRealView() {
        self.animatedView?.transform = self.proxyView.absoluteTransform
    }
}

extension FancyAnimator: DeviceMotionHandlerDelegate {
    
    func didUpdate(gravityDirection: CGVector, angularVelocity: CGFloat) {
        self.itemBehavior?.addAngularVelocity(angularVelocity, for: self.proxyView)
        self.gravity?.gravityDirection = gravityDirection;
    }
}
