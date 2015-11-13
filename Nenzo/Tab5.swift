//
//  Tab5.swift
//  Nenzo
//
//  Created by sloot on 5/27/15.
//
//

import UIKit

let EDIT_CELL_HEIGHT:CGFloat = 47.0

class Tab5: UIView {
    
    @IBOutlet var bgImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var editUserNameLabel: UILabel!
    
    @IBOutlet var editPhoneNumberLabel: UILabel!
    
    @IBOutlet var newUsernameTextField: UITextField!
    
    @IBOutlet var newPasswordTextField: UITextField!
    
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    @IBOutlet var countryCodeTextField: UITextField!
    
    @IBOutlet var dateTextField: UIDateTextField!
    
    @IBOutlet var countryNameLabel: UILabel!
    
    @IBOutlet var countryCodeLabel: UILabel!
    
    @IBOutlet var editGenderLabel: UILabel!
    
    @IBOutlet var editBirthdateLabel: UILabel!
    
    @IBOutlet var genderTextField: UITextField!
    
    @IBOutlet var verticalScrollView: UIScrollView!
    
    @IBOutlet var horizontalScrollView: UIScrollView!
    
    @IBOutlet var whiteMenuButton: UIButton!
    
    @IBOutlet var blackMenuButton: UIButton!
    
    weak var datePicker:UIDatePicker?
    weak var genderPicker:UIPickerView?
    
    weak var datePickerTool:PickerToolView?
    weak var genderPickerTool:PickerToolView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let picker = UIPickerView(frame: CGRectMake(0, 50, 100, 150))
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        countryCodeTextField.inputView = picker
        let tool = countryCodeTextField.addToolView(self)
        tool.backButton.hidden = true
        tool.nextButton.hidden = true
        var gp = UIPickerView()
        genderTextField.inputView = gp
        genderPicker = gp
        gp.delegate = self
        gp.dataSource = self
        genderPickerTool = genderTextField.addToolView(self)
        genderPickerTool!.doneButton.setTitle("Save", forState: .Normal)
        genderPickerTool!.backButton.hidden = false
        genderPickerTool!.nextEnabled = false
        
