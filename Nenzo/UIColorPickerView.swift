//
//  UIColorPickerView.swift
//  Nenzo
//
//  Created by sloot on 6/7/15.
//
//

import UIKit

class UIColorPickerView: UIView {

    var dot:UIView?
    
    var expandedFrame:CGRect!
    var unexpandedFrame:CGRect!
    
    func setup(newFrame:CGRect){
        if let myDot = viewWithTag(-1) {
            dot = myDot
            expandedFrame = CGRect(origin: frame.origin, size: frame.size)
            unexpandedFrame = newFrame
            dot!.layer.cornerRadius = dot!.frame.width/2.0
            dot!.clipsToBounds = true
            frame = unexpandedFrame
        }
    }
    
    func dotColor() -> UIColor? {
        if let myDot = dot {
            return myDot.backgroundColor
        } else {
            return nil
        }
    }

    func expand(){
        frame = expandedFrame
        alpha = 1.0
    }
    
    func unexpand(){
        frame = unexpandedFrame
        alpha = 0.0
    }
}
