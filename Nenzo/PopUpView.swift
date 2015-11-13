//
//  PopUpView.swift
//  Nenzo
//
//  Created by sloot on 6/8/15.
//
//

import UIKit

class PopUpView: UIView {

    @IBOutlet var bodyView: UIView!

    @IBOutlet var messageLabel: UILabel!
    
    @IBOutlet var checkImageView: UIImageView!
    
    @IBOutlet var errorImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bodyView.layer.cornerRadius = 5.0
        bodyView.clipsToBounds = true
    }
    
    func registerTapListener(){
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped")
        addGestureRecognizer(tap)
    }
    
    func viewTapped(){
        UIView.animateWithDuration(removeSpeed, animations: { () -> Void in
            self.alpha = 0.0
            }) { (done) -> Void in
                self.removeFromSuperview()
        }
    }
}

let presentSpeed:NSTimeInterval = 0.3
let removeSpeed:NSTimeInterval = 0.15

extension UIView {
    func showError(message:String){
        var popUpView:PopUpView = "PopUpView".loadNib() as! PopUpView
        popUpView.messageLabel.text = message
        popUpView.frame = frame
        popUpView.alpha = 0.0
        addSubview(popUpView)
        UIView.animateWithDuration(presentSpeed, animations: { () -> Void in
            popUpView.alpha = 1.0
        }) { (done) -> Void in
            popUpView.registerTapListener()
        }
    }
    
    func showSuccess(message:String){
        var popUpView:PopUpView = "PopUpView".loadNib() as! PopUpView
        popUpView.errorImageView.hidden = true
        popUpView.checkImageView.hidden = false
        popUpView.messageLabel.text = message
        popUpView.frame = frame
        popUpView.alpha = 0.0
        addSubview(popUpView)
        UIView.animateWithDuration(presentSpeed, animations: { () -> Void in
            popUpView.alpha = 1.0
            }) { (done) -> Void in
                popUpView.registerTapListener()
        }
    }
}
