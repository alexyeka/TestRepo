//
//  EventPeopleInitialCell.swift
//  Nenzo
//
//  Created by sloot on 6/24/15.
//
//

import UIKit
@objc(EventPeopleInitialCellDelegate)
protocol EventPeopleInitialCellDelegate{
    func initialCellPressed()
}
class EventPeopleInitialCell: UICollectionViewCell {
    
    @IBOutlet var myButton: UIButton!
    
    weak var delegate:EventPeopleInitialCellDelegate?
    
    @IBAction func myButtonPressed(sender: UIButton) {
        if let dgt = delegate {
            dgt.initialCellPressed()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myButton.cropCircular()
        myButton.layer.borderColor = UIColor.whiteColor().CGColor
        myButton.layer.borderWidth = 3.0
    }
}
