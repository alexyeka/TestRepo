//
//  SenderTableCell.swift
//  Nenzo
//
//  Created by sloot on 6/13/15.
//
//

import UIKit
@objc(SenderTableCellDelegate)
protocol SenderTableCellDelegate{
    func addSenderPressed(sender:SenderTableCell)
    func removeSenderPressed(sender:SenderTableCell)
}
class SenderTableCell: UITableViewCell {

    @IBOutlet var myTextLabel: UILabel!
    
    @IBOutlet var myAddButton: UIButton!
    
    weak var delegate:SenderTableCellDelegate?
    
    weak var phoneContact:PhoneContact?
    
    weak var nenzoContact:NenzoContact?
    
    @IBOutlet var profileIconImageView: NUIImageView!
    
    @IBOutlet var phoneIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileIconImageView.loadedView = self
        profileIconImageView.cropCircular()
        profileIconImageView.layer.borderWidth = 2.0
        profileIconImageView.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addButtonPressed(sender: UIButton) {
        sender.selected = !sender.selected
        if let dgt = delegate {
            if sender.selected {
                dgt.addSenderPressed(self)
            } else {
                dgt.removeSenderPressed(self)
            }
        }
    }
}
