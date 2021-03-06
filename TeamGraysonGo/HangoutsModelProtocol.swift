//
//  HangoutsModelProtocol.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 8/24/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import Foundation
import SystemConfiguration

protocol HangoutsModelProtocal: class {
    func itemsDownloaded(items: NSArray)
}

class HangoutsModel: NSObject, NSURLSessionDataDelegate{
    
    weak var delegate: HangoutsModelProtocal!
    
    var data: NSMutableData = NSMutableData()
    
    var urlPath: String = "http://10.0.0.246/mobile_hangouts.php"
    
    func downloadItems(){
        
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 2
        configuration.timeoutIntervalForResource = 2
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.data.appendData(data);
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            if self.urlPath == "http://10.0.0.246/mobile_hangouts.php"{
                self.urlPath = "http://50.156.82.136/mobile_hangouts.php"
                self.downloadItems()
            }
            else {
                let alert = UIAlertView(title: "Connection Error", message: "There was an error connecting to the server. Please try again later.", delegate: nil, cancelButtonTitle: "Close")
                alert.show()
                //self.urlPath = "http://10.0.0.246/mobile_hangouts.php"
                //self.downloadItems()
            }
        }
        else {
            self.parseJSON()
        }
    }
    
    func parseJSON() {
        
        //var jsonResult: NSMutableArray = NSMutableArray()
        let hangoutItems: NSMutableArray = NSMutableArray()
        var jsonElement: NSDictionary = NSDictionary()
        
        do {
            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data as NSData, options: .AllowFragments) as? NSMutableArray {
                
                for i in 0...(jsonResult.count - 1) {
                    
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    //the following insures none of the JsonElement values are nil through optional binding
                    if let id = jsonElement["id"] as? String,
                        let organizer = jsonElement["organizer"] as? String,
                        let going = jsonElement["going"] as? String,
                        let notGoing = jsonElement["notgoing"] as? String,
                        let location = jsonElement["location"] as? String,
                        let address = jsonElement["address"] as? String,
                        let minutes = jsonElement["minutes"] as? String
                    {
                        
                        let item = HangoutModelObj(id: id, organizer: organizer, going: going, notGoing: notGoing, location: location, address: address, minutes: Int(minutes)!)
                        
                        hangoutItems.addObject(item)
                        
                    }
                }
            }
        }
        catch let error as NSError {
            print(error)
            
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            if self.delegate != nil {
                self.delegate.itemsDownloaded(hangoutItems)
            }
        }
    }
}
