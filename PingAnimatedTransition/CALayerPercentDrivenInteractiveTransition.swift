//
//  CALayerPercentDrivenInteractiveTranstion.swift
//  PingAnimatedTransition
//
//  Created by Devon Boyer on 2014-12-03.
//  Copyright (c) 2014 Inner Geek. All rights reserved.
//

import UIKit

/**
 * When using gesture driven UIPercentDrivenInteractiveTransition with CABasicAnimation (or any other CAAnimation), upon 
 * finishInteractiveTransition, the animation jumps to the final position, rather then animating smoothly as is the case when using 
 * UIView animations. The problem with CAAnimations is their begingTime, timeOffSet, speed properties are not set correctly. This wrapper 
 * class will help to correct the incorrect timing of CABasicAnimations to allow animations to finish or cancel smoothly.
 */
class CALayerPercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    var transitionDuration: NSTimeInterval = 0.25
    var pausedTime: NSTimeInterval = 0
    
    weak var transitionContext: UIViewControllerContextTransitioning?

    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        self.transitionContext = transitionContext
        self.pauseLayer(transitionContext.containerView().layer)
    }
    
    override func updateInteractiveTransition(percentComplete: CGFloat) {
        super.updateInteractiveTransition(percentComplete)
        
        transitionContext?.containerView().layer.timeOffset = pausedTime + (transitionDuration * NSTimeInterval(percentComplete))
    }
    
    override func cancelInteractiveTransition() {
        super.cancelInteractiveTransition()
        
        let containerLayer = transitionContext?.containerView().layer
        containerLayer?.speed = -1.0
        containerLayer?.beginTime = CACurrentMediaTime();
        let delay = (CFTimeInterval((1.0 - self.completionSpeed)) * transitionDuration) + CFTimeInterval(0.075)
        
        self.delay(delay, closure: { () -> () in
            containerLayer!.speed = 1.0
        })
    }
    
    override func finishInteractiveTransition() {
        super.finishInteractiveTransition()
        self.resumeLayer(transitionContext!.containerView().layer)
    }
    
    private func pauseLayer(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
        self.pausedTime = pausedTime;
    }
    
    private func resumeLayer(layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0;
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        layer.beginTime = timeSincePause;
    }
    
    private func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}