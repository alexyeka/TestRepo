//
//  SelectSenderView.swift
//  Nenzo
//
//  Created by sloot on 6/13/15.
//
//

import UIKit
import AddressBookUI
@objc(SelectSenderViewDelegate)
protocol SelectSenderViewDelegate{
    func cancelSelectSenderPressed()
}
let sectionTitles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]

class SelectSenderView: UISlideView {

    weak var tab3:Tab3!
    
    weak var delegate:SelectSenderViewDelegate?
    
    @IBOutlet var myToggleView: UIView!
    
    @IBOutlet var phoneTabButton: UIButton!
    
    @IBOutlet var nenzoTabButton: UIButton!
    
    @IBOutlet var myTableView: UITableView!
    
    @IBOutlet var myCountLabel: UILabel!
    
    @IBOutlet var mySearchTextField: UITextField!
    
    var senderCount:Int = 0
    
    var phoneContacts:[[PhoneContact]] = createArrayOfPhoneArrays(sectionTitles.count)
    
    var displayPhoneContacts:[[PhoneContact]] = createArrayOfPhoneArrays(sectionTitles.count)
    
    var nenzoContacts:[[NenzoContact]] = createArrayOfNenzoArrays(sectionTitles.count)
    
    var displayNenzoContacts:[[NenzoContact]] = createArrayOfNenzoArrays(sectionTitles.count)
    
    let sectionConverter:NSDictionary = createToIntDictionary()
    
    var adbk : ABAddressBook!
    
    var isPhoneTab:Bool = true
    
