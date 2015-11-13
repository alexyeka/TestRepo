//
//  Tab3.swift
//  Nenzo
//
//  Created by sloot on 5/27/15.
//
//

import UIKit

var sharedTab3:Tab3?

class Tab3: UISlideView {

    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var dateTimeTextField: UIDateTextField!
    
    @IBOutlet var endDateTimeTextField: UIDateTextField!
    
    @IBOutlet var locationTextField: UITextField!

    @IBOutlet var feeTextField: UIPriceTextField!
    
    @IBOutlet var detailsTextField: UITextField!
    
    @IBOutlet var nameLine: UIView!
    
    @IBOutlet var dateTimeLine: UIView!
    
    @IBOutlet var endDateTimeLine: UIView!
    
    @IBOutlet var locationLine: UIView!
    
    @IBOutlet var feeLine: UIView!
    
    @IBOutlet var detailLine: UIView!
    
    var holderTextView:UITextView = UITextView()
    
    weak var datePicker:UIDatePicker?
    
    weak var endDatePicker:UIDatePicker?
    
    var selectedContacts:[PhoneContact] = []
    
    weak var selectSenderView:SelectSenderView?
    
    weak var eventPreviewView:EventPreviewView?
    
    weak var detailEnterView:DetailEnterView?
    weak var locationPickerView:LocationPickerView?
    
    @IBAction func backPressed(sender: UIButton) {
        goBack()
    }
    
    func goBack(){
        if let masterVC:MainViewController = Tool.sharedInstance.myViewController {
            masterVC.sharedBottom.selectTab(masterVC.previousTab)
        }
    }
    
    @IBAction func nextPressed(sender: UIButton) {
        let senderView = createSenderSelectView()
        senderView.layoutIfNeeded()
        senderView.slide(SlidePosition.Middle){
            senderView.didAppear()
        }
        slide(SlidePosition.Left)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedTab3 = self
        setup()
    }
    
    var dateTimeToolView:PickerToolView!
    var endDateTimeToolView:PickerToolView!
    var nameToolView:PickerToolView!
    var feeToolView:PickerToolView!
    
    func setup(){
        feeLine.alpha = 0.6
        dateTimeLine.alpha = 0.6
        endDateTimeLine.alpha = 0.6
        nameLine.alpha = 0.6
        locationLine.alpha = 0.6
        detailLine.alpha = 0.6
        dateTimeTextField.stylePlaceHolder()
        endDateTimeTextField.stylePlaceHolder()
        locationTextField.stylePlaceHolder()
        feeTextField.stylePlaceHolder()
        nameTextField.stylePlaceHolder()
        detailsTextField.stylePlaceHolder()
        datePicker = dateTimeTextField.addDatePicker(UIDatePickerMode.DateAndTime)
        endDatePicker = endDateTimeTextField.addDatePicker(UIDatePickerMode.DateAndTime)
        position = SlidePosition.Middle
        dateTimeToolView = dateTimeTextField.addToolView(self)
        endDateTimeToolView = endDateTimeTextField.addToolView(self)
        nameToolView = nameTextField.addToolView(self)
        nameToolView.backButton.hidden = true
        feeToolView = feeTextField.addToolView(self)
        feeTextField.priceDelegate = self
        if (prefixArray.count == 0) {
            prefixArray = prefixCodes.keys.array.sorted{$0<$1}
            prefixArray.insert("US", atIndex: 0)
            prefixCodes["US"] = "1"
        }
    }
    
    func createEventPreviewView(){
        var newEventPreviewView = "EventPreviewView".loadNib() as! EventPreviewView
        eventPreviewView = newEventPreviewView
    }
    
