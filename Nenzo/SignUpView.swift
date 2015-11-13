//
//  SignUpView.swift
//  Nenzo
//
//  Created by sloot on 5/29/15.
//
//

import UIKit
@objc(SignUpViewDelegate)
protocol SignUpViewDelegate{
    func cancelSignUpPressed()
    func continueSignUpPressed(params:NSMutableDictionary)
}
class SignUpView: UISlideView {

    @IBOutlet var phoneNumberTextField: UITextField!
    
    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var phoneNumberLine: UIView!
    
    @IBOutlet var nameLine: UIView!
    
    @IBOutlet var usernameLine: UIView!
    
    @IBOutlet var passwordLine: UIView!
    
    @IBOutlet var phoneError: UIImageView!
    
    @IBOutlet var phoneCheck: UIImageView!
    
    @IBOutlet var nameError: UIImageView!
    
    @IBOutlet var nameCheck: UIImageView!
    
    @IBOutlet var usernameError: UIImageView!
    
    @IBOutlet var usernameCheck: UIImageView!
    
    @IBOutlet var passwordError: UIImageView!
    
    @IBOutlet var passwordCheck: UIImageView!
    
    @IBOutlet var countryPickerTextField: UITextField!
    
    @IBOutlet var countryNameLabel: UILabel!
    
    @IBOutlet var countryCodeLabel: UILabel!
    
    @IBAction func selectCountryPressed(sender: UIButton) {
        countryPickerTextField.becomeFirstResponder()
    }
    
    weak var delegate:SignUpViewDelegate!
    
    @IBAction func backPressed(sender: AnyObject) {
        countryPickerTextField.resignFirstResponder()
        if !networkLock {
            delegate.cancelSignUpPressed()
        }
    }
    @IBAction func continuePressed(sender: AnyObject) {
        signup(prepareParams())
    }
    
    @IBAction func showPolicyPressed(sender: AnyObject) {
        var privacyPolicyView = "PrivacyPolicyView".loadNib() as! PrivacyPolicyView
        privacyPolicyView.frame = frame
        privacyPolicyView.setup()
        addSubview(privacyPolicyView)
    }
    
    var internationalCode:String = "1"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        let picker = UIPickerView(frame: CGRectMake(0, 50, 100, 150))
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        countryPickerTextField.inputView = picker
        let tool = countryPickerTextField.addToolView(self)
        tool.backButton.hidden = true
        tool.nextButton.hidden = true
    }
    
    func setup(){
        if (prefixArray.count == 0) {
            prefixArray = prefixCodes.keys.array.sorted{$0<$1}
            prefixArray.insert("US", atIndex: 0)
            prefixCodes["US"] = "1"
        }
        usernameLine.alpha = 0.6
        passwordLine.alpha = 0.6
        nameLine.alpha = 0.6
        phoneNumberLine.alpha = 0.6
        let usernamePlaceHolder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName:UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)])
        usernameTextField.attributedPlaceholder = usernamePlaceHolder
        let passwordPlaceHolder = NSAttributedString(string: "Create a Password", attributes: [NSForegroundColorAttributeName:UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)])
        passwordTextField.attributedPlaceholder = passwordPlaceHolder
        let phoneNumberPlaceHolder = NSAttributedString(string: "Phone Number", attributes: [NSForegroundColorAttributeName:UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)])
        phoneNumberTextField.attributedPlaceholder = phoneNumberPlaceHolder
        let namePlaceHolder = NSAttributedString(string: "Full Name", attributes: [NSForegroundColorAttributeName:UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)])
        nameTextField.attributedPlaceholder = namePlaceHolder
    }
    
    func prepareParams() -> NSMutableDictionary {
        var params = NSMutableDictionary()
        var userDict = NSMutableDictionary()
        userDict["name"] = nameTextField.text
        userDict["username"] = usernameTextField.text
        userDict["password"] = passwordTextField.text
        userDict["phone_number"] = phoneNumberTextField.text
        userDict["country_code"] = internationalCode
        userDict["full_number"] = internationalCode + phoneNumberTextField.text
        params["user"] = userDict
        return params
    }
}