        datePicker = dateTextField.addDatePicker()
        datePickerTool = dateTextField.addToolView(self)
        datePickerTool!.doneButton.setTitle("Save", forState: .Normal)
        datePickerTool!.backButton.hidden = false
        datePickerTool!.nextEnabled = false
    }
    
    @IBOutlet var accountSectionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var profileHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var usernameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var passwordHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var phonenumberHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var privacySectionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var genderHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var birthdayHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var helpSectionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var friendsHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var policyHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var conditionsHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var logoutHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var settingsContentViewHeightConstraint: NSLayoutConstraint!
    
    var circularImage:UIImage?
    
    var bgImage:UIImage?
    
    var newUsername:String?
    
    var newPassword:String?
    
    var internationalCode:String = "+1"
    
    var newGender:String?
    
    var newDate:NSDate?
    
    var usernameExpanded:Bool = false {
        didSet {
            usernameHeightConstraint.constant = usernameExpanded ? EDIT_CELL_HEIGHT * 3 + 2.0 : EDIT_CELL_HEIGHT
        }
    }
    
    var passwordExpanded:Bool = false {
        didSet {
            passwordHeightConstraint.constant = passwordExpanded ? EDIT_CELL_HEIGHT * 3 + 2.0 : EDIT_CELL_HEIGHT
        }
    }
    
    var phoneNumberExpanded:Bool = false {
        didSet {
            phonenumberHeightConstraint.constant = phoneNumberExpanded ? EDIT_CELL_HEIGHT * 3 + 2.0 : EDIT_CELL_HEIGHT
        }
    }
    
    var genderExpanded:Bool = false {
        didSet {
            genderHeightConstraint.constant = genderExpanded ? EDIT_CELL_HEIGHT * 3 + 2.0 : EDIT_CELL_HEIGHT
        }
    }
    
    var birthdayExpanded:Bool = false {
        didSet {
            birthdayHeightConstraint.constant = birthdayExpanded ? EDIT_CELL_HEIGHT * 3 + 2.0 : EDIT_CELL_HEIGHT
        }
    }
    
    @IBAction func menuButtonPressed(sender: UIButton) {
        horizontalScrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    @IBAction func backMenuButtonPressed(sender: UIButton) {
        horizontalScrollView.setContentOffset(CGPointMake(horizontalScrollView.contentSize.width/2.0, 0), animated: true)
    }
    
    func loadProfile(){
        if let name = NSUserDefaults.standardUserDefaults().objectForKey("name") as? String {
            nameLabel.text = name
        }
        if let username = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String {
            usernameLabel.text = username
            editUserNameLabel.text = username
        }
        let genderIndex = NSUserDefaults.standardUserDefaults().integerForKey("gender")
        if genderIndex < GENDERS.count && genderIndex >= 0 {
            editGenderLabel.text = GENDERS[genderIndex]
        }
        if let phone_number = NSUserDefaults.standardUserDefaults().objectForKey("phone_number") as? String, let country_code = NSUserDefaults.standardUserDefaults().objectForKey("country_code") as? String {
            editPhoneNumberLabel.text = "+" + country_code + " " + phone_number
            countryCodeLabel.text = "+" + country_code
        }
        let birthdate = NSUserDefaults.standardUserDefaults().integerForKey("birthdate")
        if birthdate > 0 {
            let date:NSDate = NSDate(timeIntervalSince1970: NSTimeInterval(birthdate))
            let formatter:NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            editBirthdateLabel.text = formatter.stringFromDate(date)
        }
    }
    
    func loadBGImage(){
        if let photo_url = NSUserDefaults.standardUserDefaults().objectForKey("bg_photo") as? String {
            bgImageView.smartLoad(photo_url)
        }
    }
    
    @IBAction func changeProfilePicturePressed(sender: UIButton) {
        Tool.sharedInstance.myViewController!.showCameraView(self, type: .Profile)
    }
 
    @IBAction func usernameEditPressed(sender: UIButton) {
        let wasExpanded = usernameExpanded
        collapseAll()
        if !wasExpanded {
            usernameExpanded = true
        }
        redoScrollViewHeight()
    }
    
    @IBAction func passwordEditPressed(sender: UIButton) {
        let wasExpanded = passwordExpanded
        collapseAll()
        if !wasExpanded {
            passwordExpanded = true
        }
        redoScrollViewHeight()
    }
    
    @IBAction func phoneNumberEditPressed(sender: UIButton) {
        let wasExpanded = phoneNumberExpanded
        collapseAll()
        if !wasExpanded {
            phoneNumberExpanded = true
        }
        redoScrollViewHeight()
    }
    
    @IBAction func genderEditPressed(sender: UIButton) {
        let wasExpanded = genderExpanded
        collapseAll()
        if !wasExpanded {
            genderExpanded = true
        }
        redoScrollViewHeight()
    }
    
    @IBAction func birthdayEditPressed(sender: UIButton) {
        let wasExpanded = birthdayExpanded
        collapseAll()
        if !wasExpanded {
            birthdayExpanded = true
        }
        redoScrollViewHeight()
    }
    
    @IBAction func selectCountryCodePressed(sender: UIButton) {
        countryCodeTextField.becomeFirstResponder()
    }
    
    @IBAction func friendsButtonPressed(sender: UIButton) {
    }
    
    @IBAction func privacyPolicyButtonPressed(sender: UIButton) {
    }
    
    @IBAction func termsConditionButtonPressed(sender: UIButton) {
    }
    
    @IBAction func logoutPressed(sender: UIButton) {
        sender.enabled = false
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "nenzo_cookie")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "searches")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "name")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "username")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "bg_photo")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "gender")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "phone_number")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "country_code")
        NSUserDefaults.standardUserDefaults().setObject(0, forKey: "birthdate")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "bg_photo")
        NSUserDefaults.standardUserDefaults().synchronize()
        CoreDataTool.sharedInstance.clearCookies()
        if let masterVC:MainViewController = Tool.sharedInstance.myViewController {
            masterVC.resetUp()
        }
    }
    
    func endAllEditing(){
        newUsernameTextField.resignFirstResponder()
        newPasswordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
    }
    
    func collapseAll(){
        if usernameExpanded {
            usernameExpanded = false
        }
        if passwordExpanded {
            passwordExpanded = false
        }
        if phoneNumberExpanded {
            phoneNumberExpanded = false
        }
        if genderExpanded {
            genderExpanded = false
        }
        if birthdayExpanded {
            birthdayExpanded = false
        }
    }
    
    func redoScrollViewHeight(){
        let totalHeight = accountSectionHeightConstraint.constant + profileHeightConstraint.constant + usernameHeightConstraint.constant + passwordHeightConstraint.constant + phonenumberHeightConstraint.constant + privacySectionHeightConstraint.constant + genderHeightConstraint.constant + birthdayHeightConstraint.constant + helpSectionHeightConstraint.constant + friendsHeightConstraint.constant + policyHeightConstraint.constant + conditionsHeightConstraint.constant + logoutHeightConstraint.constant + 12.0
        settingsContentViewHeightConstraint.constant = totalHeight
    }
    
    func update(completion:(success:Bool)-> Void){
        var input:[MultiPartFormObject] = []
        if let newCircularImage = circularImage {
            let imgData:NSData = UIImagePNGRepresentation(newCircularImage)
            var newImg:MultiPartFormObject = MultiPartFormObject(containsImage: true, data: imgData, key: "user[profile_photo]")
            input.append(newImg)
            
            circularImage = nil
        }
        if let newFullImage = bgImage {
            let imgData:NSData = UIImagePNGRepresentation(newFullImage)
            var newImg:MultiPartFormObject = MultiPartFormObject(containsImage: true, data: imgData, key: "user[bg_photo]")
            input.append(newImg)
            bgImage = nil
        }
        if let username = newUsername where count(username) > 0 {
            var mPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: username, key: "user[username]")
            input.append(mPObj)
            newUsername = nil
        }
        if let password = newPassword where count(password) > 0 {
            var mPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: password, key: "user[password]")
            input.append(mPObj)
            newPassword = nil
        }
        if let gender = newGender where count(gender) > 0 {
            var mPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: gender, key: "user[gender]")
            input.append(mPObj)
            newGender = nil
        }
        if let date = dateTextField.date {
            var birthMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: "\(date.timeIntervalSince1970)", key: "user[birthdate]")
            input.append(birthMPObj)
        }
        if input.count > 0 {
            Tool.callMPREST(input, path: "users.json", method: "PUT", completionHandler: { (json) -> Void in
                if let myJson = json, status = myJson["status"] as? String {
                    if status == "error" {
                        self.showError("Error")
                        completion(success: false)
                    } else {
                        saveUserInfo(myJson)
                        completion(success: true)
                        println("gucci")
                    }
                } else {
                    completion(success: false)
                    self.showError("Internet Error")
                }
                }, errorHandler: nil)
        }
    }
}

