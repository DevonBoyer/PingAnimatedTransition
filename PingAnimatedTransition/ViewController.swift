//
//  ViewController.swift
//  PingAnimatedTransition
//
//  Created by Devon Boyer on 2014-12-03.
//  Copyright (c) 2014 Inner Geek. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PingTransitionAnimatorProtocol, PingTransitionAnimatorDelegate {

    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func circleTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func initialRectForPingTransition() -> CGRect {
        return button.frame
    }
    
    func pingTransitionDidBegin() {
        println("pingTransitionDidBegin")
        
        button.transform = CGAffineTransformMakeScale(0.0, 0.0)
    }
    
    func pingTransitionDidFinish() {
        println("pingTransitionDidFinish")
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.button.transform = CGAffineTransformIdentity
        })
    }
    
    func pingTransitionDidCancel() {
        println("pingTransitionDidCancel")
        
        button.transform = CGAffineTransformIdentity
    }

}

