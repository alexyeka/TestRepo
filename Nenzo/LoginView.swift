//
//  LoginView.swift
//  Nenzo
//
//  Created by sloot on 5/28/15.
//
//

import UIKit
@objc(LoginViewDelegate)
protocol LoginViewDelegate{
    func signUpPressed()
    func loginSuccess()
}
class LoginView: UISlideView {
    
    weak var delegate:LoginViewDelegate!
    
    var signUp:Bool = true
    
    @IBOutlet var usernameLine: UIView!
    
    @IBOutlet var passwordLine: UIView!
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var signUpButton: UIButton!
    
    @IBAction func signUpPressed(sender: AnyObject) {
        if signUp {
            delegate.signUpPressed()
        } else {
            login()
            //delegate.loginSuccess()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup(){
        usernameLine.alpha = 0.6
        passwordLine.alpha = 0.6
        let usernamePlaceHolder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName:UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)])
        usernameTextField.attributedPlaceholder = usernamePlaceHolder
        let passwordPlaceHolder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)])
        passwordTextField.attributedPlaceholder = passwordPlaceHolder
    }
    
    func checkLoginSignUp(){
        signUp = count(usernameTextField.text + passwordTextField.text) == 0
        if signUp {
            signUpButton.setTitle("Sign Up", forState: .Normal)
        } else {
            signUpButton.setTitle("Sign In", forState: .Normal)
        }
    }
}

extension LoginView: UITextFieldDelegate {

    @IBAction func usernameTextDidChange(sender: UITextField) {
        sender.updateDisplay(usernameLine)
        checkLoginSignUp()
    }
    
    @IBAction func passwordTextDidChange(sender: UITextField) {
        sender.updateDisplay(passwordLine)
        checkLoginSignUp()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}

//Network
extension LoginView {
    func login(){
        if !networkLock {
            networkLock = true
            showLoading()
            var inputDict = NSMutableDictionary()
            
            var sessionDict = NSMutableDictionary()
            sessionDict["username"] = usernameTextField.text
            sessionDict["password"] = passwordTextField.text
            
            inputDict["session"] = sessionDict
            Tool.callREST(inputDict, path: "login.json", method: "POST", completionHandler: { (json) -> Void in
                if let myJson = json {
                    if let status = myJson["status"] as? String {
                        if status == "error" {
                            self.showError("Wrong username/password")
                        } else {
                            saveUserInfo(myJson)
                            CoreDataTool.sharedInstance.saveCookies()
                            self.delegate.loginSuccess()
                        }
                    } else {
                        self.showError("Server Error")
                    }
                } else {
                    self.showError("No internet")
                }
                removeLoading()
                self.networkLock = false
                }, errorHandler: { () -> Void in
                    self.networkLock = false
                    removeLoading()
            })
        }
    }
}