//
//  StreamViewController.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 9/1/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import AVFoundation

class StreamViewController: UIViewController, NSURLSessionDataDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var streamButton: UIButton!
    
    var urlPath: String = "http://10.0.0.246/stream/server/stream.m3u8"
    
    func isTimeStampCurrent(timeStamp:NSDate, startTime:NSDate, endTime:NSDate)->Bool{
        if (timeStamp as NSDate).earlierDate(endTime) == timeStamp && (timeStamp as NSDate).laterDate(startTime) == timeStamp{
            return true
        }
        return false
    }
    
    func verifyUrl() {
        
        let url: NSURL = NSURL(string: self.urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 2
        configuration.timeoutIntervalForResource = 2
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            if self.urlPath == "http://10.0.0.246/stream/server/stream.m3u8"{
                self.urlPath = "http://50.156.82.136/stream/server/stream.m3u8"
                self.verifyUrl()
            }
            else {
                let alert = UIAlertController(title: "Connection Error", message: "Unable to connect to server right now. Please try again, or wait until later to try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                    self.urlPath = "http://10.0.0.246/stream/server/stream.m3u8"
                    self.checkStream()
                }))
                self.presentViewController(alert, animated: true, completion: nil)

            }
        }
        else {
            self.startStream()
        }
    }
    
    func checkStream(){
        if Reachability.connectedToNetwork() == true {
            verifyUrl()
        }
        else {
            let alert = UIAlertController(title: "Internet Connection Error", message: "No data connection detected. Please ensure you have a data connection to retry.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                self.checkStream()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func startStream(){
        self.streamButton.enabled = true
        self.streamButton.layer.borderColor = UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0).CGColor
        self.activityIndicator.stopAnimating()
        let videoURL = NSURL(string: self.urlPath)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.onVideoDone(_:)), name: AVPlayerItemPlaybackStalledNotification, object: player.currentItem)
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.streamButton.layer.borderWidth = 1
        self.streamButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.streamButton.layer.cornerRadius = 5
        self.streamButton.enabled = false
        self.checkStream() //JUST FOR TESTING NIGHT! UNCOMMENT BELOW FOR NON-ADMIN BUILD
        
        /*let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let now: NSDate = NSDate()
        let morningDateTime = calendar.dateBySettingHour(8, minute: 0, second: 0, ofDate: now, options: NSCalendarOptions.MatchFirst)!
        let eveningDateTime = calendar.dateBySettingHour(21, minute: 0, second: 0, ofDate: now, options: NSCalendarOptions.MatchFirst)!
        
        if isTimeStampCurrent(now, startTime: morningDateTime, endTime: eveningDateTime) {
            self.checkStream()
        }
        else {
            activityIndicator.stopAnimating()
            
            let alert = UIAlertController(title: "Stream Error", message: "Stream is offline until 8am. Please try again then.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.streamButton.enabled = true
            self.streamButton.layer.borderColor = UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0).CGColor
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    @IBAction func startStream(sender: UIButton) {
        self.streamButton.enabled = false
        self.streamButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.activityIndicator.startAnimating()
        self.urlPath = "http://10.0.0.246/stream/server/stream.m3u8"
        self.checkStream() //JUST FOR TESTING NIGHT! UNCOMMENT BELOW FOR NON-ADMIN BUILD
        
        /*let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let now: NSDate = NSDate()
        let morningDateTime = calendar.dateBySettingHour(8, minute: 0, second: 0, ofDate: now, options: NSCalendarOptions.MatchFirst)!
        let eveningDateTime = calendar.dateBySettingHour(21, minute: 0, second: 0, ofDate: now, options: NSCalendarOptions.MatchFirst)!
        
        if isTimeStampCurrent(now, startTime: morningDateTime, endTime: eveningDateTime) {
            activityIndicator.startAnimating()
            self.checkStream()
        }
        else {
            let alert = UIAlertController(title: "Stream Error", message: "Stream is offline until 8am. Please try again then.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.streamButton.enabled = true
            self.streamButton.layer.borderColor = UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0).CGColor
        }*/
    }
}
