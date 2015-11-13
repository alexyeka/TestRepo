//
//  DetailEnterView.swift
//  Nenzo
//
//  Created by sloot on 6/20/15.
//
//

import UIKit

class DetailEnterView: UISlideView {

    weak var referenceInputField:UITextField?
    
    weak var referenceTextView:UITextView?
    
    weak var tab3:Tab3?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textViewDidChange:", name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    func keyboardShow(notification :NSNotification) {
        let userNotif = notification.userInfo!
        var resizeTextView = (userNotif[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        resizeTextView = myTextView.convertRect(resizeTextView, fromView:nil)
        myTextView.contentInset.bottom = resizeTextView.size.height
        myTextView.scrollIndicatorInsets.bottom = resizeTextView.size.height
    }
    
    func keyboardHide(n:NSNotification) {
        myTextView.contentInset = UIEdgeInsetsZero
        myTextView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    func textViewDidChange(textView: UITextView) {

    }
    
    func setup(ref:UITextField, ref2:UITextView){
        referenceInputField = ref
        referenceTextView = ref2
        myTextView.text = ref2.text
        myTextView.addToolView(self).nextButton.hidden = true
        myTextView.becomeFirstResponder()
    }
    
    @IBOutlet var myTextView: UITextView!

    @IBAction func backPressed(sender: UIButton) {
        finish(nil)
    }
    
    var isFinished:Bool = false
    
    func finish(completionHandler: (() -> Void)?){
        if !isBusy && !isFinished {
            isFinished = true
            if (count(myTextView.text) > 0) {
                tab3!.detailLine.alpha = 1.0
            } else {
                tab3!.detailLine.alpha = 0.6
            }
            slide(SlidePosition.Right)
            tab3!.slide(SlidePosition.Middle){
                if let refTV = self.referenceInputField {
                    refTV.text = self.myTextView.text
                }
                if let refTV = self.referenceTextView{
                    refTV.text = self.myTextView.text
                }
                NSNotificationCenter.defaultCenter().removeObserver(self)
                if let completion = completionHandler {
                    completion()
                }
                self.removeFromSuperview()
            }
        }
    }
}

extension DetailEnterView: PickerToolViewDelegate {
    func pickerPressedBack(ptv: PickerToolView) {
        finish(){
            self.tab3!.feeTextField.becomeFirstResponder()
        }
    }
    
    func pickerPressedNext(ptv: PickerToolView) {

    }
    
    func pickerPressedDone(ptv: PickerToolView) {
        finish(nil)
    }
}