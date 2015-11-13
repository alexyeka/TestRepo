//
//  PastEventStoryView.swift
//  Nenzo
//
//  Created by sloot on 6/26/15.
//
//

import UIKit

class PastEventStoryView: UIView {

    @IBOutlet var myBGImageView: UIImageView!

    @IBOutlet var myVideoView: UIVideoView!
    
    @IBOutlet var myProfileIconView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var progressView: UIView!
    
    weak var currentMedia:NMedia?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myVideoView.delegate = self
        if let tab4 = sharedTab4 {
            event = tab4.selectedEvent
            myProfileIconView.smartLoad(tab4.selectedEvent.owner_profile_url)
            nameLabel.text = tab4.selectedEvent.owner_name
            currentMedia = event?.medias.first
            if let media = event?.medias.first as? NImage {
                myBGImageView.smartLoad(media.imgurl)
                myVideoView.hidden = true
            }
            if let media = event?.medias.first as? NVideo {
                myBGImageView.image = nil
                myVideoView.smartVideoLoad(media.vidurl)
                myVideoView.hidden = false
            }
        }
        myProfileIconView.cropCircular()
        myProfileIconView.layer.borderColor = UIColor.whiteColor().CGColor
        myProfileIconView.layer.borderWidth = 3.0
        addRightSwipe("rightSwiped")
        addLeftSwipe("leftSwiped")
    }
    
    @IBAction func backPressed(sender: UIButton) {
        endTimer()
        removeFromSuperview()
    }
    
    var seconds:CGFloat = 1.0
    var step:CGFloat = 0.01
    var backLock:CGFloat = 0.5
    
    var progressAmount:CGFloat = 0
    var progressTimer = NSTimer()
    
    var index:Int = 0
    
    var event:PastEvent?
    
    func startTimer(){
        if let e = event {
            progressTimer = NSTimer(timeInterval: NSTimeInterval(step), target: self, selector: "progressTimeDidUpdate", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(progressTimer, forMode: NSDefaultRunLoopMode)
        }
    }
    
    func endTimer(){
        myVideoView.stop()
        progressTimer.invalidate()
        progressAmount = 0.0
        resetProgressBar()
    }
    
    func progressTimeDidUpdate(){
        if let e = event {
            progressAmount = progressAmount + step/seconds
            progressView.frame = CGRectMake(progressView.frame.origin.x, progressView.frame.origin.y, (frame.width * progressAmount), progressView.frame.height)
            if  progressView.frame.width >= frame.width {
                index += 1
                showSlide()
                resetProgressBar()
            }
        }
    }
    
    func showSlide(){
        if let e = event {
            if index < e.medias.count {
                currentMedia = e.medias[index]
                if let media = e.medias[index] as? NImage {
                    seconds = 1.0
                    myBGImageView.smartLoad(media.imgurl)
                    myVideoView.hidden = true
                    myVideoView.stop()
                }
                if let media = e.medias[index] as? NVideo {
                    if UIVideoView.isLoaded(media.vidurl) {
                        seconds = 5.0
                        myBGImageView.image = nil
                        myVideoView.stop()
                        myVideoView.smartVideoLoad(media.vidurl)
                        myVideoView.hidden = false
                    } else {
                        index += 1
                        showSlide()
                    }
                }
            } else {
                endTimer()
            }
        }
    }
    
    func rightSwiped(){
        if let e = event {
            var shouldGoBack = progressView.frame.width <= frame.width * backLock / seconds
            endTimer()
            if shouldGoBack {
                if index > 0 {
                    index -= 1
                    showSlide()
                }
            } else if let media = currentMedia as? NVideo {
                myVideoView.replay()
            }
            startTimer()
        }
    }
    
    func leftSwiped(){
        if let e = event {
            endTimer()
            var shouldSkip = index + 1 < e.medias.count
            if shouldSkip {
                index += 1
                showSlide()
                startTimer()
            }
        }
    }
    
    func resetProgressBar(){
        progressAmount = 0.0
        progressView.frame = CGRectMake(progressView.frame.origin.x, progressView.frame.origin.y, 0, progressView.frame.height)
    }
}

extension PastEventStoryView : UIVideoViewDelegate {
    func videoShouldPlay(withDuration: Float64) -> Bool {
        seconds = CGFloat(withDuration)
        if seconds > 5 {
            seconds = 5
        }
        return true
    }
}