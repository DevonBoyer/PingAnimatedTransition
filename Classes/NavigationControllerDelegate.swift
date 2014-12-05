//
//  NavigationControllerDelegate.swift
//  PingAnimatedTransition
//
//  Created by Devon Boyer on 2014-12-03.
//  Copyright (c) 2014 Inner Geek. All rights reserved.
//

import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    @IBOutlet weak var navigationController: UINavigationController?
    @IBOutlet weak var pingTransitionAnimator: PingTransitionAnimator!
    
    var interactionController: CALayerPercentDrivenInteractiveTransition?
    
    var shouldCompleteTransition: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        var panGesture = UIPanGestureRecognizer(target: self, action: Selector("panned:"))
        self.navigationController!.view.addGestureRecognizer(panGesture)
    }
  
    @IBAction func panned(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            var location = gestureRecognizer.locationInView(gestureRecognizer.view)
            var fromViewController = self.navigationController?.topViewController
            
            if !fromViewController!.conformsToProtocol(PingTransitionAnimatorProtocol) {
                NSLog("fromViewController does not conform to <%@>", NSStringFromProtocol(PingTransitionAnimatorProtocol))
            }
            
            var initialRect = (fromViewController as PingTransitionAnimatorProtocol).initialRectForPingTransition()
            if CGRectContainsPoint(CGRectInset(initialRect, -30, -30), location) {
                self.interactionController = CALayerPercentDrivenInteractiveTransition()
                if self.navigationController?.viewControllers.count > 1 {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {
                    self.navigationController?.topViewController.performSegueWithIdentifier("PushSegue", sender: nil)
                }
            }
        case .Changed:
            var translation = gestureRecognizer.translationInView(self.navigationController!.view)
            var completionProgress = translation.y / CGRectGetHeight(self.navigationController!.view.bounds)
            shouldCompleteTransition = completionProgress > 0.20
            self.interactionController?.updateInteractiveTransition((completionProgress < 0) ? 0 : completionProgress)
        case .Ended:
            if (gestureRecognizer.velocityInView(self.navigationController!.view).y > 0 && shouldCompleteTransition) {
                self.interactionController?.finishInteractiveTransition()
            }
            else {
                self.interactionController?.cancelInteractiveTransition()
            }
            self.interactionController = nil
        default:
            self.interactionController?.cancelInteractiveTransition()
            self.interactionController = nil
        }
    }
  
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation:    UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) ->   UIViewControllerAnimatedTransitioning? {
        if fromVC is PingTransitionAnimatorDelegate {
            self.pingTransitionAnimator.delegate = fromVC as? PingTransitionAnimatorDelegate
        }
        
        if toVC is PingTransitionAnimatorDelegate {
            self.pingTransitionAnimator.delegate = toVC as? PingTransitionAnimatorDelegate
        }

        return self.pingTransitionAnimator
    }

    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController   animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
}
