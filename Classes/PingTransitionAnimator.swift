//
//  PingTransitionAnimator.swift
//  PingAnimatedTransition
//
//  Created by Devon Boyer on 2014-12-03.
//  Copyright (c) 2014 Inner Geek. All rights reserved.
//

import UIKit

@objc protocol PingTransitionAnimatorDelegate {
    
    optional func pingTransitionDidBegin()
    optional func pingTransitionDidCancel()
    optional func pingTransitionDidFinish()
}

@objc protocol PingTransitionAnimatorProtocol {
    
    func initialRectForPingTransition() -> CGRect
}

class PingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  
    @IBOutlet weak var delegate: PingTransitionAnimatorDelegate?
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    private var maskLayerAnimation = CABasicAnimation()
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.25;
    }
  
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        var containerView = transitionContext.containerView()
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as ViewController
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as ViewController
        
        // Check to make sure that the fromViewController conforms to the required protocol
        if !fromViewController.conformsToProtocol(PingTransitionAnimatorProtocol) {
            NSLog("fromViewController does not conform to <%@>", NSStringFromProtocol(PingTransitionAnimatorProtocol))
        }
        
        var initialRect = (fromViewController as PingTransitionAnimatorProtocol).initialRectForPingTransition()
        var initialRectCenter = CGPointMake(initialRect.origin.x + initialRect.width / 2.0, initialRect.origin.y + initialRect.height / 2.0)
        
        containerView.addSubview(toViewController.view)

        var circleMaskPathInitial = UIBezierPath(ovalInRect: initialRect)
        var extremePoint = CGPoint(x: initialRectCenter.x - 0, y: initialRectCenter.y - CGRectGetHeight(toViewController.view.bounds))
        var radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        var circleMaskPathFinal = UIBezierPath(ovalInRect: CGRectInset(initialRect, -radius, -radius))

        var maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.CGPath
        toViewController.view.layer.mask = maskLayer

        maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.CGPath
        maskLayerAnimation.toValue = circleMaskPathFinal.CGPath
        maskLayerAnimation.duration = self.transitionDuration(transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
        
        delegate?.pingTransitionDidBegin!()
    }
  
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if self.transitionContext!.transitionWasCancelled() {
            delegate?.pingTransitionDidCancel!()
            self.transitionContext?.completeTransition(false)
        }
        else {
            delegate?.pingTransitionDidFinish!()
            self.transitionContext?.completeTransition(true)
        }
        
        self.transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view.layer.mask = nil
    }
}
