//
//  EventPreviewView.swift
//  Nenzo
//
//  Created by sloot on 6/21/15.
//
//

import AssetsLibrary
import UIKit
import AVFoundation
import MapKit

protocol Previewable {
    var status:EventStatus { get set }
    var owner_profile_url:String { get set }
    var owner_name:String { get set }
    var cover_photo_url:String { get set }
    var cover_video_url:String { get set }
    var fee:String { get set }
    var location:String { get set }
    var details:String {get set}
    var title:String {get set}
    var start_date:NSTimeInterval {get set}
    var sent_date:NSTimeInterval {get set}
    var true_start_date:NSTimeInterval {get set}
}

class EventPreviewView: UISlideView {

    weak var tab3:Tab3?
    
    weak var tab1:Tab1?
    
    @IBOutlet var eventTitleLabel: UILabel!

    @IBOutlet var myImageView: UIImageView!
    
    @IBOutlet var dateView: UIView!
    
    @IBOutlet var monthLabel: UILabel!
    
    @IBOutlet var dayLabel: UILabel!
    
    @IBOutlet var myProfileImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var locationButton: UIButton!
    
    @IBOutlet var phoneButton: UIButton!
    
    @IBOutlet var feeLabel: UILabel!
    
    @IBOutlet var videoView: UIVideoView!
    
    @IBOutlet var eventDetailTextView: UITextView!
    
    @IBOutlet var tab3BottomView: UIView!
    
    @IBOutlet var tab1BottomView: UIView!
    
    @IBOutlet var tab1OwnerBottomView: UIView!
    
    @IBOutlet var attendButton: NUIButton!
    
    @IBOutlet var attendView: UIView!
    
    @IBOutlet var declineView: UIView!
    
    @IBOutlet var declineButton: NUIButton!
    
    @IBOutlet var sentDateLabel: UILabel!
    
    @IBOutlet var myScrollView: UIScrollView!
    
    @IBOutlet var myCollectionView: UICollectionView!
    
    @IBOutlet var bodyView: UIView!
    
    @IBOutlet var bodyTopView: UIView!
    
    @IBOutlet var bodyMiddleView: UIScrollView!
    
    @IBOutlet var bodyBottomView: UIView!
    
    @IBOutlet var sendInvitationHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var bottomViewHeightConstraint: NSLayoutConstraint!
    
    var date:NSDate!
    
    var originalCollectionViewFrame:CGRect!
    
    var fullCollectionViewFrame:CGRect!
    
    var isAnimating:Bool = false
    
    var collectionViewIsExpanded:Bool = false
    
    var detailedEvent:DetailedEvent?
    
    var selectedContacts:[PhoneContact] = []
    
    var invitedUsers:[InvitedUser] = []
    
    var userEventID:String = ""
    
