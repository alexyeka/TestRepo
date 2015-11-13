//
//  LoadingView.swift
//  Nenzo
//
//  Created by sloot on 7/29/15.
//
//

let FULL_STASCHE_WIDTH:CGFloat = 77.0

import UIKit

class LoadingView: UIView {

    @IBOutlet var displayWidthCosntraint: NSLayoutConstraint!
    
    var isUsed:Bool = false
    
    var isAnimating:Bool = false
    
    func animate() {
        if isUsed && !isAnimating {
            isAnimating = true
            self.displayWidthCosntraint.constant = 0
            self.layoutIfNeeded()
            self.displayWidthCosntraint.constant = FULL_STASCHE_WIDTH
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut , animations: { () -> Void in
                self.layoutIfNeeded()
            }, completion: { (done) -> Void in
                self.isAnimating = false
                self.animate()
            })
        }
    }
}

var loadingView:LoadingView?
func showLoading(){
    removeLoading()
    if let lv = loadingView {
        getMainWindowView().addSubview(lv)
        lv.isUsed = true
        lv.animate()
    } else if let newlv = "LoadingView".loadNib() as? LoadingView {
        loadingView = newlv
        newlv.frame = getMainWindowView().frame
        getMainWindowView().addSubview(newlv)
        newlv.layoutIfNeeded()
        newlv.isUsed = true
        newlv.animate()
    }
}

func removeLoading(){
    if let lv = loadingView {
        lv.isUsed = false
        lv.removeFromSuperview()
    }
}