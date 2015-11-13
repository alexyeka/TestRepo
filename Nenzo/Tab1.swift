//
//  Tab1.swift
//  Nenzo
//
//  Created by sloot on 5/27/15.
//
//
let TAB1_CELL_HEIGHT:CGFloat = 171.0
import UIKit
weak var sharedTab1:Tab1?
func tempEvents() -> [Event]{
    var new:[Event] = []
    var newE:Event = Event()
    newE.title = "Jacks BDay"
    newE.status = EventStatus.Invited
    newE.profileUrl = "https://scontent-sjc2-1.xx.fbcdn.net/hphotos-xaf1/v/t1.0-9/10702129_10205018429642811_8761955955535783707_n.jpg?oh=b4f4a2f7bcf85a15c357f1af535e9733&oe=5632B7BA"
    newE.medias = tempMedias()
    
    var newE2:Event = Event()
    newE2.title = "GNO"
    newE2.status = EventStatus.Accept
    newE2.profileUrl = "https://scontent-sjc2-1.xx.fbcdn.net/hphotos-xap1/v/t1.0-9/11116389_1585955778345413_430388825310725857_n.jpg?oh=2e1452fd3ca06fb48ce9da2defe8215d&oe=55F357C7"
    newE2.opened = true
    newE2.medias = tempMedias()
    
    var newE3:Event = Event()
    newE3.title = "Sarahs goodbye..."
    newE3.status = EventStatus.Decline
    newE3.profileUrl = "https://scontent-sjc2-1.xx.fbcdn.net/hphotos-xtp1/v/t1.0-9/10641288_10205844934979088_1215173457728100831_n.jpg?oh=d91ea324dc82c04865ba6a51f671f446&oe=55F51941"
    newE3.opened = true
    newE3.medias = tempMedias()
    
    new.append(newE)
    new.append(newE2)
    new.append(newE3)
    return new
}

func tempMedias() -> [NMedia] {
    var new:[NMedia] = []
    var newM:NImage = NImage()
    newM.imgurl = "http://flyingsquirrelsports.ca/wp-content/uploads/2015/02/11-birthday-party.jpg"
    
    new.append(newM)
    
    var newM2:NImage = NImage()
    newM2.imgurl = "http://www.laelamalta.com/sites/default/files/party.jpg"
    
    new.append(newM2)
    
    var newM3:NImage = NImage()
    newM3.imgurl = "http://www.dnpphoto.com/portals/0/Images/Fotolia_32635285_XXL_party-fun.jpg"
    
    new.append(newM3)
    return new
}

class Tab1: UIView {

    @IBOutlet var myCollectionView: UICollectionView!
    
    //var events:[Event] = tempEvents()
    
    var inboxEvents:[InboxEvent] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedTab1 = self
        var eventCellNib:UINib = UINib(nibName: "Tab1EventCell", bundle: nil)
        myCollectionView.registerNib(eventCellNib, forCellWithReuseIdentifier: "EventCell")
        getEvents()
    }
    
    weak var eventPreviewView:EventPreviewView?
    
    var isBusy:Bool = false
    
    func createEventPreviewView() -> EventPreviewView {
        var newEventPreviewView = "EventPreviewView".loadNib() as! EventPreviewView
        eventPreviewView = newEventPreviewView
        return newEventPreviewView
    }
    
    func showEventPreviewView(inboxEvent:InboxEvent){
        if let newEventPreviewView = eventPreviewView {
            newEventPreviewView.frame = getMainWindowView().frame
            newEventPreviewView.place(SlidePosition.Right)
//            newEventPreviewView.myImageView.image = img
            newEventPreviewView.alpha = 0.0
            newEventPreviewView.tab1 = self
            newEventPreviewView.tab1BottomView.hidden = false
            newEventPreviewView.setupContent(inboxEvent)
            newEventPreviewView.phoneButton.setTitle(inboxEvent.owner_phone_number, forState: .Normal)
            newEventPreviewView.speed = 0.2
//            newEventPreviewView.timeLabel.text = dateTimeTextField.getTime()
//            newEventPreviewView.locationLabel.text = locationTextField.text
//            newEventPreviewView.phoneLabel.text = "777 - 777 - 7777"
//            newEventPreviewView.feeLabel.text = feeTextField.text
//            newEventPreviewView.eventTitleLabel.text = nameTextField.text
//            newEventPreviewView.eventDetailTextView.setBody(detailsTextField.text)
//            newEventPreviewView.monthLabel.text = dateTimeTextField.getMonth()
//            newEventPreviewView.dayLabel.text = dateTimeTextField.getDay()
            Tool.sharedInstance.myViewController!.view.addSubview(newEventPreviewView)
            newEventPreviewView.layoutIfNeeded()
            if inboxEvent.cover_video_url != "/cover_videos/original/missing.png" {
                newEventPreviewView.previewVideo(nil, urlString: inboxEvent.cover_video_url)
            } else {
                newEventPreviewView.myImageView.smartLoad(inboxEvent.cover_photo_url)
            }
            newEventPreviewView.alpha = 1.0
            newEventPreviewView.getEventUsers(inboxEvent.uuid)
            if inboxEvent.status == EventStatus.Created {
                newEventPreviewView.tab1OwnerBottomView.hidden = false
                newEventPreviewView.tab1BottomView.hidden = true
            } else if inboxEvent.status == EventStatus.Accept {
                newEventPreviewView.showAttending()
            } else if inboxEvent.status == EventStatus.Decline {
                newEventPreviewView.showDeclining()
            }
            newEventPreviewView.userEventID = inboxEvent.user_event_uuid
            newEventPreviewView.slide(SlidePosition.Middle){
                newEventPreviewView.setup()
            }
//            newEventPreviewView.tab3 = self
//            if let sv = selectSenderView {
//                sv.slide(SlidePosition.Left)
//            }
        }
    }
    
    func removeEventPreviewView(){
        if let epv = eventPreviewView {
            epv.slide(SlidePosition.Right){
                epv.removeFromSuperview()
            }
        }
    }
    
    func refresh(){
        getEvents()
    }
}

