
//
//  LocationPickerView.swift
//  Nenzo
//
//  Created by sloot on 6/21/15.
//
//

import UIKit

class LocationPickerView: UISlideView {
    weak var referenceInputField:UITextField?
    
    weak var tab3:Tab3?
    
    @IBOutlet var myTableView: UITableView!
    
    var savedSearches:[String] = []
    
    var displaySavedSearches:[String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var nib:UINib = UINib(nibName: "LocationPickerViewCell", bundle: nil)
        myTableView.registerNib(nib, forCellReuseIdentifier: "LocationCell")
        if let searches = NSUserDefaults.standardUserDefaults().objectForKey("searches") as? [String] {
            savedSearches = searches
            displaySavedSearches = savedSearches
        }
    }
    
    func setup(ref:UITextField){
        referenceInputField = ref
        if let refTV = referenceInputField {
            mySearchField.text = refTV.text
        }
        search(mySearchField.text)
        mySearchField.addToolView(self)
    mySearchField.becomeFirstResponder()
    }
    
    @IBOutlet var mySearchField: UITextField!
    
    @IBAction func backPressed(sender: UIButton) {
        finish(nil)
    }
    
    var isFinished = false
    
    func finish(completionHandler: (() -> Void)?){
        if !isBusy && !isFinished {
            isFinished = true
            if (count(mySearchField.text) > 0) {
                if !contains(savedSearches, mySearchField.text) {
                    savedSearches.append(mySearchField.text)
                    NSUserDefaults.standardUserDefaults().setObject(savedSearches, forKey: "searches")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                tab3!.locationLine.alpha = 1.0
            } else {
                tab3!.locationLine.alpha = 0.6
            }
            slide(SlidePosition.Right)
            tab3!.slide(SlidePosition.Middle){
                if let refTV = self.referenceInputField {
                    refTV.text = self.mySearchField.text
                }
                if let completion = completionHandler {
                    completion()
                }
                self.removeFromSuperview()
            }
        }
    }

    @IBAction func searchDidChange(sender: UITextField) {
        search(sender.text)
    }
    
    func search(pre:String){
        if count(pre) > 0 {
            let predicate:NSPredicate = NSPredicate(format: "self contains[c] %@", pre)
            displaySavedSearches = (savedSearches as NSArray).filteredArrayUsingPredicate(predicate) as! [String]
        } else {
            displaySavedSearches = savedSearches
        }
        myTableView.reloadData()
    }
}


let LOCATIONCELLHEIGHT:CGFloat = 50.0
extension LocationPickerView : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return LOCATIONCELLHEIGHT
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    /*
    1 section for followed boards
    another for own boards
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let emptyView:UIView = UIView()
        emptyView.backgroundColor = UIColor.clearColor()
        return emptyView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displaySavedSearches.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            var cell:LocationPickerViewCell = tableView.dequeueReusableCellWithIdentifier(
                "LocationCell",
                forIndexPath: indexPath) as! LocationPickerViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.myLabel.text = displaySavedSearches[indexPath.row]
            return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mySearchField.text = displaySavedSearches[indexPath.row]
        finish(nil)
    }
    
//    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return false
//    }
}

extension LocationPickerView : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        finish(){
            self.tab3!.feeTextField.becomeFirstResponder()
        }
        return false
    }
}

extension LocationPickerView: PickerToolViewDelegate {
    func pickerPressedBack(ptv: PickerToolView) {
        finish(){
            self.tab3!.endDateTimeTextField.becomeFirstResponder()
        }
    }
    
    func pickerPressedNext(ptv: PickerToolView) {
        finish(){
            self.tab3!.feeTextField.becomeFirstResponder()
        }
    }
    
    func pickerPressedDone(ptv: PickerToolView) {
        mySearchField.resignFirstResponder()
    }
}