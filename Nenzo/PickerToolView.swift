//
//  DatePickerToolView.swift
//  Nenzo
//
//  Created by sloot on 6/10/15.
//
//

import UIKit
@objc(PickerToolViewDelegate)
protocol PickerToolViewDelegate{
    func pickerPressedBack(ptv:PickerToolView)
    func pickerPressedNext(ptv:PickerToolView)
    func pickerPressedDone(ptv:PickerToolView)
}
class PickerToolView: UIView {
    
    weak var delegate:PickerToolViewDelegate?
    
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var doneButton: UIButton!
    
    var nextEnabled:Bool = true {
        didSet {
            nextButton.hidden = !nextEnabled
        }
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        if let dgt = delegate {
            dgt.pickerPressedBack(self)
        }
    }

    @IBAction func nextPressed(sender: AnyObject) {
        if let dgt = delegate {
            dgt.pickerPressedNext(self)
        }
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        if let dgt = delegate {
            dgt.pickerPressedDone(self)
        }
    }
    
}
