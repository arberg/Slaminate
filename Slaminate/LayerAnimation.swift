//
//  LayerAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class LayerAnimation: DirectAnimation {
    
    override class func canAnimate(object: NSObject, key: String) -> Bool {
        guard (object.valueForKey(key) as? Interpolatable)?.canInterpolate == true else { return false }
        guard let layer = object as? CoreAnimationKVCExtension else { return false }
        return layer.dynamicType.animatableKeyPaths.contains(key)
    }
    
    var layer: CALayer
    
    var delayTimer: NSTimer?
    
    var animation: CurvedAnimation?
    
    required init(duration: NSTimeInterval, object: NSObject, key: String, toValue: Any, curve: Curve) {
        self.layer = object as! CALayer
        super.init(duration: duration, object: object, key: key, toValue: toValue, curve: curve)
    }
    
    override func animationDidStart(anim: CAAnimation) {
        object.setValue((fromValue as! Interpolatable).interpolate(toValue as! Interpolatable, curve.transform(1.0)).objectValue!, forKey: key)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        animation?.delegate = nil
        complete(flag)
    }
    
    override func commit() {
        
        fromValue = fromValue ?? (layer.presentationLayer() ?? layer).valueForKey(key)
        
        animation = CurvedAnimation(keyPath: key)
        animation?.duration = duration
        animation?.position = max(0.0, position - delay)
        animation?.fromValue = fromValue as? Interpolatable
        animation?.toValue = toValue as? Interpolatable
        animation?.curve = curve
        animation?.speed = Float(speed)
        animation?.delegate = self
        animation?.removedOnCompletion = true
        
        layer.addAnimation(animation!, forKey: "animation_\(key)")
        
    }
    
}