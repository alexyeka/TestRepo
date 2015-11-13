//
//  VarificationView.swift
//  Nenzo
//
//  Created by sloot on 6/1/15.
//
//

import UIKit

@objc(VarificationViewDelegate)
protocol VarificationViewDelegate{
    func cancelVarificationViewPressed()
    func didVerify()
}
class VarificationView: UISlideView {

    weak var delegate:VarificationViewDelegate!
    
    @IBOutlet var hiddenInput: UITextField!
    
    func setup(){
        hiddenInput.becomeFirstResponder()
        textFields.append(textField1)
        textFields.append(textField2)
        textFields.append(textField3)
        textFields.append(textField4)
    }
    
    var textFields:[UITextField] = []
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet var textField1: UITextField!

    @IBOutlet var textField2: UITextField!
    
    @IBOutlet var textField3: UITextField!
    
    @IBOutlet var textField4: UITextField!
    
    @IBAction func hiddenInputDidChange(sender: UITextField) {
        let length = count(sender.text)
        if length < 4 {
            textFields[length].text = ""
            if length > 0 {
                textFields[length].alpha = 0.6
            }
        }
        
        if length > 0 {
            
            textFields[length - 1].text = String(sender.text[length - 1] as Character)
            textFields[length - 1].alpha = 1.0
        }
        if length == 4 {
            if true {
                verify()
            } else {
                
            }
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        if !networkLock{
            delegate.cancelVarificationViewPressed()
        }
    }
    
}

extension VarificationView:UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return count(textField.text + string) < 5
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}

extension VarificationView {
    func verify(){
        if !networkLock {
            if let uuid = NSUserDefaults.standardUserDefaults().objectForKey("uuid") as? String {
            networkLock = true
            showLoading()
                var params = NSMutableDictionary()
                var userDict = NSMutableDictionary()
                userDict["uuid"] = uuid
                userDict["activation_token"] = hiddenInput.text
                params["user"] = userDict
                Tool.callREST(params, path: "users/verify_sms.json", method: "POST", completionHandler: { (json) -> Void in
                    if let myJson = json, status = myJson["status"] as? String {
                        if status == "error" {
                            if let err = myJson["message"] as? String {
                                self.showError(err)
                            } else {
                                self.showError("Server Error")
                            }
                        } else {
                            self.hiddenInput.resignFirstResponder()
                            self.delegate.didVerify()
                        }
                    } else {
                        self.showError("Internet Error")
                    }
                    self.networkLock = false
                    removeLoading()
                    }, errorHandler: { () -> Void in
                    self.networkLock = false
                    removeLoading()
                })
                //            hiddenInput.resignFirstResponder()
                //            delegate.didVerify()
            } else {
                println("somthing crazy wrong")
            }
        }
    }
}