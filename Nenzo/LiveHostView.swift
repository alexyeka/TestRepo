//
//  LiveHostView.swift
//  Nenzo
//
//  Created by sloot on 6/28/15.
//
//

import UIKit

class LiveHostView: UIView {

    @IBOutlet var eventTitleLabel: UILabel!

    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var myImageView: NUIImageView!
    
    @IBOutlet var bodyBottomView: UIView!
    
    @IBOutlet var bodyTopView: UIView!
    
    @IBOutlet var bodyMiddleView: UIView!
    
    @IBOutlet var myCollectionView: UICollectionView!
    
    @IBOutlet var bottomHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var ownerBottomView: UIView!
    
    @IBOutlet var loadingView: UIView!
    
    var originalCollectionViewFrame:CGRect!
    
    var fullCollectionViewFrame:CGRect!
    
    var myTimer:NSTimer = NSTimer()
    
    var eventTime:NSDate = NSDate(timeIntervalSinceNow: 20000)
    
    var invitedUsers:[InvitedUser] = []
    
    var isAnimating:Bool = false
    
    var currentEvent:InboxEvent?
    
    var collectionViewIsExpanded:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var peopleCellNib:UINib = UINib(nibName: "EventPeopleCell", bundle: nil)
        myCollectionView.registerNib(peopleCellNib, forCellWithReuseIdentifier: "PeopleCell")
        var peopleInitialCellNib:UINib = UINib(nibName: "EventPeopleInitialCell", bundle: nil)
        myCollectionView.registerNib(peopleInitialCellNib, forCellWithReuseIdentifier: "PeopleInitialCell")
        myImageView.loadingView = loadingView
        myImageView.label1 = eventTitleLabel
        myImageView.label2 = timeLabel
    }
    
    func setupOwner(){
        bottomHeightConstraint.constant = 60.0
        updateConstraintsIfNeeded()
        resetup()
        ownerBottomView.hidden = false
    }
    
    func setupGuest(){
        bottomHeightConstraint.constant = 0.0
        updateConstraintsIfNeeded()
        resetup()
        ownerBottomView.hidden = true
    }
    
    func resetup(){
        if let cEvent = currentEvent {
            eventTime = NSDate(timeIntervalSince1970: cEvent.true_start_date)
            if eventTime.timeIntervalSinceNow <= 0 {
                timeLabel.text = "Currently Live!"
                if let vc = Tool.sharedInstance.myViewController where vc.currentTab == 2 {
                    vc.showCameraView(self, type: CameraViewType.Multiple) //.backButton.hidden = true
                }
            } else {
                println("is not live")
            }
            if cEvent.cover_video_url == "/cover_videos/original/missing.png" {
                myImageView.smartLoad(cEvent.cover_photo_url)
            } else {
                myImageView.smartLoad(cEvent.thumbnail_url)
                UIVideoView.preload(cEvent.cover_video_url)
                //myImageView.smartVideoThumbLoad(event.cover_video_url)
            }
            eventTitleLabel.hidden = false
        } else {
            eventTitleLabel.hidden = true
            myImageView.image = nil
        }
        self.bodyMiddleView.hidden = false
        self.myCollectionView.setContentOffset(CGPointZero, animated: true)
        collectionViewIsExpanded = false
        self.bodyMiddleView.alpha = 1.0
        self.myCollectionView.scrollEnabled = false
        self.removeUpdate()
        self.registerUpdate()
        self.layoutIfNeeded()
        setup()
    }
    
    func registerUpdate(){
        refreshDisplay()
        myTimer = NSTimer(timeInterval: 1, target: self, selector: "refreshDisplay", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(myTimer, forMode: NSDefaultRunLoopMode)
    }
    
    func removeUpdate(){
        myTimer.invalidate()
    }
    
    func refreshDisplay(){
        var timeLeft:NSTimeInterval = eventTime.timeIntervalSinceNow
        if timeLeft <= 0 {
            if let vc = Tool.sharedInstance.myViewController where vc.currentTab == 2 {
                vc.showCameraView(self, type: CameraViewType.Multiple) //.backButton.hidden = true
            }
            removeUpdate()
        } else {
            var timeStr = stringFromTimeInterval(timeLeft)
            timeLabel.text = timeStr as String
        }
    }
    
    func setup(){
        originalCollectionViewFrame = bodyBottomView.frame
        fullCollectionViewFrame = CGRectMake(bodyBottomView.frame.origin.x, bodyTopView.frame.height, bodyBottomView.frame.width, bodyBottomView.frame.origin.y - bodyTopView.frame.height)
    }
    
    func addAttachment(videoURL:NSURL?, event_image:UIImage?){
        if let event = currentEvent {
            var input:[MultiPartFormObject] = []
            var eventIDMPObj:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: event.uuid, key: "event_id")
            input.append(eventIDMPObj)
            if let newVideoURL = videoURL, vidData = NSData(contentsOfURL: newVideoURL) {
                var newVid:MultiPartFormObject = MultiPartFormObject(containsImage: true, data: vidData, key: "file")
                input.append(newVid)
                if let newCoverImage = event_image {
                    let imgData:NSData = UIImagePNGRepresentation(newCoverImage)
                    var newImg:MultiPartFormObject = MultiPartFormObject(containsImage: true, data: imgData, key: "thumbnail")
                    input.append(newImg)
                }
                var relation:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: "video", key: "relation")
                input.append(relation)
            } else if let newCoverImage = event_image {
                let imgData:NSData = UIImagePNGRepresentation(newCoverImage)
                var newImg:MultiPartFormObject = MultiPartFormObject(containsImage: true, data: imgData, key: "file")
                input.append(newImg)
                var relation:MultiPartFormObject = MultiPartFormObject(containsImage: false, data: "photo", key: "relation")
                input.append(relation)
            }
            Tool.callMPREST(input, path: "events/add_attachment.json", method: "POST", completionHandler: { (json) -> Void in
                if let myJson = json, status = myJson["status"] as? String {
                    println(myJson)
//                    if status == "success" {
//                        if let errorArr = myJson["message"] as? [String] where errorArr.count > 0 {
//                            for err in errorArr {
//                                self.showError(err)
//                            }
//                        } else {
//                            self.showError("Server Error")
//                        }
//                    } else {
//                        println("gucci")
//                    }
                } else {
                    self.showError("Internet Error")
                }
                }, errorHandler: nil)
        }
    }
}

