//
//  HangoutModelObj.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 8/24/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import Foundation

class HangoutModelObj: NSObject {
    
    var id: String?
    var organizer: String?
    var going: [String]?
    var notGoing: [String]?
    var location: String?
    var address: String?
    var date: NSTimeInterval?
    
    init(id: String, organizer: String, going: [String], notGoing: [String], location: String, address: String, date: NSTimeInterval){
        
        super.init()
        
        self.id = id
        self.organizer = organizer
        self.going = going
        self.notGoing = notGoing
        self.location = location
        self.address = address
        self.date = date
    }
    
    init(id: String, organizer: String, going: String, notGoing: String, location: String, address: String, minutes: Int){
        
        super.init()
        
        self.id = id
        self.organizer = organizer
        if going != ""{
            self.going = going.componentsSeparatedByString(",")
        }
        else{
            self.going = []
        }
        if notGoing != ""{
            self.notGoing = notGoing.componentsSeparatedByString(",")
        }
        else{
            self.notGoing = []
        }
        self.location = location
        self.address = address
        self.date = convertDate(minutes)
    }

    
    func convertDate(minutes: Int) -> NSTimeInterval{
        let date = NSDate()
        //let calendar = NSCalendar.currentCalendar()
        
        if minutes > 0{
            let date = date.dateByAddingTimeInterval(Double(minutes)*60.0)
            return date.timeIntervalSinceNow
        }
        else if minutes == 0{
            return date.timeIntervalSinceNow
        }
        else{
            //let oldDate = calendar.dateByAddingUnit(.Minute, value: minutes, toDate: date, options: [])
            return NSTimeInterval(-1)
            //return date.timeIntervalSinceDate(oldDate!)
        }
    }
}
