//
//  PastEventMediaPreviewView.swift
//  Nenzo
//
//  Created by sloot on 6/28/15.
//
//

import UIKit

class PastEventMediaPreviewView: UIView {

    @IBOutlet var myImageView: UIImageView!
    
    @IBOutlet var myVideoView: UIVideoView!
    
    func setup(){

    }
    
    @IBAction func backPressed(sender: UIButton) {
        removeFromSuperview()
    }

    @IBAction func stashPressed(sender: UIButton) {
        println("Stashed!")
    }
}
