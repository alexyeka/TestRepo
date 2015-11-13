//
//  BackgroundView.swift
//  Nenzo
//
//  Created by sloot on 5/30/15.
//
//

import UIKit

let mySpeed = 70.0

class BackgroundView: UIView {
    
    var shouldAnimate = true;
    
    @IBOutlet var myBackground: UIImageView!
    
    @IBOutlet var ownBGImageView: UIImageView!
    
    @IBOutlet var darkOverlayView: UIView!
    
    func setup(){
        recordFrames()
        startAnimations()
    }
    
    var leftFrame:CGRect!
    var rightFrame:CGRect!
    var middleFrame:CGRect!
    
    func recordFrames(){
        let bgWidth = myBackground.frame.width
        let bgHeight = myBackground.frame.height
        let screenWidth = frame.width
        let screenHeight = frame.width
        middleFrame = myBackground.frame
        leftFrame = CGRectMake(myBackground.frame.origin.x - 2.0 + (bgWidth - screenWidth)/2.0 , myBackground.frame.origin.y, bgWidth, bgHeight)
        rightFrame = CGRectMake(myBackground.frame.origin.x + 2.0 - (bgWidth - screenWidth)/2.0 , myBackground.frame.origin.y, bgWidth, bgHeight)
    }
    
    func startAnimations(){
        moveLeft(mySpeed/2.0)
    }
    
    func moveLeft(speed:NSTimeInterval){
        UIView.animateWithDuration(speed, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.myBackground.frame = self.leftFrame
            }) { (done) -> Void in
                self.moveRight(mySpeed)
        }
    }
    
    func moveRight(speed:NSTimeInterval){
        UIView.animateWithDuration(speed, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.myBackground.frame = self.rightFrame
            }) { (done) -> Void in
                self.moveLeft(mySpeed)
        }
    }
}
