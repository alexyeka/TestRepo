//
//  PastEventCell.swift
//  Nenzo
//
//  Created by sloot on 6/26/15.
//
//

import UIKit

class PastEventCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateContainerView.layer.cornerRadius = 20.0
        dateContainerView.clipsToBounds = true
        dateContainerView.layer.borderColor = UIColor.whiteColor().CGColor
        dateContainerView.layer.borderWidth = 2.0
        myBGImageView.loadingView = loadingView
        myBGImageView.label1 = dayLabel
        myBGImageView.label2 = titleLabel
        myBGImageView.borderView1 = dateContainerView
    }
    
    func setup(event:PastEvent) {
        titleLabel.text = event.title
        let date:NSDate = NSDate(timeIntervalSince1970: event.true_end_date)
        monthLabel.text = date.getMonth()
        dayLabel.text = date.getDay()
        if event.cover_video_url == "/cover_videos/original/missing.png" {
            myBGImageView.smartLoad(event.cover_photo_url)
        } else {
            println(NSDate().timeIntervalSince1970)
            myBGImageView.smartLoad(event.thumbnail_url)
            //myBGImageView.smartVideoThumbLoad(event.cover_video_url)
        }
    }
    
    @IBOutlet var myBGImageView: NUIImageView!
    
    @IBOutlet var loadingView: UIView!
    
    @IBOutlet var dateContainerView: UIView!
    
    @IBOutlet var monthLabel: UILabel!
    
    @IBOutlet var dayLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    
}
