//
//  EventPeopleCell.swift
//  Nenzo
//
//  Created by sloot on 6/24/15.
//
//

import UIKit

class EventPeopleCell: UICollectionViewCell {
    
    @IBOutlet var myImageView: UIImageView!
    
    @IBOutlet var acceptImageView: UIImageView!
    
    @IBOutlet var undecidedImageView: UIImageView!
    
    @IBOutlet var errorImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        undecidedImageView.hidden = false
        myImageView.cropCircular()
        myImageView.layer.borderColor = UIColor.whiteColor().CGColor
        myImageView.layer.borderWidth = 3.0
    }
    
    func setup(user:InvitedUser){
        myImageView.smartLoad(user.profile_url)
        if user.status == .Invited {
            errorImageView.hidden = true
            acceptImageView.hidden = true
            undecidedImageView.hidden = false
        } else if user.status == .Accept {
            errorImageView.hidden = true
            acceptImageView.hidden = false
            undecidedImageView.hidden = true
        } else if user.status == .Decline {
            errorImageView.hidden = false
            acceptImageView.hidden = true
            undecidedImageView.hidden = true
        }
    }
}
