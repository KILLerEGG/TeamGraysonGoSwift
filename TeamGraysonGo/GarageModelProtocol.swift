//
//  GarageModelProtocol.swift
//  GraysonApp
//
//  Created by Graham Turbyne on 7/28/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import Foundation
import SystemConfiguration

protocol GarageModelProtocal: class {
    func itemsDownloaded(items: NSArray)
}

class GarageModel: NSObject, NSURLSessionDataDelegate{
    
    weak var delegate: GarageModelProtocal!
    
    var data: NSMutableData = NSMutableData()
    
    var urlPath: String = "http://10.0.0.246/mobile_garage.php"
    
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
        print("received: \(data)")
        self.data.appendData(data);
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            if self.urlPath == "http://10.0.0.246/mobile_garage.php"{
                self.urlPath = "http://50.156.82.136/mobile_garage.php"
                self.downloadItems()
            }
            else {
                let alert = UIAlertView(title: "Connection Error", message: "There was an error connecting to the server. Please try again later.", delegate: nil, cancelButtonTitle: "Close")
                alert.show()
                //self.urlPath = "http://10.0.0.246/mobile_garage.php"
                //self.downloadItems()
            }
        }
        else {
            self.parseJSON()
        }
    }
    
    func parseJSON() {
        
        var jsonResult: NSMutableArray = NSMutableArray()
        
        do {
            jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data as NSData, options: .AllowFragments) as! NSMutableArray
            
        }
        catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        let garageUsers: NSMutableArray = NSMutableArray()
        
        for i in 0...(jsonResult.count - 1) {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let user = GarageModelObj()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let name = jsonElement["name"] as? String,
                let garage = jsonElement["garage"] as? String,
                let outside = jsonElement["outside"] as? String,
                let pass = jsonElement["pass"] as? String,
                let order = jsonElement["order"] as? String,
                let idNum = jsonElement["id_num"] as? String
            {
                
                user.name = name
                user.garage = garage
                user.outside = outside
                user.pass = pass
                user.order = order
                user.idNum = idNum
            }
            
            garageUsers.addObject(user)
            
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            if self.delegate != nil {
                self.delegate.itemsDownloaded(garageUsers)
            }
        }
    }
}