extension Tab5 : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case newUsernameTextField:
            textField.resignFirstResponder()
            usernameExpanded = false
            newUsername = textField.text
            let new = textField.text
            let old = usernameLabel.text ?? ""
            usernameLabel.text = new
            editUserNameLabel.text = new
            newUsernameTextField.text = ""
            update(){ (success) -> Void in
                if success {
                    NSUserDefaults.standardUserDefaults().setObject(new, forKey: "username")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.showSuccess("Username update successful")
                } else {
                    self.usernameLabel.text = old
                    self.editUserNameLabel.text = old
                    textField.text = new
                }
            }
        case newPasswordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            if confirmPasswordTextField.text == newPasswordTextField.text {
                textField.resignFirstResponder()
                passwordExpanded = false
                newPassword = textField.text
                update(){ (success) -> Void in
                    if success {
                        self.showSuccess("Password update successful")
                    } else {
                        
                    }
                }
            } else {
                newPasswordTextField.text = ""
                confirmPasswordTextField.text = ""
                newPasswordTextField.becomeFirstResponder()
                showError("Passwords do not match")
            }
            newPasswordTextField.text = ""
            confirmPasswordTextField.text = ""
        default:
            break
        }
        return true
    }
}

extension Tab5 : PickerToolViewDelegate {
    func pickerPressedBack(ptv:PickerToolView) {
        if (ptv == datePickerTool) {
            dateTextField.resignFirstResponder()
        } else if (ptv == genderPickerTool) {
            genderTextField.resignFirstResponder()
        }
    }
    
    func pickerPressedNext(ptv:PickerToolView) {
    }
    
    func pickerPressedDone(ptv:PickerToolView) {
        if (ptv == datePickerTool) {
            setBirthDate()
            dateTextField.resignFirstResponder()
        } else if (ptv == genderPickerTool) {
            setGender()
            genderTextField.resignFirstResponder()
        } else {
            countryCodeTextField.resignFirstResponder()
        }
    }
    
