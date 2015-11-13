//
//  Tab4.swift
//  Nenzo
//
//  Created by sloot on 5/27/15.
//
//
weak var sharedTab4:Tab4?

let TAB4_CELL_HEIGHT:CGFloat = 127.0

import UIKit

class Tab4: UIView {

    @IBOutlet var myCollectionView: UICollectionView!

    var events:[PastEvent] = []
    
    weak var selectedEvent:PastEvent!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedTab4 = self
        var eventCellNib:UINib = UINib(nibName: "PastEventCell", bundle: nil)
        myCollectionView.registerNib(eventCellNib, forCellWithReuseIdentifier: "PastEventCell")
    }
    
    weak var pastEventsView:PastEventsView?
    weak var pastEventStoryView:PastEventStoryView?
    weak var pastEventMediaPreviewView:PastEventMediaPreviewView?
    var isBusy:Bool = false
    
    func showPastEvents(){
        getAttachments(selectedEvent)
        if pastEventsView == nil {
            pastEventsView = "PastEventsView".loadNib() as? PastEventsView
            pastEventsView!.frame = self.frame
            pastEventsView!.titleLabel.text = selectedEvent.title
            addSubview(pastEventsView!)
        }
    }
    
    func showPastEventStory(){
        if pastEventStoryView == nil {
            pastEventStoryView = "PastEventStoryView".loadNib() as? PastEventStoryView
            pastEventStoryView!.frame = getMainWindowView().frame
            getMainWindowView().addSubview(pastEventStoryView!)
            pastEventStoryView!.startTimer()
        }
    }
    
    func showPastEventMediaPreview(index:Int){
        if pastEventMediaPreviewView == nil {
            pastEventMediaPreviewView = "PastEventMediaPreviewView".loadNib() as? PastEventMediaPreviewView
            pastEventMediaPreviewView!.frame = getMainWindowView().frame
            if index < selectedEvent.medias.count {
                if let media = selectedEvent.medias[index] as? NImage {
                    pastEventMediaPreviewView!.myImageView.smartLoad(media.imgurl)
                }
                if let media = selectedEvent.medias[index] as? NVideo {
                    pastEventMediaPreviewView!.myVideoView.smartVideoLoad(media.vidurl)
                }
            }
            getMainWindowView().addSubview(pastEventMediaPreviewView!)
        }
    }
    
    func didSelectItem(indexPath:NSIndexPath){
        if indexPath.row == 0 {
            showPastEventStory()
        } else {
            showPastEventMediaPreview(indexPath.row - 1)
        }
    }
}

extension Tab4: TabDelegate {
    func showSlide() {
        getPastEvents()
    }
    func removeSlide() {
    }
}

extension Tab4: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:PastEventCell!
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("PastEventCell", forIndexPath: indexPath) as! PastEventCell
        //applyBlurEffect(cell.myBGImageView)
        cell.setup(events[indexPath.row])
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
        selectedEvent = events[indexPath.row]
        showPastEvents()
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

class PastEvent {
    var title:String = ""
    var uuid:String = ""
    var status:EventStatus = EventStatus.Accept
    var cover_photo_url:String = ""
    var cover_video_url:String = ""
    var thumbnail_url:String = ""
    var user_event_uuid:String = ""
    var end_date:NSTimeInterval = NSTimeInterval()
    var true_end_date:NSTimeInterval = NSTimeInterval()
    var medias:[NMedia] = []
    var owner_profile_url:String = ""
    var owner_name:String = ""
}

extension Tab4 {
    func getPastEvents(){
        println(NSDate().timeIntervalSince1970)
        if events.count == 0 {
            showLoading()
        }
        Tool.callREST(nil, path: "events/past.json", method: "GET", completionHandler: { (json) -> Void in
            removeLoading()
            if let myJson = json {
                if let status = myJson["status"] as? String {
                    println(NSDate().timeIntervalSince1970)
                    if let events = myJson["events"] as? [NSDictionary] where status == "success" {
                        var newPastEvents:[PastEvent] = []
                        for event in events {
                            var newEvent = PastEvent()
                            newEvent.title = event["title"] as? String ?? ""
                            newEvent.cover_photo_url = event["cover_photo_url"] as? String ?? ""
                            newEvent.cover_video_url = event["cover_video_url"] as? String ?? ""
                            newEvent.true_end_date = event["end_date"] as? NSTimeInterval ?? 0
                            newEvent.uuid = event["event_uuid"] as? String ?? ""
                            newEvent.user_event_uuid = event["user_event_uuid"] as? String ?? "invited"
                            newEvent.owner_profile_url = event["owner_profile_url"] as? String ?? ""
                            newEvent.owner_name = event["owner_name"] as? String ?? ""
                            newEvent.thumbnail_url = event["thumbnail_url"] as? String ?? ""
                            let myTimeZone:NSInteger = NSTimeZone.systemTimeZone().secondsFromGMT
                            newEvent.end_date =  newEvent.true_end_date + NSTimeInterval(myTimeZone)
                            var status = event["relation"] as? String ?? "accepted"
                            switch status {
                            case "created":
                                newEvent.status = EventStatus.Created
                            case "accepted":
                                newEvent.status = EventStatus.Accept
                            default:
                                break
                            }
                            newPastEvents.append(newEvent)
                        }
                        self.events = newPastEvents
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
    
    func getAttachments(pastEvent:PastEvent){
        println(NSDate().timeIntervalSince1970)
        Tool.callREST(nil, path: "events/get_attachments.json?event_id=\(pastEvent.uuid)", method: "GET", completionHandler: { (json) -> Void in
            if let myJson = json {
                println(NSDate().timeIntervalSince1970)
                if let status = myJson["status"] as? String {
                    if let attachments = myJson["attachments"] as? [NSDictionary] where status == "success" {
                        var newAttachments:[NMedia] = []
                        for attachment in attachments {
                            if let relation = attachment["relation"] as? String {
                                var newAttachment:NMedia!
                                if relation == "video" {
                                    let newVideo = NVideo()
                                    newVideo.vidurl = attachment["file"] as? String ?? ""
                                    newVideo.thumbnailurl = attachment["thumbnail"] as? String ?? ""
                                    newAttachment = newVideo
                                } else {
                                    let newImage = NImage()
                                    newImage.imgurl = attachment["file"] as? String ?? ""
                                    newAttachment = newImage
                                }
                                newAttachment.uuid = attachment["uuid"] as? String ?? ""
                                newAttachments.append(newAttachment)
                            }
                        }
                        pastEvent.medias = newAttachments
                        if let pView = self.pastEventsView {
                            println(NSDate().timeIntervalSince1970)
                            pView.myCollectionView.reloadData()
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