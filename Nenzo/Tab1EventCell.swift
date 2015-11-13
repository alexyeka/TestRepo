//
//  Tab1EventCell.swift
//  Nenzo
//
//  Created by sloot on 5/28/15.
//
//

import UIKit

class Tab1EventCell: UICollectionViewCell {
    
    @IBOutlet var myImageView: NUIImageView!
    
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var profileImageBorderView: UIView!
    
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var stasheImageView: UIImageView!
    
    @IBOutlet var darkOverlayView: UIView!
    
    @IBOutlet var loadingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.cropCircular()
        profileImageBorderView.layer.cornerRadius = profileImageBorderView.frame.width/2.0
        profileImageBorderView.clipsToBounds = true
        myImageView.loadingView = loadingView
        myImageView.label1 = titleLabel
        myImageView.label2 = statusLabel
        myImageView.view1 = profileImageBorderView
    }
    
    func setup(event:InboxEvent){
        switch event.status {
        case .Created:
            created()
        case .Accept:
            accept()
        case .Invited:
            invited(event.owner_name)
        case .Decline:
            decline()
        default:
            println("Invalid event status")
        }
        titleLabel.text = event.title
        profileImageBorderView.backgroundColor = event.opened ? UIColor.whiteColor() : ORANGE
        profileImageView.smartLoad(event.owner_profile_url, blur: true)
        if event.cover_video_url == "/cover_videos/original/missing.png" {
            myImageView.smartLoad(event.cover_photo_url)
        } else {
            myImageView.smartLoad(event.thumbnail_url)
            UIVideoView.preload(event.cover_video_url)
            //myImageView.smartVideoThumbLoad(event.cover_video_url)
        }
    }
    
    func created(){
        statusLabel.text = ""
        stasheImageView.hidden = false
        iconImageView.image = YESICON
    }
    
    func invited(name:String){
        statusLabel.text = "\(name) Invited You To"
        stasheImageView.hidden = true
        iconImageView.image = nil
    }
    
    func accept(){
        statusLabel.text = "You are attending to"
        stasheImageView.hidden = true
        iconImageView.image = YESICON
    }
    
    func decline(){
        statusLabel.text = "You are not attending to"
        stasheImageView.hidden = true
        iconImageView.image = NOICON
    }
}

let NOICON:UIImage? = UIImage(named: "Error_x1")
let YESICON:UIImage? = UIImage(named: "Check_x1")