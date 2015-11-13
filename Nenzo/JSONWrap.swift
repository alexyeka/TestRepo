//
//  JSONWrap.swift
//  Nenzo
//
//  Created by sloot on 6/25/15.
//
//

import Foundation

class NEvent:NSObject {
    var title:String = ""
    var date:String = ""
    var time:String = ""
    var location:String = ""
    var fee:String = ""
    var detail:String = ""
    var photoURL:String = ""
    var videoURL:String = ""
    var people:[NPerson] = []
}

class NPerson:NSObject {
    var status:EventStatus = .Invited
    var name:String = ""
    var profileURL:String = ""
}

enum EventStatus:Int{
    case Decline = -1,
    Invited = 0,
    Accept = 1,
    Created = 2
}

class PhoneContact:NSObject {
    var name:String = ""
    var phoneNumbers:[String] = []
    var profile_url:String?
    var uuid:String?
    var selected:Bool = false
}

class NenzoContact:NSObject {
    var name:String = "Alexis Done"
}