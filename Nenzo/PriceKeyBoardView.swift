//
//  PriceKeyBoardView.swift
//  Nenzo
//
//  Created by sloot on 6/11/15.
//
//

import UIKit

let PRICEKBHEIGHT:CGFloat = 215.0;
class PriceKeyBoardView: UIView {

    @IBOutlet var myContainerView: UIView!
    
    weak var myTextField:UIPriceTextField?
    
    @IBOutlet weak var decimalButton: UIHighlightButton!
    
//    class func showFrame() -> CGRect {
//        var kbf = hideFrame()
//        return CGRectMake(kbf.origin.x, kbf.origin.y - kbf.height, kbf.width, kbf.height)
//    }
    
    class func hideFrame() -> CGRect {
        var kbf = keyBoardFrame()
        return CGRectMake(kbf.origin.x, kbf.origin.y, kbf.width, PRICEKBHEIGHT)
    }
//    func show(){
//        getMainWindowView().addSubview(self)
//        UIView.animateWithDuration(keyBoardSpeed(), animations: { () -> Void in
//            self.frame = PriceKeyBoardView.showFrame()
//        })
//    }
//    
//    func hide(){
//        UIView.animateWithDuration(keyBoardSpeed(), animations: { () -> Void in
//            self.frame = PriceKeyBoardView.hideFrame()
//        }) { (done) -> Void in
//            self.removeFromSuperview()
//        }
//    }
    
    func addBorders(){
        for subview in myContainerView.subviews {
            if let hlbutton = subview as? UIHighlightButton {
                hlbutton.addBorder()
            }
        }
    }
    
    func priceChanged(text:String){
        if let tf = myTextField, dgt = tf.priceDelegate, dgtPriceChanged = dgt.priceDidChange {
            dgtPriceChanged(text)
        }
    }
    
    @IBAction func keyPressed(sender: UIButton) {
        if let tf = myTextField {
            playClick()
            var range = (tf.text as NSString).rangeOfString(".")
            
            if !tf.hasDecimal || range.length == 0 || count(tf.text) - range.location < 3 {
                if count(tf.value) > 0 || sender.titleLabel!.text! != "0" {
                    tf.value = tf.value + sender.titleLabel!.text!
                }
                if count(tf.text) == 0 {
                    tf.text = "$" + tf.text
                }
                tf.text = tf.text + sender.titleLabel!.text!
                priceChanged(tf.text)
            }
        }
    }
    
    func complete(){
        if let tf = myTextField {
            if count(tf.text) > 0 {
                if !tf.hasDecimal {
                    tf.hasDecimal = true
                    tf.text = tf.text + "."
                }
                var range = (tf.text as NSString).rangeOfString(".")
                while range.length == 0 || count(tf.text) - range.location < 3 {
                    tf.value = tf.value + "0"
                    tf.text = tf.text + "0"
                    range = (tf.text as NSString).rangeOfString(".")
                }
                priceChanged(tf.text)
            }
        }
    }
    @IBAction func decimalPressed(sender: UIButton) {
        if let tf = myTextField {
            playClick()
            if !tf.hasDecimal {
                tf.hasDecimal = true
                tf.text = tf.text + "."
            }
            priceChanged(tf.text)
        }
    }
    @IBAction func backPressed(sender: UIButton) {
        if let tf = myTextField {
            playClick()
            if count(tf.text) > 0 {
                let last = (tf.text as NSString).substringFromIndex(count(tf.text) - 1)
                if last == "." {
                    tf.hasDecimal = false
                } else if count(tf.value) > 0 {
                    tf.value = (tf.value as NSString).substringToIndex(count(tf.value) - 1)
                }
                tf.text = (tf.text as NSString).substringToIndex(count(tf.text) - 1)
                if tf.text == "$" {
                    tf.text = ""
                }
                priceChanged(tf.text)
            }
        }
    }
}

extension PriceKeyBoardView :UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if let tf = textField as? UIPriceTextField {
            tf.stylePlaceHolder("$0.00")
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let tf = textField as? UIPriceTextField {
            complete()
            tf.stylePlaceHolder(tf.initialPlaceHolder)
        }
    }
}

extension PriceKeyBoardView : UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool {
        get {
            return true
        }
    }
    
    func playClick(){
        UIDevice.currentDevice().playInputClick()
    }
}
@objc(UIPriceTextFieldDelegate)
protocol UIPriceTextFieldDelegate{
    optional func priceDidChange(text:String)
}
class UIPriceTextField:UITextField {
    weak var priceDelegate:UIPriceTextFieldDelegate?
    
    var keyBoardView:PriceKeyBoardView!
    
    var value:String = ""
    
    var hasDecimal:Bool = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        keyBoardView = addPriceKeyBoard()
        inputView = keyBoardView
        delegate = keyBoardView
        initialPlaceHolder = placeholder
        value = text
    }
    
    var initialPlaceHolder:String?
    
//    func beginEdit(){
//        keyBoardView.show()
//    }
    
    func addPriceKeyBoard() -> PriceKeyBoardView {
        var newView = "PriceKeyBoardView".loadNib() as! PriceKeyBoardView
        newView.frame = PriceKeyBoardView.hideFrame()
        newView.myTextField = self
        newView.layoutIfNeeded()
        newView.addBorders()
        return newView
    }
    
    override func caretRectForPosition(position: UITextPosition!) -> CGRect {
        return CGRectZero
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        let mc = UIMenuController.sharedMenuController()
        mc.menuVisible = false
        return super.canPerformAction(action, withSender: sender)
    }
    
    func updateDisplay() {
        if count(value) > 0 {
            var output:String = value
            while(count(output) < 3) {
                output = "0" + output
            }
            let front = (output as NSString).substringToIndex(count(output) - 2)
            let end = (output as NSString).substringFromIndex(count(output) - 2)
            text = "$" + front + "." + end
        } else {
            text = ""
        }
    }
}
