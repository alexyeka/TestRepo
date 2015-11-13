//
//  SignUpPreviewView.swift
//  Nenzo
//
//  Created by sloot on 5/29/15.
//
//

import UIKit

@objc(SignUpPreviewViewDelegate)
protocol SignUpPreviewViewDelegate{
    func cancelSignUpPreviewPressed()
    func finishSignUpPreviewPressed()
}
class SignUpPreviewView: UISlideView {
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var myImageButton: UIButton!
    
    @IBOutlet var backGroundImageView: UIImageView!
    
    @IBOutlet var bioTextField: UITextField!
    
    @IBOutlet var dateTextField: UIDateTextField!
    
    @IBOutlet var genderTextField: UITextField!
    
    @IBOutlet var containerView: UIView!
    
    weak var delegate:SignUpPreviewViewDelegate!
    
    var params:NSMutableDictionary!
    
    var hasBlurBG:Bool = false
    
    var focusedTextField:UITextField?
    
    var selectedGender:Int = 0
    
    var circularImage:UIImage?
    
    var bgImage:UIImage?
    
    @IBAction func backPressed(sender: AnyObject) {
        delegate.cancelSignUpPreviewPressed()
    }
    
    @IBAction func finishPressed(sender: AnyObject) {
        if count(dateTextField.text) == 0 {
            showError("Enter date of birth")
        } else if count(genderTextField.text) == 0 {
            showError("Enter gender")
        } else {
            updateUser()
        }
    }
    
    @IBAction func chooseImagePressed(sender: AnyObject) {
        Tool.sharedInstance.myViewController!.showCameraView(self, type: .Profile)
    }
    
    var originalContainerFrame:CGRect!
    var highContainerFrame:CGRect!
    
    func setup(){
        nameLabel.text = (params!["user"] as! NSDictionary)["name"] as? String
        usernameLabel.text = (params!["user"] as! NSDictionary)["username"] as? String
        let bioPlaceHolder = NSAttributedString(string: "Bio", attributes: [NSForegroundColorAttributeName:UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)])
        bioTextField.attributedPlaceholder = bioPlaceHolder
        datePicker = dateTextField.addDatePicker()
        datePickerTool = dateTextField.addToolView(self)
        showGenderPicker()
        let datePlaceHolder = NSAttributedString(string: "Date of Birth", attributes: [NSForegroundColorAttributeName:UIColor(red: 1, green: 1, blue: 1, alpha: 1)])
        dateTextField.attributedPlaceholder = datePlaceHolder
        let genderPlaceHolder = NSAttributedString(string: "Gender", attributes: [NSForegroundColorAttributeName:UIColor(red: 1, green: 1, blue: 1, alpha: 1)])
        genderTextField.attributedPlaceholder = genderPlaceHolder
        originalContainerFrame = containerView.frame
        highContainerFrame = CGRectMake(originalContainerFrame.origin.x, originalContainerFrame.origin.y - 125.0, originalContainerFrame.width, originalContainerFrame.height)
    }
    
    weak var datePicker:UIDatePicker?
    weak var genderPicker:UIPickerView?
    
    weak var datePickerTool:PickerToolView?
    weak var genderPickerTool:PickerToolView?
    
    func showGenderPicker(){
        var gp = UIPickerView()
        genderTextField.inputView = gp
        genderPicker = gp
        gp.delegate = self
        gp.dataSource = self
        genderPickerTool = genderTextField.addToolView(self)
        genderPickerTool!.nextEnabled = false
    }
}

extension SignUpPreviewView:CameraViewDelegate {
    func didSelectCircularImage(img: UIImage, wholeImg: UIImage) {
        myImageButton.setImage(img, forState: .Normal)
        circularImage = img
        backGroundImageView.image = wholeImg
        bgImage = wholeImg
        if !hasBlurBG {
            hasBlurBG = true
        }
    }
    
    func didSelectImage(img: UIImage) {
        println("Not supported")
    }
    
