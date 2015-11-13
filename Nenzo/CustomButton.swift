////
////  CustomButton.swift
////  Nenzo
////
////  Created by sloot on 6/28/15.
////
////
//
//import UIKit
//
//@IBDesignable class CustomButton: UIButton {
//
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
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
//    
//    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
//        if !locked {
//            let bundle = NSBundle(forClass: self.dynamicType)
//            var options:NSMutableDictionary = NSMutableDictionary()
//            var config:NSMutableDictionary = NSMutableDictionary()
//            config["m"] = "k"
//            options[UINibExternalObjects] = config
//            var view = loadWithSafe(){return bundle.loadNibNamed("CustomButton", owner: self, options: nil)[0]} as! CustomButton
//            view.setTranslatesAutoresizingMaskIntoConstraints(false)
//            if let tl = titleLabel {
//                view.setTitle(tl.text, forState: .Normal)
//            }
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
//        var view = bundle.loadNibNamed("CustomButton", owner: self, options: nil)[0] as! CustomButton
//        view.frame = self.bounds
//        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
//        if let tl = titleLabel {
//            view.setTitle("cat", forState: .Normal)
//        } else {
//            view.setTitle("monkey", forState: .Normal)
//        }
//        self.addSubview(view)
//    }
//}
//
//var locked:Bool = false
//
//func loadWithSafe(todo:(()->AnyObject?)) -> AnyObject?{
//    locked = true
//    var button: AnyObject? = todo()
//    locked = false
//    return button
//}