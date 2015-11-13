//
//  Tab2.swift
//  Nenzo
//
//  Created by sloot on 5/27/15.
//
//

import UIKit

weak var sharedTab2:Tab2?

class Tab2: UIView {
    weak var hostView:LiveHostView?
    
    var currentEvent:InboxEvent?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedTab2 = self
    }
    
    func refresh(){
        if let tab = sharedTab1 {
            showLoading()
            tab.refresh()
        }
    }
    
    func eventDidUpdate(){
        if let eve = currentEvent {
            if hostView == nil {
                hostView = "LiveHostView".loadNib() as? LiveHostView
                hostView!.frame = self.frame
                hostView!.layoutIfNeeded()
                addSubview(hostView!)
            }
            if let hView = hostView {
//                if eve.status == .Created {
//                    hView.setupOwner()
//                } else {
                    hView.setupGuest()
//                }
                hView.currentEvent = currentEvent
                hView.eventTitleLabel.text = eve.title
                hView.getEventUsers(eve.uuid)
            }
        } else {
            if let hView = hostView {
                hView.removeFromSuperview()
            }
        }
    }
//    override init(frame: CGRect) {
//        // 1. setup any properties here
//        
//        // 2. call super.init(frame:)
//        super.init(frame: frame)
//        
//        // 3. Setup view from .xib file
//        xibSetup()
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        // 1. setup any properties here
//        
//        // 2. call super.init(coder:)
//        super.init(coder: aDecoder)
//        
//        // 3. Setup view from .xib file
//        if m {
//            m = false
//                    xibSetup()
//        }
//    }
    
//    @IBInspectable var cornerRadius: CGFloat = 0 {
//        didSet {
//            layer.cornerRadius = cornerRadius
//            layer.masksToBounds = cornerRadius > 0
//        }
//    }
//    @IBInspectable var borderWidth: CGFloat = 0 {
//        didSet {
//            layer.borderWidth = borderWidth
//        }
//    }
//    @IBInspectable var borderColor: UIColor? {
//        didSet {
//            layer.borderColor = borderColor?.CGColor
//        }
//    }
    
//    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
//        if self.subviews.count == 0 {
//            let bundle = NSBundle(forClass: self.dynamicType)
//            var view = bundle.loadNibNamed("Tab2", owner: nil, options: nil)[0] as! Tab2
//            view.setTranslatesAutoresizingMaskIntoConstraints(false)
//            let contraints = self.constraints()
//            self.removeConstraints(contraints)
//            view.addConstraints(contraints)
//            return view
//        } else {
//            return self
//        }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        let bundle = NSBundle(forClass: self.dynamicType)
//        var view = bundle.loadNibNamed("Tab2", owner: nil, options: nil)[0] as! Tab2
//        view.frame = self.bounds
//        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
//        self.addSubview(view)
//    }

//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
}

extension Tab2: TabDelegate {

    func showSlide() {
        refresh()
    }
    func removeSlide() {
    }
}