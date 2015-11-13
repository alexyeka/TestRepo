//
//  TabSharedBottomBarView.swift
//  Nenzo
//
//  Created by sloot on 5/27/15.
//
//

let ORANGE:UIColor = UIColor(red: 255.0/255.0, green: 168.0/255.0, blue: 0, alpha: 1.0)
let LIGHT_GRAY:UIColor = UIColor(red: 176.0/255.0, green: 171.0/255.0, blue: 171.0/255.0, alpha: 1.0)

import UIKit
@objc(TabSharedBottomBarViewDelegate)
protocol TabSharedBottomBarViewDelegate{
    func tabChanged(from:Int, to:Int)
}
class TabSharedBottomBarView: UIView {
    
    var delegate:TabSharedBottomBarViewDelegate?
    
//    let unselectedImageArray:[UIImage] = createImageArray("")
//    let selectedImageArray:[UIImage] = createImageArray("-blue")
    
    var currentButtonTag:Int = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    private func setUp(){
        toggleButtonWithTag(currentButtonTag, enableTouch: false)
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        selectTab(sender.tag)
    }
    
    func selectTab(tab:Int){
        if(tab != currentButtonTag){
            toggleButtonWithTag(tab, enableTouch: false)
            toggleButtonWithTag(currentButtonTag, enableTouch: true)
            if let theDelegate = self.delegate{
                theDelegate.tabChanged(currentButtonTag, to: tab)
            }
            currentButtonTag = tab
        }
    }
    
    func selectTabDisplay(tab:Int){
        if(tab != currentButtonTag){
            toggleButtonWithTag(tab, enableTouch: false)
            toggleButtonWithTag(currentButtonTag, enableTouch: true)
            currentButtonTag = tab
        }
    }
    
    private func toggleButtonWithTag(tag:Int, enableTouch:Bool){
        var toggleButton:UIButton = (viewWithTag(tag) as! UIButton)
        toggleButton.userInteractionEnabled = enableTouch
        toggleButton.selected = !enableTouch
//        var toggleLabel:UILabel = (viewWithTag(-tag) as! UILabel)
//        toggleLabel.textColor = enableTouch ? LIGHT_GRAY : ORANGE
    }
}

//private let prefix:String = "tab-"
//
//private let tabNames:[String] = ["speed", "boards", "explore", "favorites", "profile"]
//
//private func createImageArray(appendString:String) -> [UIImage]{
//    var imageArray:[UIImage] = []
//    for tabName in tabNames {
//        imageArray.append(UIImage(named: prefix + tabName + appendString)!)
//    }
//    return imageArray
//}