    func showEventPreviewView(img:UIImage?, videoURL:NSURL?){
        if let newEventPreviewView = eventPreviewView, date = dateTimeTextField.date, endDate = endDateTimeTextField.date {
            newEventPreviewView.frame = getMainWindowView().frame
            newEventPreviewView.place(SlidePosition.Right)
            newEventPreviewView.alpha = 0.0
            newEventPreviewView.timeLabel.text = dateTimeTextField.getTime()
            newEventPreviewView.locationButton.setTitle(locationTextField.text, forState: .Normal)
            newEventPreviewView.phoneButton.setTitle("777 - 777 - 7777", forState: .Normal)
            newEventPreviewView.feeLabel.text = feeTextField.text
            newEventPreviewView.eventTitleLabel.text = nameTextField.text
            newEventPreviewView.eventDetailTextView.setBody(holderTextView.text)
            newEventPreviewView.monthLabel.text = dateTimeTextField.getMonth()
            newEventPreviewView.dayLabel.text = dateTimeTextField.getDay()
            newEventPreviewView.tab3BottomView.hidden = false
            newEventPreviewView.selectedContacts = selectedContacts
            newEventPreviewView.tab3 = self
            
            var newDetailedEvent:DetailedEvent = DetailedEvent()
            newDetailedEvent.title = nameTextField.text
            newDetailedEvent.start_date = date.timeIntervalSince1970
            newDetailedEvent.end_date = endDate.timeIntervalSince1970
            newDetailedEvent.fee = feeTextField.value
            newDetailedEvent.location = locationTextField.text
            newDetailedEvent.details = holderTextView.text
            newDetailedEvent.cover_image = img
            newEventPreviewView.detailedEvent = newDetailedEvent
            
            Tool.sharedInstance.myViewController!.view.addSubview(newEventPreviewView)
            newEventPreviewView.layoutIfNeeded()
            if let url = videoURL {
                newEventPreviewView.previewVideo(url, urlString: nil)
            } else {
                newEventPreviewView.myImageView.image = img
            }
            newEventPreviewView.alpha = 1.0
            newEventPreviewView.slide(SlidePosition.Middle){
                newEventPreviewView.setup()
            }
            newEventPreviewView.tab3 = self
            if let sv = selectSenderView {
                sv.slide(SlidePosition.Left)
            }
        }
    }
    
    func removeEventPreviewView(){
        if let epv = eventPreviewView {
            epv.slide(SlidePosition.Right)
        }
        if let sv = selectSenderView {
            sv.slide(SlidePosition.Middle)
        }
    }
    
    func finish(){
        reset()
        if let tab = sharedTab1 {
            tab.refresh()
        }
        goBack()
        place(SlidePosition.Middle)
        if let epv = eventPreviewView {
            epv.removeFromSuperview()
        }
        if let sv = selectSenderView {
            sv.removeFromSuperview()
        }
    }
    
    func reset(){
        if let dp = datePicker {
            dp.minimumDate = NSDate()
        }
        if let dp = endDatePicker {
            dp.minimumDate = NSDate()
        }
        nameTextField.text = ""
        dateTimeTextField.text = ""
        endDateTimeTextField.text = ""
        locationTextField.text = ""
        feeTextField.text = ""
        detailsTextField.text = ""
        holderTextView.text = ""
        feeLine.alpha = 0.6
        dateTimeLine.alpha = 0.6
        endDateTimeLine.alpha = 0.6
        nameLine.alpha = 0.6
        locationLine.alpha = 0.6
        detailLine.alpha = 0.6
    }
}

extension Tab3: TabDelegate {
    func showSlide() {
        reset()
    }
    
    func removeSlide() {
        
    }
}

extension Tab3: PickerToolViewDelegate {
    func pickerPressedBack(ptv: PickerToolView) {
        switch ptv {
        case dateTimeToolView:
            dateTimeLine.alpha = 1.0
            nameTextField.becomeFirstResponder()
            break
        case endDateTimeToolView:
            endDateTimeLine.alpha = 1.0
            dateTimeTextField.becomeFirstResponder()
            break
        case feeToolView:
            locationTextField.becomeFirstResponder()
        default:
            break
        }
    }
    
    func pickerPressedNext(ptv: PickerToolView) {
        switch ptv {
        case dateTimeToolView:
            dateTimeLine.alpha = 1.0
            endDateTimeTextField.becomeFirstResponder()
        case endDateTimeToolView:
            endDateTimeLine.alpha = 1.0
            locationTextField.becomeFirstResponder()
        case feeToolView:
            detailsTextField.becomeFirstResponder()
        case nameToolView:
            dateTimeTextField.becomeFirstResponder()
        default:
            break
        }
    }
    
    func pickerPressedDone(ptv: PickerToolView) {
        switch ptv {
        case dateTimeToolView:
            dateTimeLine.alpha = 1.0
            dateTimeTextField.resignFirstResponder()
        case endDateTimeToolView:
            endDateTimeLine.alpha = 1.0
            endDateTimeTextField.resignFirstResponder()
        case feeToolView:
            feeTextField.resignFirstResponder()
        case nameToolView:
            nameTextField.resignFirstResponder()
        default:
            break
        }
    }
}

extension Tab3: UITextFieldDelegate {
    
    @IBAction func nameTextDidChange(sender: UITextField) {
        sender.updateDisplay(nameLine)
    }
    
