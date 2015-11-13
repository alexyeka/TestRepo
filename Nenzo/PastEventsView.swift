//
//  PastEventsView.swift
//  Nenzo
//
//  Created by sloot on 6/26/15.
//
//

import UIKit

class PastEventsView: UIView {

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var myCollectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        var eventCellNib:UINib = UINib(nibName: "PastEventMediaCell", bundle: nil)
        myCollectionView.registerNib(eventCellNib, forCellWithReuseIdentifier: "PastEventMediaCell")
        var eventInitialCellNib:UINib = UINib(nibName: "PastEventMediaInitialCell", bundle: nil)
        myCollectionView.registerNib(eventInitialCellNib, forCellWithReuseIdentifier: "PastEventMediaInitialCell")
    }
    
    @IBAction func backPressed(sender: UIButton) {
        removeFromSuperview()
    }
}


extension PastEventsView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let tab4 = sharedTab4, event = tab4.selectedEvent {
            return event.medias.count + 1
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell!
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("PastEventMediaInitialCell", forIndexPath: indexPath) as! PastEventMediaInitialCell
        } else {
            var newcell = collectionView.dequeueReusableCellWithReuseIdentifier("PastEventMediaCell", forIndexPath: indexPath) as! PastEventMediaCell
            cell = newcell
            if let tab4 = sharedTab4 {
                if let media = tab4.selectedEvent.medias[indexPath.row - 1] as? NImage {
                    newcell.myImageView.smartLoad(media.imgurl)
                }
                if let media = tab4.selectedEvent.medias[indexPath.row - 1] as? NVideo {
                    newcell.myImageView.smartLoad(media.thumbnailurl)
                    UIVideoView.preload(media.vidurl)
                    //newcell.myImageView.smartVideoThumbLoad(media.vidurl)
                }
            }
        }
        //cell.setup(events[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
            
            var returnSize:CGSize!
            returnSize = CGSize(width: (self.frame.width)/4.0, height: (self.frame.width)/4.0)
            
            return returnSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let tab4 = sharedTab4 {
            tab4.didSelectItem(indexPath)
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