    weak var myUser:InvitedUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var peopleCellNib:UINib = UINib(nibName: "EventPeopleCell", bundle: nil)
        myCollectionView.registerNib(peopleCellNib, forCellWithReuseIdentifier: "PeopleCell")
        var peopleInitialCellNib:UINib = UINib(nibName: "EventPeopleInitialCell", bundle: nil)
        myCollectionView.registerNib(peopleInitialCellNib, forCellWithReuseIdentifier: "PeopleInitialCell")
        myProfileImageView.cropCircular()
        myProfileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        myProfileImageView.layer.borderWidth = 2.0
        dateView.layer.cornerRadius = 20.0
        dateView.clipsToBounds = true
        dateView.layer.borderColor = UIColor.whiteColor().CGColor
        dateView.layer.borderWidth = 2.0
        tab3BottomView.hidden = true
        tab1BottomView.hidden = true
        eventDetailTextView.textContainer.lineFragmentPadding = 0
        eventDetailTextView.textContainerInset = UIEdgeInsetsZero
    }
    
    func setup(){
        var diff = eventDetailTextView.contentSize.height - eventDetailTextView.frame.size.height
        if diff > 0 {
            myScrollView.contentSize = CGSizeMake(myScrollView.frame.size.width, myScrollView.frame.size.height + diff)
            eventDetailTextView.frame = CGRectMake(eventDetailTextView.frame.origin.x, eventDetailTextView.frame.origin.y, eventDetailTextView.frame.width, eventDetailTextView.frame.height + diff)
        }
        originalCollectionViewFrame = bodyBottomView.frame
        fullCollectionViewFrame = CGRectMake(bodyBottomView.frame.origin.x, bodyBottomView.frame.origin.y - (self.bodyTopView.frame.height + self.bodyMiddleView.frame.height), bodyBottomView.frame.width, self.bodyView.frame.height)
    }
    
    func setupContent(event:Previewable){
        feeLabel.text = event.fee
        eventDetailTextView.selectable = true
        eventDetailTextView.text = event.details
        eventDetailTextView.selectable = false
        locationButton.setTitle(event.location, forState: .Normal)
        nameLabel.text = event.owner_name
        myProfileImageView.smartLoad(event.owner_profile_url)
        eventTitleLabel.text = event.title
        let date:NSDate = NSDate(timeIntervalSince1970: event.true_start_date)
        monthLabel.text = date.getMonth()
        dayLabel.text = date.getDay()
        sentDateLabel.text = NSDate(timeIntervalSince1970: event.sent_date).daysAgo()
    }
    
    @IBAction func phoneButtonPressed(sender: UIButton) {
        if let number = sender.titleLabel?.text, url = NSURL(string: "tel://" + ((number as NSString).extractPhoneNumber() as String)) where UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func locationButtonPressed(sender: UIButton) {
        if let loc = locationButton.titleLabel?.text {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(loc,
                completionHandler:
                {(placemarks: [AnyObject]!, error: NSError!) in
                    
                    if error != nil {
                        println("Geocode failed with error: \(error.localizedDescription)")
                    } else if placemarks.count > 0 {
                        let placemark = placemarks[0] as! CLPlacemark
                        let location = placemark.location
                        let regionDistance:CLLocationDistance = 10000
                        let regionSpan = MKCoordinateRegionMakeWithDistance(location.coordinate, regionDistance, regionDistance)
                        var options = [
                            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
                            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
                        ]
                        var pm = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
                        var mapItem = MKMapItem(placemark: pm)
                        mapItem.name = loc
                        mapItem.openInMapsWithLaunchOptions(options)
                    }
                    
                    if error != nil || placemarks.count == 0 {
                        var options:[NSObject : AnyObject] = NSDictionary() as [NSObject : AnyObject]
                        let regionDistance:CLLocationDistance = 10000
                        var coordinate = CLLocationCoordinate2DMake(35.0, 1.0)
                        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinate, regionDistance, regionDistance)
                        var pm = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                        var mapItem = MKMapItem(placemark: pm)
                        mapItem.name = loc
                        mapItem.openInMapsWithLaunchOptions(options)
                    }
                    
            })
        }
    }
    
    
    @IBAction func sendInvitePressed(sender: UIButton) {
        createEvent()
    }
    
    @IBAction func editPressed(sender: UIButton) {
    }
    
    var shouldClose:Bool = true
    
    @IBAction func backPressed(sender: UIButton) {
        if shouldClose {
            shouldClose = false
            if let tab = tab3 {
                tab.removeEventPreviewView()
            }
            if let tab = tab1 {
                tab.refresh()
                tab.removeEventPreviewView()
            }
        }
    }
    
    @IBAction func attendPressed(sender: UIButton) {
        if let tab = tab1 {
            declineButton.userInteractionEnabled = false
            attendButton.userInteractionEnabled = false
            attendButton.chosen = !attendButton.chosen
            if attendButton.chosen {
                putStatus("accepted")
                showAttendDisplay()
                if declineButton.chosen {
                    showUnDeclineDisplay()
                }
                updateEventStatus(EventStatus.Accept)
                if let user = myUser {
                    user.status = EventStatus.Accept
                    myCollectionView.reloadData()
                }
            } else {
                putStatus("invited")
                showUnAttendDisplay()
                updateEventStatus(EventStatus.Invited)
                if let user = myUser {
                    user.status = EventStatus.Invited
                    myCollectionView.reloadData()
                }
            }
            declineButton.userInteractionEnabled = true
            attendButton.userInteractionEnabled = true
        }
    }
    
    func showAttending(){
        attendButton.chosen = true
        showAttendDisplay()
    }
    
    @IBAction func declinePressed(sender: UIButton) {
        if let tab = tab1 {
            declineButton.userInteractionEnabled = false
            attendButton.userInteractionEnabled = false
            declineButton.chosen = !declineButton.chosen
            if declineButton.chosen {
                putStatus("declined")
                showDeclineDisplay()
                if attendButton.chosen {
                    showUnAttendDisplay()
                }
                updateEventStatus(EventStatus.Decline)
                if let user = myUser {
                    user.status = EventStatus.Decline
                    myCollectionView.reloadData()
                }
            } else {
                putStatus("invited")
                showUnDeclineDisplay()
                updateEventStatus(EventStatus.Invited)
                if let user = myUser {
                    user.status = EventStatus.Invited
                    myCollectionView.reloadData()
                }
            }
            declineButton.userInteractionEnabled = true
            attendButton.userInteractionEnabled = true
        }
    }
    
    func showDeclining(){
        declineButton.chosen = true
        showDeclineDisplay()
    }
    
    func showDeclineDisplay(){
        declineView.alpha = 1.0
        declineButton.chosen = true
    }
    
    func showAttendDisplay(){
        attendView.alpha = 1.0
        attendButton.chosen = true
    }
    
    func showUnDeclineDisplay(){
        declineView.alpha = 0.5
        declineButton.chosen = false
    }
    
    func showUnAttendDisplay(){
        attendView.alpha = 0.5
        attendButton.chosen = false
    }
    
    func updateEventStatus(status:EventStatus){
        
    }
    
    
    var videoURL:NSURL?
    
    func setupVideo(url:NSURL){
        videoURL = url
        previewVideo(url, urlString: nil)
    }
    
    var avPlayerLayer:AVPlayerLayer = AVPlayerLayer()
    
    func previewVideo(url:NSURL?, urlString:String?){
        if let tab = tab1, str = urlString {
            videoView.smartVideoLoad(str)
        } else {
            if let u = url {
                videoURL = u
                var avPlayer:AVPlayer = AVPlayer(URL: u)
                
                avPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                avPlayerLayer.player = avPlayer
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: avPlayer.currentItem)
                
                var screenRect:CGRect = UIScreen.mainScreen().bounds
                
                avPlayerLayer.frame = CGRectMake(0, 0, screenRect.width, screenRect.height)
                
                videoView.layer.addSublayer(avPlayerLayer)
                avPlayer.play()
            }
        }
    }
    
    func playerItemDidReachEnd(notification:NSNotification){
        if let p = notification.object as? AVPlayerItem {
            p.seekToTime(kCMTimeZero)
        }
    }
}