    var selectedCount:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myToggleView.layer.cornerRadius = 5.0
        myToggleView.layer.borderColor = ORANGE.CGColor
        myToggleView.layer.borderWidth = 1.0
        myToggleView.clipsToBounds = true
        phoneTabButton.enabled = false
        var nib:UINib = UINib(nibName: "SenderTableCell", bundle: nil)
        myTableView.registerNib(nib, forCellReuseIdentifier: "SenderTableCell")
        myTableView.bounces = false
        myCountLabel.layer.cornerRadius = myCountLabel.frame.width/2.0
        myCountLabel.clipsToBounds = true
        mySearchTextField.stylePlaceHolder(mySearchTextField.placeholder, color: UIColor(red: 66.0/255.0, green: 103.0/255.0, blue: 135/255.0, alpha: 1.0))
        refreshCountLabel()
        myTableView.sectionIndexColor = ORANGE
        myTableView.sectionFooterHeight = 0.0
        myTableView.sectionHeaderHeight = 0.0
        //myTableView.backgroundColor = UIColor.greenColor()
    }

    func didAppear(){
        displayNenzoContacts = nenzoContacts
        getContactNames()
    }
    
    @IBAction func backPressed(sender: UIButton) {
        slide(SlidePosition.Right){
            self.removeFromSuperview()
        }
        if let dgt = delegate {
            dgt.cancelSelectSenderPressed()
        }
    }
    
    @IBAction func nextPressed(sender: UIButton) {
        if let tab3 = sharedTab3 {
            var selected:[PhoneContact] = []
            for set in phoneContacts {
                for contact in set {
                    if contact.selected {
                        selected.append(contact)
                    }
                }
            }
            tab3.selectedContacts = selected
        }
        Tool.sharedInstance.myViewController!.showCameraView(tab3, type: CameraViewType.Multiple)
    }
    
    @IBAction func phoneTabPressed(sender: UIButton) {
//        isPhoneTab = true
//        nenzoTabButton.backgroundColor = UIColor.clearColor()
//        phoneTabButton.backgroundColor = ORANGE
//        phoneTabButton.enabled = false
//        nenzoTabButton.enabled = true
//        dispatch_async(dispatch_get_main_queue()){
//            self.myTableView.reloadData()
//        }
    }
    
    @IBAction func nenzoTabPressed(sender: UIButton) {
//        isPhoneTab = false
//        phoneTabButton.backgroundColor = UIColor.clearColor()
//        nenzoTabButton.backgroundColor = ORANGE
//        phoneTabButton.enabled = true
//        nenzoTabButton.enabled = false
//        dispatch_async(dispatch_get_main_queue()){
//            self.myTableView.reloadData()
//        }
    }
}
let ITEMCELLHEIGHT:CGFloat = 61.0
extension SelectSenderView : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return ITEMCELLHEIGHT - 7.0
        } else {
            return ITEMCELLHEIGHT
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isPhoneTab {
            if displayPhoneContacts[section].count > 0 {
                return 28.0
            } else {
                return 0.0
            }
        } else {
            if displayNenzoContacts[section].count > 0 {
                return 28.0
            } else {
                return 0.0
            }
        }
    }
    
    /*
    1 section for followed boards
    another for own boards
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.numberOfRowsInSection(section) == 0 {
            return nil
        } else {
            var sectionView:SenderTableSectionHeaderView = "SenderTableSectionHeaderView".loadNib() as! SenderTableSectionHeaderView
            sectionView.sectionLabel.text = "\(sectionTitles[section])"
            return sectionView
        }
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
        if isPhoneTab {
            return displayPhoneContacts[section].count
        } else {
            return displayNenzoContacts[section].count
        }
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            var cell:SenderTableCell = tableView.dequeueReusableCellWithIdentifier(
                "SenderTableCell",
                forIndexPath: indexPath) as! SenderTableCell
            if isPhoneTab {
                let contact = displayPhoneContacts[indexPath.section][indexPath.row]
                if contact.selected {
                    cell.myAddButton.selected = true
                } else {
                    cell.myAddButton.selected = false
                }
                cell.phoneContact = contact
                cell.nenzoContact = nil
                cell.myTextLabel.text = contact.name
                if let url = contact.profile_url {
                    cell.profileIconImageView.smartLoad(url)
                } else {
                    cell.profileIconImageView.tag = -1
                    cell.profileIconImageView.image = nil
                    cell.profileIconImageView.hidden = true
                }
            } else {
//                let contact = displayNenzoContacts[indexPath.section][indexPath.row]
//                if selectedSet.containsObject(contact) {
//                    cell.myAddButton.selected = true
//                } else {
//                    cell.myAddButton.selected = false
//                }
//                cell.myTextLabel.text = contact.name
//                cell.nenzoContact = contact
//                cell.phoneContact = nil
            }
            cell.delegate = self
            //cell.backgroundColor = UIColor.blueColor()
            return cell
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func refreshCountLabel(){
        myCountLabel.text = "\(selectedCount)"
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return sectionTitles
    }
    
    @IBAction func searchUpdated(sender: UITextField) {
        search(sender.text)
    }
    
}

extension SelectSenderView: SenderTableCellDelegate {
    func addSenderPressed(sender:SenderTableCell) {
        if let pc = sender.phoneContact where !pc.selected {
            pc.selected = true
            selectedCount++
        } else if let pc = sender.nenzoContact {
//            selectedSet.addObject(pc)
        }
        refreshCountLabel()
    }
    
    func removeSenderPressed(sender:SenderTableCell) {
        if let pc = sender.phoneContact where pc.selected {
            pc.selected = false
            selectedCount--
        } else if let pc = sender.nenzoContact {
            //selectedSet.removeObject(pc)
        }
        refreshCountLabel()
    }
}

extension SelectSenderView {
    func createAddressBook() -> Bool {
        if self.adbk != nil {
            return true
        }
        var err : Unmanaged<CFError>? = nil
        let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if adbk == nil {
            self.adbk = nil
            return false
        }
        self.adbk = adbk
        return true
    }
    
    func determineStatus() -> Bool {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .Authorized:
            return self.createAddressBook()
        case .NotDetermined:
            var ok = false
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        ok = self.createAddressBook()
                        self.getContactNames()
                    }
                }
            }
            if ok == true {
                return true
            }
            self.adbk = nil
            return false
        case .Restricted:
            self.adbk = nil
            return false
        case .Denied:
            self.adbk = nil
            return false
        }
    }
    
    func getContactNames() {
        if !self.determineStatus() {
            println("not authorized")
            return
        }
        if let people = ABAddressBookCopyArrayOfAllPeople(adbk)?.takeRetainedValue() as? NSArray as? [ABRecord] {
            var contacts:[PhoneContact] = []
            for person in people {
                if let property = ABRecordCopyValue(person, kABPersonPhoneProperty) {
                    var abnumbers: ABMultiValueRef? = property.takeRetainedValue() as ABMultiValueRef
                    if let name = ABRecordCopyCompositeName(person)?.takeRetainedValue() as? String, numbers: ABMultiValueRef = abnumbers {
                        var newContact = PhoneContact()
                        newContact.name = name
                        for var i = 0; i < ABMultiValueGetCount(numbers); i++ {
                            if let number = ABMultiValueCopyValueAtIndex(numbers, i)?.takeRetainedValue() as? NSString {
                                newContact.phoneNumbers.append(number.extractPhoneNumber() as String)
                            } else {
                                println("Invalid number for \(name)")
                            }
                        }
                        if count(newContact.name) > 0 {
                            contacts.append(newContact)
                        }
                    } else {
                        println("Invalid name or numbers")
                    }
                } else {
                    println("Invalid phone properties")
                }
            }
            getFriends(contacts)
        }
    }
    
    func search(pre:String){
        if isPhoneTab {
            if count(pre) > 0 {
                let predicate:NSPredicate = NSPredicate(format: "name contains[c] %@", pre)
                for var i = 0; i < phoneContacts.count; i++ {
                    displayPhoneContacts[i] = (phoneContacts[i] as NSArray).filteredArrayUsingPredicate(predicate) as! [PhoneContact]
                }
            } else {
                displayPhoneContacts = phoneContacts
            }
        } else {
            if count(pre) > 0 {
                let predicate:NSPredicate = NSPredicate(format: "name contains[c] %@", pre)
                for var i = 0; i < nenzoContacts.count; i++ {
                    displayNenzoContacts[i] = (nenzoContacts[i] as NSArray).filteredArrayUsingPredicate(predicate) as! [NenzoContact]
                }
            } else {
                displayNenzoContacts = nenzoContacts
            }
        }
        myTableView.reloadData()
    }
}

extension SelectSenderView {
    func getFriends(contacts:[PhoneContact]){
        var inputDict = NSMutableDictionary()
        var phoneArr:NSMutableArray = NSMutableArray()
        for contact in contacts {
            phoneArr.addObject(contact.phoneNumbers)
        }
        //inputDict["phone_numbers"] = ["6502817692"]
        inputDict["phone_numbers"] = phoneArr
        Tool.callREST(inputDict, path: "events/friends.json", method: "PUT", completionHandler: { (json) -> Void in
            if let myJson = json {
                self.selectedCount = 0
                if let status = myJson["status"] as? String {
                    if let users = myJson["users"] as? [NSDictionary] where status == "success" {
                        if count(users) == count(contacts) {
                            for var i = 0; i < count(users) ; i++ {
                                var contact = contacts[i]
                                if let img_url = users[i]["profile_url"] as? String {
                                    contact.profile_url = img_url
                                }
                                if let user_id = users[i]["uuid"] as? String {
                                    contact.uuid = user_id
                                }
                                let firstLetter = String((contact.name as NSString).substringToIndex(1))
                                if let index = self.sectionConverter[firstLetter] as? Int {
                                    self.phoneContacts[index].append(contact)
                                } else {
                                    self.phoneContacts[self.phoneContacts.count - 1].append(contact)
                                }
                            }
                            self.displayPhoneContacts = self.phoneContacts
                            self.myTableView.reloadData()
                        } else {
                            self.showError("Server Error")
                        }
                    } else {
                        self.showError("Server Error")
                    }
                } else {
                    self.showError("Server Error")
                }
            } else {
                self.showError("No internet")
            }
            }, errorHandler: nil)
    }
}

func createArrayOfPhoneArrays(count:Int) -> [[PhoneContact]] {
    var temp:[[PhoneContact]] = []
    for var i = 0; i < count; i++ {
        temp.append([])
    }
    return temp
}

func createArrayOfNenzoArrays(count:Int) -> [[NenzoContact]] {
    var temp:[[NenzoContact]] = []
    for var i = 0; i < count; i++ {
        temp.append([])
    }
    return temp
}

func createToIntDictionary() -> NSMutableDictionary {
    var temp:NSMutableDictionary = NSMutableDictionary()
    for var i = 0; i < sectionTitles.count; i++ {
        temp[sectionTitles[i]] = i
    }
    return temp
}