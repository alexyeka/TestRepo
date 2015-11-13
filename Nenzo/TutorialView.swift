//
//  TutorialView.swift
//  Nenzo
//
//  Created by sloot on 6/19/15.
//
//

import UIKit

class TutorialView: UIView {

    @IBOutlet var myScrollView: UIScrollView!
    
    var pageControlBeingUsed:Bool = false
    
    var currentPage:Int = 0
    
    @IBOutlet var pageControlContainerView: UIView!
    /*
    Adds the 4 tutorial views inside of the scroll view
    */
    func setUpScrollView(){
        for (var i = 0; i < 4; i++) {
            var frame:CGRect = CGRect(origin: CGPoint(x: (getMainWindowView().frame.width*CGFloat(i)), y: 0), size: self.frame.size)
            let subView:UIView = "Slide\(i + 1)".loadNib() as! UIView
            subView.frame = frame
//            if let textView = subView.textView {
//                textView.addCustomShadow(0.34)
//            }
//            if let textLabel = subView.textLabel {
//                if(i == 3){
//                    textLabel.addCustomShadow(0.34)
//                }
//                else{
//                    textLabel.addCustomShadow(0.44)
//                }
//            }
            myScrollView.addSubview(subView)
        }
        myScrollView.contentSize = CGSizeMake(getMainWindowView().frame.width * CGFloat(4), self.frame.height);
        myScrollView.bounces = false
    }
    
    func tutorialSlideSwitched(page:Int){
        if let sender = pageControlContainerView.viewWithTag(page) as? UIButton {
            sender.selected = true
            getCurrenButton().selected = false
            if let vc = Tool.sharedInstance.myViewController {
                vc.sharedBottom.selectTabDisplay(page + 1)
            }
            currentButton = sender
        }
    }
    
    @IBOutlet var firstSlideButton: UIButton!
    
    weak var currentButton:UIButton?
    
    func getCurrenButton() -> UIButton {
        if let cb = currentButton {
            return cb
        } else {
            return firstSlideButton
        }
    }
    
    func switchToSlide(slide:Int){
        if getCurrenButton().tag != slide {
            pageControlBeingUsed = true
            tutorialSlideSwitched(slide)
            let frame:CGRect = CGRect(origin: CGPoint(x: getMainWindowView().frame.width * CGFloat(slide), y: 0), size: self.frame.size)
            myScrollView.scrollRectToVisible(frame, animated: true)
        }
    }
    
    @IBAction func slide1Pressed(sender: UIButton) {
        switchToSlide(sender.tag)
    }
    
    @IBAction func slide2Pressed(sender: UIButton) {
        switchToSlide(sender.tag)
    }
    
    @IBAction func slide3Pressed(sender: UIButton) {
        switchToSlide(sender.tag)
    }
    
    @IBAction func slide4Pressed(sender: UIButton) {
        switchToSlide(sender.tag)
    }
}

extension TutorialView : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(!pageControlBeingUsed){
            let pageWidth:CGFloat = getMainWindowView().frame.width
            let dbl:Double = Double(1.0+(scrollView.contentOffset.x - getMainWindowView().frame.width/2.0)/getMainWindowView().frame.width)
            let page:Int = Int(dbl)
            if(page != getCurrenButton().tag){
                tutorialSlideSwitched(page)
            }
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pageControlBeingUsed = false
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        pageControlBeingUsed = false
    }
}