extension LiveHostView : CameraViewDelegate {
    func didSelectCircularImage(img: UIImage, wholeImg: UIImage) {
        println("ERROR: LiveHost Recieved circular image")
    }
    func didSelectImage(img: UIImage) {
        println("img")
        addAttachment(nil, event_image: img)
        recamera()
    }
    
    func didSelectVideo(videourl: NSURL, img: UIImage) {
        println("vid")
        addAttachment(videourl, event_image: img)
        recamera()
    }
    
    func recamera(){
        if let vc = Tool.sharedInstance.myViewController where vc.currentTab == 2 {
            vc.showCameraView(self, type: CameraViewType.Multiple) //.backButton.hidden = true
        }
    }
}

extension LiveHostView :  UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return invitedUsers.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell!
        if indexPath.row == 0 {
            let newCell = collectionView.dequeueReusableCellWithReuseIdentifier("PeopleInitialCell", forIndexPath: indexPath) as! EventPeopleInitialCell
            newCell.delegate = self
            newCell.myButton.setTitle("\(invitedUsers.count)", forState: .Normal)
            cell = newCell
        } else {
            let newCell = collectionView.dequeueReusableCellWithReuseIdentifier("PeopleCell", forIndexPath: indexPath) as! EventPeopleCell
            cell = newCell
            newCell.setup(invitedUsers[indexPath.row - 1])
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

extension LiveHostView : EventPeopleInitialCellDelegate {
    func initialCellPressed() {
        if !isAnimating {
            isAnimating = true
            collectionViewIsExpanded = !collectionViewIsExpanded
            if !collectionViewIsExpanded {
                self.bodyMiddleView.hidden = false
                self.myCollectionView.setContentOffset(CGPointZero, animated: true)
            } else {
                removeUpdate()
            }
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                if self.collectionViewIsExpanded {
                    self.bodyBottomView.frame = self.fullCollectionViewFrame
//                    self.bodyTopView.alpha = 0.0
                    self.bodyMiddleView.alpha = 0.0
                } else {
                    self.bodyBottomView.frame = self.originalCollectionViewFrame
//                    self.bodyTopView.alpha = 1.0
                    self.bodyMiddleView.alpha = 1.0
                    
                }
                }){ (done) -> Void in
                    if self.collectionViewIsExpanded {
//                        self.bodyTopView.hidden = true
                        self.bodyMiddleView.hidden = true
                        self.myCollectionView.scrollEnabled = true
                    } else {
                        self.myCollectionView.scrollEnabled = false
                        self.registerUpdate()
                    }
                    self.isAnimating = false
            }
        }
    }
}

extension LiveHostView {
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
}

func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
    
    var ti = NSInteger(interval)

    var seconds = ti % 60
    var minutes = (ti / 60) % 60
    var hours = (ti / 3600)
    
    return "\(hours)h \(minutes)m \(seconds)s"
}