    @IBAction func dateTimeTextDidChange(sender: UITextField) {
        sender.updateDisplay(dateTimeLine)
    }
    
    @IBAction func endDateTimeTextDidChange(sender: UITextField) {
        sender.updateDisplay(endDateTimeLine)
    }
    
    @IBAction func locationTextDidChange(sender: UITextField) {
        sender.updateDisplay(locationLine)
    }
    
    @IBAction func feeTextDidChange(sender: UITextField) {
        sender.updateDisplay(feeLine)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        switch textField {
        case detailsTextField:
            if detailEnterView == nil {
                dispatch_async(dispatch_get_main_queue()){
                    var newDetailEnterView = "DetailEnterView".loadNib() as! DetailEnterView
                    self.detailEnterView = newDetailEnterView
                    newDetailEnterView.setup(self.detailsTextField, ref2: self.holderTextView)
                    newDetailEnterView.frame = getMainWindowView().frame
                    getMainWindowView().addSubview(newDetailEnterView)
                    newDetailEnterView.place(SlidePosition.Right)
                    newDetailEnterView.layoutIfNeeded()
                    newDetailEnterView.slide(SlidePosition.Middle)
                    newDetailEnterView.tab3 = self
                    self.slide(SlidePosition.Left)
                }
            }
            return false
        case locationTextField:
            if locationPickerView == nil {
                dispatch_async(dispatch_get_main_queue()){
                    var newLocationPickerView = "LocationPickerView".loadNib() as! LocationPickerView
                    self.locationPickerView = newLocationPickerView
                    newLocationPickerView.setup(self.locationTextField)
                    newLocationPickerView.frame = getMainWindowView().frame
                    getMainWindowView().addSubview(newLocationPickerView)
                    newLocationPickerView.place(SlidePosition.Right)
                    newLocationPickerView.layoutIfNeeded()
                    newLocationPickerView.slide(SlidePosition.Middle)
                    newLocationPickerView.tab3 = self
                    self.slide(SlidePosition.Left)
                }
            }
            return false
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == dateTimeTextField {
            dateTimeTextField.setTextFromDatePicker(datePicker)
            if endDateTimeTextField.text == "" || dateTimeTextField.date?.timeIntervalSince1970 > endDateTimeTextField.date?.timeIntervalSince1970  {
                endDateTimeTextField.setTextFromDatePicker(datePicker)
                endDatePicker!.setDate(datePicker!.date, animated: false)
             }
        } else if textField == endDateTimeTextField {
            endDateTimeTextField.setTextFromDatePicker(endDatePicker)
            if dateTimeTextField.text == "" || dateTimeTextField.date?.timeIntervalSince1970 > endDateTimeTextField.date?.timeIntervalSince1970  {
                dateTimeTextField.setTextFromDatePicker(endDatePicker)
                datePicker!.setDate(endDatePicker!.date, animated: false)
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            dateTimeTextField.becomeFirstResponder()
        case dateTimeTextField:
            endDateTimeTextField.becomeFirstResponder()
        case endDateTimeTextField:
            locationTextField.becomeFirstResponder()
        case locationTextField:
            feeTextField.becomeFirstResponder()
        case feeTextField:
            feeTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
}

extension Tab3:UIPriceTextFieldDelegate {
    func priceDidChange(text: String) {
        if count(text) > 0 {
            feeLine.alpha = 1.0
        } else {
            feeLine.alpha = 0.6
        }
    }
}

extension Tab3:SelectSenderViewDelegate {
    func createSenderSelectView() -> SelectSenderView {
        var newSelectSenderView = "SelectSenderView".loadNib() as! SelectSenderView
        newSelectSenderView.tab3 = self
        newSelectSenderView.frame = getMainWindowView().frame
        newSelectSenderView.delegate = self
        newSelectSenderView.place(SlidePosition.Right)
        Tool.sharedInstance.myViewController!.view.addSubview(newSelectSenderView)
        selectSenderView = newSelectSenderView
        return newSelectSenderView
    }
    
    func cancelSelectSenderPressed() {
        slide(SlidePosition.Middle)
    }
}

extension Tab3 : CameraViewDelegate {
    func didSelectCircularImage(img: UIImage, wholeImg: UIImage) {
        println("ERROR: Tab3 recieved Circular img")
    }
    
    func didSelectImage(img: UIImage) {
        createEventPreviewView()
        showEventPreviewView(img, videoURL: nil)
    }
    
    func didSelectVideo(videourl: NSURL, img: UIImage) {
        createEventPreviewView()
        showEventPreviewView(img, videoURL: videourl)
    }
}