    func setGender(){
        if let gp = genderPicker {
            genderExpanded = false
            let selectedGender = gp.selectedRowInComponent(0)
            let nGender = GENDERS[selectedGender]
            let oldGender = editGenderLabel.text ?? "Male"
            genderTextField.text = ""
            editGenderLabel.text = nGender
            newGender = String(selectedGender)
            update(){ (success) -> Void in
                if success {
                    self.showSuccess("Gender update successful")
                } else {
                    self.genderTextField.text = nGender
                    self.editGenderLabel.text = oldGender
                }
            }
        }
    }
    
    func setBirthDate(){
        birthdayExpanded = false
        let oldDateString = editBirthdateLabel.text ?? ""
        dateTextField.setTextFromDatePicker(datePicker)
        let newDateString = dateTextField.text
        editBirthdateLabel.text = newDateString
        dateTextField.text = ""
        newDate = dateTextField.date
        update(){ (success) -> Void in
            if success {
                self.showSuccess("Birthdate update successful")
            } else {
                self.editBirthdateLabel.text = oldDateString
            }
        }
    }
}

extension Tab5 : UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genderPicker {
            return GENDERS.count
        } else {
            return prefixCodes.keys.array.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPicker {
            if let gp = genderPicker {
                genderTextField.text = GENDERS[gp.selectedRowInComponent(0)]
            }
        } else {
            let key = prefixArray[row]
            let value = prefixCodes[key] ?? ""
            countryNameLabel.text = key
            countryCodeLabel.text = "+" + value
            internationalCode = value
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        if pickerView == genderPicker {
            if let cv = "CountryView".loadNib() as? CountryView {
                cv.frame = CGRectMake(0, 0, pickerView.frame.width, 80)
                cv.centerLabel.text = GENDERS[row]
                cv.centerLabel.hidden = false
                cv.leftTextLabel.text = ""
                cv.rightTextLabel.text = ""
                return cv
            } else {
                return UIView()
            }
        } else {
            let key = prefixArray[row]
            let value = prefixCodes[key] ?? ""
            if let cv = "CountryView".loadNib() as? CountryView {
                cv.frame = CGRectMake(0, 0, pickerView.frame.width, 80)
                cv.centerLabel.text = ""
                cv.centerLabel.hidden = true
                cv.leftTextLabel.text = key
                cv.rightTextLabel.text = "+" + value
                return cv
            } else {
                return UIView()
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension Tab5 : CameraViewDelegate {
    func didSelectCircularImage(img: UIImage, wholeImg: UIImage) {
        circularImage = img
        let oldImage = bgImageView.image
        bgImageView.image = wholeImg
        bgImage = wholeImg
        let bg_url = NSUserDefaults.standardUserDefaults().objectForKey("bg_photo") as? String ?? "temp"
        smartSet(wholeImg, bg_url)
        update(){ (success) -> Void in
            if success {
                let bg_url = NSUserDefaults.standardUserDefaults().objectForKey("bg_photo") as? String ?? "temp"
                smartSet(wholeImg, bg_url)
                self.showSuccess("Profile picture update successful")
            } else {
                self.showError("Profile picture update unsuccesstul")
                self.bgImageView.image = oldImage
            }
        }
    }
    func didSelectImage(img: UIImage) {
        println("ERROR: Tab5 Recieved image")
    }
    
    func didSelectVideo(videourl: NSURL, img: UIImage) {
        println("ERROR: Tab5 Recieved video")
    }
}

extension Tab5: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == horizontalScrollView {
            if scrollView.contentOffset.x > scrollView.contentSize.width/4.0 {
                blackMenuButton.hidden = true
                whiteMenuButton.hidden = false
            } else {
                blackMenuButton.hidden = false
                whiteMenuButton.hidden = true
            }
            if scrollView.contentOffset.x > 20.0 {
                endAllEditing()
            }
        }
    }
}

extension Tab5: TabDelegate {
    func showSlide() {
        loadBGImage()
        loadProfile()
        horizontalScrollView.setContentOffset(CGPointMake(horizontalScrollView.contentSize.width/2.0, 0), animated: false)
        redoScrollViewHeight()
    }
    func removeSlide() {
    }
}