    func didSelectVideo(videourl: NSURL, img: UIImage) {
        println("Not supported")
    }
}

extension SignUpPreviewView:UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == bioTextField) {
            dateTextField.becomeFirstResponder()
            return false
        } else {
            textField.resignFirstResponder()
            return true
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        focusedTextField = textField
        raiseContainer()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if focusedTextField == textField {
            lowerContainer()
        }
    }
    
    func raiseContainer(){
        containerView.layer.removeAllAnimations()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.containerView.frame = self.highContainerFrame
            self.myImageButton.alpha = 0
        })
    }
    
    func lowerContainer(){
        containerView.layer.removeAllAnimations()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.containerView.frame = self.originalContainerFrame
            self.myImageButton.alpha = 1
        })
    }
}

extension SignUpPreviewView:PickerToolViewDelegate {
    func pickerPressedBack(ptv: PickerToolView) {
        if (ptv == datePickerTool) {
            dateTextField.setTextFromDatePicker(datePicker)
            bioTextField.becomeFirstResponder()
        } else if (ptv == genderPickerTool) {
            setGender()
            dateTextField.becomeFirstResponder()
        }
    }
    
    func pickerPressedNext(ptv: PickerToolView) {
        if (ptv == datePickerTool) {
            dateTextField.setTextFromDatePicker(datePicker)
            genderTextField.becomeFirstResponder()
        }
    }
    
    func pickerPressedDone(ptv: PickerToolView) {
        if (ptv == datePickerTool) {
            dateTextField.setTextFromDatePicker(datePicker)
            dateTextField.resignFirstResponder()
        } else if (ptv == genderPickerTool) {
            setGender()
            genderTextField.resignFirstResponder()
        }
    }
    
    func setGender(){
        if let gp = genderPicker {
            selectedGender = gp.selectedRowInComponent(0)
            genderTextField.text = GENDERS[gp.selectedRowInComponent(0)]
            if gp.selectedRowInComponent(0) == 2 {
                genderTextField.text = " "
            }
        }
    }
}

let GENDERS:[String] = ["Male", "Female", "I prefer not to answer"]
extension SignUpPreviewView:UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GENDERS.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return GENDERS[row]
    }
}

extension SignUpPreviewView {
    func updateUser(){
        if !networkLock {
            showLoading()
            var input:[MultiPartFormObject] = []
            if let newCircularImage = circularImage {
                let imgData:NSData = UIImagePNGRepresentation(newCircularImage)
                var newImg:MultiPartFormObject = MultiPartFormObject(containsImage: true, data: imgData, key: "user[profile_photo]")
                input.append(newImg)
            }
            if let newFullImage = bgImage {
                let imgData:NSData = UIImagePNGRepresentation(newFullImage)
                var newImg:MultiPartFormObject = MultiPartFormObject(containsImage: true, data: imgData, key: "user[bg_photo]")
                input.append(newImg)
            }
            var genderMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: "\(selectedGender)", key: "user[gender]")
            input.append(genderMPObj)
            if let date = dateTextField.date {
                var birthMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: "\(date.timeIntervalSince1970)", key: "user[birthdate]")
                input.append(birthMPObj)
            }
            if count(bioTextField.text) > 0 {
                var bioMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: bioTextField.text, key: "user[bio]")
                input.append(bioMPObj)
            }
            
            Tool.callMPREST(input, path: "users.json", method: "PUT", completionHandler: { (json) -> Void in
                if let myJson = json, status = myJson["status"] as? String {
                    if status == "error" {
                        self.showError("Error")
                    } else {
                        saveUserInfo(myJson)
                        self.delegate.finishSignUpPreviewPressed()
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

class MultiPartFormObject: NSObject {
    var containsImage:Bool = false
    var data:AnyObject!
    var key:String!
    
    init(containsImage : Bool, data: AnyObject, key:String) {
        self.containsImage = containsImage
        self.data = data
        self.key = key
    }
}