extension SignUpView : PickerToolViewDelegate {
    func pickerPressedBack(ptv:PickerToolView) {
    
    }
    
    func pickerPressedNext(ptv:PickerToolView) {
    
    }
    
    func pickerPressedDone(ptv:PickerToolView) {
        countryPickerTextField.resignFirstResponder()
    }
}

extension SignUpView: UITextFieldDelegate {

    @IBAction func phoneNumberTextDidChange(sender: UITextField) {
        sender.updateDisplay(phoneNumberLine)
        if count(sender.text) < 4 {
            phoneError.alpha = 1.0
            phoneCheck.alpha = 0.0
        } else {
            phoneError.alpha = 0.0
            phoneCheck.alpha = 1.0
        }
    }
    
    @IBAction func nameTextDidChange(sender: UITextField) {
        sender.updateDisplay(nameLine)
        if count(sender.text) < 4 {
            nameError.alpha = 1.0
            nameCheck.alpha = 0.0
        } else {
            nameError.alpha = 0.0
            nameCheck.alpha = 1.0
        }
    }
    
    @IBAction func usernameTextDidChange(sender: UITextField) {
        sender.updateDisplay(usernameLine)
        if count(sender.text) < 4 {
            usernameError.alpha = 1.0
            usernameCheck.alpha = 0.0
        } else {
            usernameError.alpha = 0.0
            usernameCheck.alpha = 1.0
        }
    }

    @IBAction func passwordTextDidChange(sender: UITextField) {
        sender.updateDisplay(passwordLine)
        if count(sender.text) < 4 {
            passwordError.alpha = 1.0
            passwordCheck.alpha = 0.0
        } else {
            passwordError.alpha = 0.0
            passwordCheck.alpha = 1.0
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case phoneNumberTextField:
            nameTextField.becomeFirstResponder()
        case nameTextField:
            usernameTextField.becomeFirstResponder()
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
} 

extension UITextField {
    func updateDisplay(line:UIView){
        if count(self.text) == 0 {
            line.alpha = 0.6
        } else {
            line.alpha = 1.0
        }
    }
}

extension SignUpView : UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return prefixCodes.keys.array.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let key = prefixArray[row]
        let value = prefixCodes[key] ?? ""
        countryNameLabel.text = key
        countryCodeLabel.text = "+" + value
        internationalCode = value
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let key = prefixArray[row]
        let value = prefixCodes[key] ?? ""
        if let cv = "CountryView".loadNib() as? CountryView {
            cv.frame = CGRectMake(0, 0, pickerView.frame.width, 80)
            cv.leftTextLabel.text = key
            cv.rightTextLabel.text = "+" + value
            return cv
        } else {
            return UIView()
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension SignUpView {
    func signup(inputDict:NSMutableDictionary){
        if !networkLock {
            networkLock = true
            showLoading()
            //        var inputDict = myParams
            //
            //        var userDict = NSMutableDictionary()
            //        userDict["name"] = "😎😎😎😎😎😎😟😚😤😩😩😧"
            //        userDict["username"] = "koroketa"
            //        userDict["password"] = "masasss"
            //        userDict["phone_number"] = "6502817692"
            //
            //        inputDict["user"] = userDict
            Tool.callREST(inputDict, path: "users.json", method: "POST", completionHandler: { (json) -> Void in
                if let myJson = json, status = myJson["status"] as? String {
                    if status == "error" {
                        if let errorArr = myJson["message"] as? [String] where errorArr.count > 0 {
                            for err in errorArr {
                                self.showError(err)
                            }
                        } else if let errMessage = myJson["message"] as? String {
                            self.showError(errMessage)
                        } else {
                            self.showError("Server Error")
                        }
                    } else {
                        if let uuid = myJson["uuid"] as? String {
                            NSUserDefaults.standardUserDefaults().setObject(uuid, forKey: "uuid")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.delegate.continueSignUpPressed(inputDict)
                        } else {
                            self.showError("Server Error")
                        }
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
        }
    }
}

var prefixArray:[String] = []

var prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]