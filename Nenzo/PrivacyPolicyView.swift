//
//  PrivacyPolicyView.swift
//  Nenzo
//
//  Created by sloot on 6/3/15.
//
//

import UIKit

class PrivacyPolicyView: UISlideView {
    
    @IBOutlet var backBlurView: UIView!
    
    var effectView:UIVisualEffectView!
    
    func setup(){
        effectView = backBlurView.blur()
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        self.removeFromSuperview()
    }
}

extension UIView {
    func blur() -> UIVisualEffectView{
        var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var effectView = UIVisualEffectView (effect: blur)
        effectView.frame = frame
        addSubview(effectView)
        return effectView
    }
}