//
//  AnimationChain.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 11/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class AnimationChain: ConcreteAnimation, AnimationDelegate {
    
    var animations: [DelegatedAnimation]
    
    init(animations: [DelegatedAnimation]) {
        self.animations = animations
        super.init()
        self.animations.forEach { (animation) -> () in
            animation.delegate = self
            animation.postpone()
        }
    }
    
    @objc override var duration: NSTimeInterval {
        get {
            return self.animations.reduce(0.0, combine: { (c, animation) -> NSTimeInterval in
                return c + animation.delay + animation.duration
            })
        }
        set {}
    }
    
    @objc override var delay: NSTimeInterval {
        get {
            return 0.0
        }
        set {}
    }
    
    @objc override var finished: Bool {
        @objc(isFinished) get {
            return self.animations.all({ $0.finished && $0.progressState == .End })
        }
        set {}
    }
    
    override var position: NSTimeInterval {
        didSet {
            var total = 0.0
            animations.forEach { (animation) in
                animation.position = max(0.0, min(animation.delay + animation.duration, position - total))
                total += animation.delay + animation.duration
            }
        }
    }
    
    override func commitAnimation() {
        state = .Comited
        progressState = .InProgress
        animateNext()
    }
    
    override func then(animation animation: Animation) -> Animation {
        if let animation = animation as? DelegatedAnimation {
            animation.postpone()
            animation.delegate = self
            animations.append(animation)
        }
        return self
    }
    
    private func animateNext() {
        if let nextAnimation = animations.filter({ $0.progressState != .End }).first as? ConcreteAnimation {
            nextAnimation.commitAnimation()
        } else {
            progressState = .End
        }
    }
    
    func animationCompleted(animation: Animation, finished: Bool) {
        guard state == .Comited else { return }
        animateNext()
    }
    
}