extension EventPreviewView :  UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let t3 = tab3 {
            return selectedContacts.count + 1
        } else {
            return invitedUsers.count + 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell!
        if indexPath.row == 0 {
            let newCell = collectionView.dequeueReusableCellWithReuseIdentifier("PeopleInitialCell", forIndexPath: indexPath) as! EventPeopleInitialCell
            newCell.delegate = self
            if let t3 = tab3 {
                newCell.myButton.setTitle("\(selectedContacts.count)", forState: .Normal)
            } else {
                newCell.myButton.setTitle("\(invitedUsers.count)", forState: .Normal)
            }
            cell = newCell
        } else {
            let newCell = collectionView.dequeueReusableCellWithReuseIdentifier("PeopleCell", forIndexPath: indexPath) as! EventPeopleCell
            cell = newCell
            if let t3 = tab3 {
                if let url = selectedContacts[indexPath.row - 1].profile_url {
                    newCell.myImageView.smartLoad(url)
                }
            } else {
                newCell.setup(invitedUsers[indexPath.row - 1])
            }
        }
//        applyBlurEffect(cell.myImageView)
//        cell.setup(events[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
            
            var returnSize:CGSize!
            returnSize = CGSize(width: collectionView.frame.width/5.0, height: 78.0)
            
            return returnSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        if eventPreviewView == nil {
//            self.createEventPreviewView()
//            self.showEventPreviewView(UIImage(), videoURL: nil)
//        }
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        //collectionView.cellForItemAtIndexPath(indexPath)?.contentView.backgroundColor = UIColor.lightGrayColor()
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        //collectionView.cellForItemAtIndexPath(indexPath)?.contentView.backgroundColor = UIColor.whiteColor()
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    //Margin/Padding/Spacing additionals
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
}

extension EventPreviewView : EventPeopleInitialCellDelegate {
    func initialCellPressed() {
        if !isAnimating {
            isAnimating = true
            collectionViewIsExpanded = !collectionViewIsExpanded
            if !collectionViewIsExpanded {
                self.bodyTopView.hidden = false
                self.bodyMiddleView.hidden = false
                self.myCollectionView.setContentOffset(CGPointZero, animated: true)
            }
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                if self.collectionViewIsExpanded {
                    self.bodyBottomView.frame = self.fullCollectionViewFrame
                    self.bodyTopView.alpha = 0.0
                    self.bodyMiddleView.alpha = 0.0
                } else {
                    self.bodyBottomView.frame = self.originalCollectionViewFrame
                    self.bodyTopView.alpha = 1.0
                    self.bodyMiddleView.alpha = 1.0

                }
            }){ (done) -> Void in
                if self.collectionViewIsExpanded {
                    self.bodyTopView.hidden = true
                    self.bodyMiddleView.hidden = true
                    self.myCollectionView.scrollEnabled = true
                } else {
                    self.myCollectionView.scrollEnabled = false
                }
                self.isAnimating = false
            }
        }
    }
}