extension Tab1: TabDelegate {
    func showSlide() {
        refresh()
    }
    func removeSlide() {
        
    }
}

extension Tab1: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inboxEvents.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:Tab1EventCell!
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! Tab1EventCell
        //applyBlurEffect(cell.myImageView)
        cell.setup(inboxEvents[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
            
            var returnSize:CGSize!
            returnSize = CGSize(width: self.frame.width, height: (self.frame.height + 50.0)/3.0)
            
            return returnSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if eventPreviewView == nil {
            let event = inboxEvents[indexPath.row]
            let pv = self.createEventPreviewView()
            pv.sendInvitationHeightConstraint.constant = event.status == EventStatus.Created ? 0 : 50.0
            pv.bottomViewHeightConstraint.constant = event.status == EventStatus.Created ? 0 : 50.0
            self.showEventPreviewView(event)
            putRead(event.user_event_uuid)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        //collectionView.cellForItemAtIndexPath(indexPath)?.contentView.backgroundColor = UIColor.lightGrayColor()
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        //collectionView.cellForItemAtIndexPath(indexPath)?.contentView.backgroundColor = UIColor.whiteColor()
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //Margin/Padding/Spacing additionals
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }

}

extension Tab1 {
    func getEvents(){
        if inboxEvents.count == 0 {
            showLoading()
        }
        Tool.callREST(nil, path: "events/inbox.json", method: "GET", completionHandler: { (json) -> Void in
            removeLoading()
            if let myJson = json {
                if let status = myJson["status"] as? String {
                    if let events = myJson["events"] as? [NSDictionary] where status == "success" {
                        var newInboxEvents:[InboxEvent] = []
                        var nextEvent:InboxEvent?
                        for event in events {
                            var newEvent = InboxEvent()
                            newEvent.title = event["title"] as? String ?? ""
                            newEvent.owner_profile_url = event["owner_profile_url"] as? String ?? ""
                            newEvent.cover_photo_url = event["cover_photo_url"] as? String ?? ""
                            newEvent.cover_video_url = event["cover_video_url"] as? String ?? ""
                            newEvent.thumbnail_url = event["thumbnail_url"] as? String ?? ""
                            newEvent.owner_name = event["owner_name"] as? String ?? "Your friend"
                            newEvent.start_date = event["start_date"] as? NSTimeInterval ?? 0
                            newEvent.uuid = event["event_uuid"] as? String ?? ""
                            newEvent.fee = event["fee"] as? String ?? ""
                            newEvent.location = event["location"] as? String ?? ""
                            newEvent.details = event["details"] as? String ?? ""
                            newEvent.owner_phone_number = event["owner_phone_number"] as? String ?? ""
                            newEvent.user_event_uuid = event["user_event_uuid"] as? String ?? "invited"
                            newEvent.true_start_date = NSTimeInterval(event["start_date"] as? Int ?? 0) ?? NSTimeInterval()
                            newEvent.opened = event["read"] as? Bool ?? false
                            let myTimeZone:NSInteger = NSTimeZone.systemTimeZone().secondsFromGMT
                            newEvent.start_date =  newEvent.true_start_date + NSTimeInterval(myTimeZone)
                            newEvent.sent_date = NSTimeInterval(event["created_at"] as? Int ?? 0) ?? NSTimeInterval()
                            var status = event["relation"] as? String ?? "invited"
                            switch status {
                            case "created":
                                newEvent.status = EventStatus.Created
                            case "invited":
                                newEvent.status = EventStatus.Invited
                            case "accepted":
                                newEvent.status = EventStatus.Accept
                            case "declined":
                                newEvent.status = EventStatus.Decline
                            default:
                                break
                            }
                            newInboxEvents.append(newEvent)
                            if newEvent.status == EventStatus.Accept || newEvent.status == EventStatus.Created {
                                if let eve = nextEvent {
                                    if newEvent.start_date < eve.start_date {
                                        nextEvent = newEvent
                                    }
                                } else {
                                    nextEvent = newEvent
                                }
                            }
                        }
                        if let tab = sharedTab2 {
                            tab.currentEvent = nextEvent
                            tab.eventDidUpdate()
                        }
                        self.inboxEvents = newInboxEvents
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
    
    func putRead(userEventID:String){
        var input:NSMutableDictionary = NSMutableDictionary()
        input["user_event_id"] = userEventID
        Tool.callREST(input, path: "events/read.json", method: "PUT", completionHandler: nil, errorHandler: nil)
    }
}

class Event:NSObject {
    var status:EventStatus = EventStatus.Invited
    var title:String = ""
    var profileUrl:String = ""
    var opened:Bool = false
    var medias:[NMedia] = []
    var uuid:String = ""
}

class InboxEvent:DetailedEvent, Previewable {
    var status:EventStatus = EventStatus.Invited
    var opened:Bool = false
    var owner_profile_url:String = ""
    var owner_name:String = ""
    var owner_phone_number:String = ""
    var cover_photo_url:String = ""
    var cover_video_url:String = ""
    var user_event_uuid:String = ""
    var sent_date:NSTimeInterval = NSTimeInterval()
    var true_start_date:NSTimeInterval = NSTimeInterval()
    var thumbnail_url:String = ""
}

class NMedia:NSObject {
    var uuid:String = ""
}

class NVideo:NMedia {
    var vidurl:String = ""
    var thumbnailurl:String = ""
}

class NImage:NMedia {
    var imgurl:String = ""
}