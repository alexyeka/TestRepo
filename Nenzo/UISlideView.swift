//
//  UISlideView.swift
//  Nenzo
//
//  Created by sloot on 5/29/15.
//
//

import UIKit

class NView:UIView {
    var networkLock:Bool = false
}

class UISlideView: NView {

    var position:SlidePosition = SlidePosition.Middle
    
    var isBusy:Bool = false
    
    var speed:NSTimeInterval = 0.3
    
    func getPreSlideFrame() -> CGRect{
        return CGRect(origin: CGPoint(x: getMainWindowView().frame.origin.x + getMainWindowView().frame.width, y: getMainWindowView().frame.origin.y) , size: getMainWindowView().frame.size)
    }
    
    func slide(pos:SlidePosition){
        slide(pos, completionHandler: nil)
    }
    
    func slide(pos:SlidePosition, completionHandler: (() -> Void)?){
        if !isBusy {
            isBusy = true
            var dist = getMainWindowView().frame.width
            UIView.animateWithDuration(speed, animations: { () -> Void in
                dist = dist * CGFloat(pos.rawValue - self.position.rawValue)
                self.frame = CGRect(origin: CGPoint(x: self.frame.origin.x + dist , y: self.frame.origin.y) , size: self.frame.size)
                }) { (done) -> Void in
                    self.position = pos
                    if let ch = completionHandler {
                        ch()
                    }
                    self.isBusy = false
            }
        }
    }
    
    func place(pos:SlidePosition) {
        if !isBusy {
            var dist = getMainWindowView().frame.width
            dist = dist * CGFloat(pos.rawValue - self.position.rawValue)
            frame = CGRect(origin: CGPoint(x: self.frame.origin.x + dist , y: self.frame.origin.y) , size: self.frame.size)
            position = pos
        }
    }
}

enum SlidePosition:Int{
    case Left = -1,
    Middle = 0,
    Right = 1
}