extension EventPreviewView {
    func createEvent(){
        if let event = detailedEvent where !networkLock {
            showLoading()
            networkLock = true
            var input:[MultiPartFormObject] = []
            var titleMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: event.title, key: "title")
            input.append(titleMPObj)
            var startMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: "\(event.start_date)", key: "start_date")
            input.append(startMPObj)
            var endMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: "\(event.end_date)", key: "end_date")
            input.append(endMPObj)
            var feeMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: event.fee, key: "fee")
            input.append(feeMPObj)
            var locMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: event.location, key: "location")
            input.append(locMPObj)
            var detailsMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: event.details, key: "details")
            input.append(detailsMPObj)
            
            if let newVideoURL = videoURL, vidData = NSData(contentsOfURL: newVideoURL) {
                var newVid:MultiPartFormObject = MultiPartFormObject(containsImage: true, data: vidData, key: "cover_video")
                input.append(newVid)
                if let newCoverImage = event.cover_image {
                    let imgData:NSData = UIImagePNGRepresentation(newCoverImage)
                    var newImg:MultiPartFormObject = MultiPartFormObject(containsImage: true, data: imgData, key: "thumbnail")
                    input.append(newImg)
                }
            } else if let newCoverImage = event.cover_image {
                let imgData:NSData = UIImagePNGRepresentation(newCoverImage)
                var newImg:MultiPartFormObject = MultiPartFormObject(containsImage: true, data: imgData, key: "cover_photo")
                input.append(newImg)
            }
            
            var nenzoContacts:[String] = []
            var phoneContacts:[String] = []
            for contact in selectedContacts {
                if let uuid = contact.uuid where count(uuid) > 0 {
                    nenzoContacts.append(uuid)
                } else {
                    phoneContacts = (phoneContacts as NSArray).arrayByAddingObjectsFromArray(contact.phoneNumbers) as? [String] ?? []
                }
            }
            
            if nenzoContacts.count > 0 {
                var nenzoContactMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: nenzoContacts, key: "nenzo_contacts")
                input.append(nenzoContactMPObj)
            }
            
            if phoneContacts.count > 0 {
                var nenzoMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: phoneContacts, key: "phone_contacts")
                input.append(nenzoMPObj)
            }
            
            Tool.callMPREST(input, path: "events.json", method: "POST", completionHandler: { (json) -> Void in
                if let myJson = json, status = myJson["status"] as? String {
                    if status == "error" {
                        if let errorArr = myJson["message"] as? [String] where errorArr.count > 0 {
                            for err in errorArr {
                                self.showError(err)
                            }
                        } else {
                            self.showError("Server Error")
                        }
                    } else {
                        println("gucci")
                    }
                } else {
                    self.showError("Internet Error")
                }
                removeLoading()
                self.networkLock = false
                if let tab = sharedTab3 {
                    tab.finish()
                }
                }, errorHandler: { () -> Void in
                    self.networkLock = false
                    removeLoading()
            })
        }
    }
    
    func getEventUsers(event_id:String){
        Tool.callREST(nil, path: "events/invited_users.json?event_id=\(event_id)", method: "GET", completionHandler: { (json) -> Void in
            if let myJson = json {
                if let status = myJson["status"] as? String {
                    if let users = myJson["users"] as? [NSDictionary] where status == "success" {
                        var newUsers:[InvitedUser] = []
                        for user in users {
                            var newUser = InvitedUser()
                            newUser.profile_url = user["profile_url"] as? String ?? ""
                            var status = user["relation"] as? String ?? "invited"
                            switch status {
                            case "invited":
                                newUser.status = EventStatus.Invited
                            case "accepted":
                                newUser.status = EventStatus.Accept
                            case "delined":
                                newUser.status = EventStatus.Decline
                            default:
                                break
                            }
                            var is_current_user = user["is_current_user"] as? Bool ?? false
                            if is_current_user {
                                if self.attendButton.chosen {
                                    newUser.status = EventStatus.Accept
                                } else if self.declineButton.chosen {
                                    newUser.status = EventStatus.Decline
                                } else {
                                    newUser.status = EventStatus.Invited
                                }
                                self.myUser = newUser
                            }
                            newUsers.append(newUser)
                        }
                        self.invitedUsers = newUsers
                        self.myCollectionView.reloadData()
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
    
    func putStatus(status:String){
        var input:NSMutableDictionary = NSMutableDictionary()
        input["status"] = status
        input["user_event_id"] = userEventID
        Tool.callREST(input, path: "events/update_status.json", method: "PUT", completionHandler: nil, errorHandler: nil)
    }
}

class InvitedUser {
    var profile_url:String = ""
    var status:EventStatus = EventStatus.Invited
}

class DetailedEvent : NSObject {
    var title:String = ""
    var start_date:NSTimeInterval = NSTimeInterval()
    var end_date:NSTimeInterval = NSTimeInterval()
    var fee:String = ""
    var location:String = ""
    var details:String = ""
    var cover_image:UIImage?
    var uuid:String = ""
}