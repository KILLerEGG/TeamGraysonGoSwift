//
//  hangoutsViewController.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 8/23/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class hangoutsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HangoutsModelProtocal {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var addHangoutButton: UIBarButtonItem!
    @IBOutlet weak var hangoutTableView: UITableView!
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var noHangoutsLabel: UILabel!
    
    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, first_name, last_name"])
    var first_name: String = ""

    var hangoutItems: [HangoutModelObj] = [HangoutModelObj]()
    var picturesArray: [pictures] = [pictures]()
    
    var myTimer: NSTimer? = nil
    var newTimeInt: NSTimeInterval? = nil
    
    func reloadData() {
        if Reachability.connectedToNetwork() == true {
            if self.hangoutTableView.hidden == false {
                self.hangoutTableView.hidden = true
            }
            // Load hangout data from PHP call
            let hangoutsModel = HangoutsModel()
            hangoutsModel.delegate = self
            hangoutsModel.downloadItems()
            
            hangoutTableView.delegate = self
            hangoutTableView.dataSource = self
            
            if self.revealViewController() != nil {
                    menuButton.target = self.revealViewController()
                    menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
                    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
        }
        else {
            let alert = UIAlertController(title: "Internet Connection Error", message: "No data connection detected. Please ensure you have a data connection to retry.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                self.reloadData()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                let alert = UIAlertController(title: "Connection Error", message: "Unable to connect to server right now. Please try again, or wait until later to try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                self.first_name = result.valueForKey("first_name") as! String
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.noHangoutsLabel.hidden = true
        if !self.loadingIcon.isAnimating() {
            self.loadingIcon.startAnimating()
        }
        self.reloadData()
    }
    
    func itemsDownloaded(items: NSArray){
        
        if items.count > 0 {
            for i in 0...(items.count-1){
                let item: HangoutModelObj = items[i] as! HangoutModelObj
                if item.date != NSTimeInterval(-1) {
                    hangoutItems.append(HangoutModelObj(id: item.id!, organizer: item.organizer!, going: item.going!, notGoing: item.notGoing!, location: item.location!, address: item.address!, date: item.date!))
                }
            }
            self.hangoutTableView.hidden = false
            self.loadingIcon.stopAnimating()
            self.hangoutTableView.reloadData()
        }
        else {
            self.loadingIcon.stopAnimating()
            self.noHangoutsLabel.hidden = false
        }
    }

    func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours > 0 {
            if minutes == 0 {
                return String(format: "%d hr", hours)
            }
            else {
                return String(format: "%d hr, %d min", hours, minutes)
            }
        }
        else {
            if minutes > 0 {
                return String(format: "%d min", minutes)
            }
            else if minutes == 0 {
                return "now"
            }
            return String(format: "%d hr, %d min", hours, minutes)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(hangoutTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return dataSourceArray.count // Most of the time my data source is an array of something
        return self.hangoutItems.count
    }

    
    func tableView(hangoutTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CustomHangoutCell = hangoutTableView.dequeueReusableCellWithIdentifier("hangoutCell")! as! CustomHangoutCell
        cell.organizerLabel.text = hangoutItems[(indexPath as NSIndexPath).item].organizer! + " is going to " + hangoutItems[(indexPath as NSIndexPath).item].location! + "!"
        cell.whenLabel.text = stringFromTimeInterval(hangoutItems[(indexPath as NSIndexPath).item].date!)
        for i in 0...(globalPicsArray.count-1) {
            if globalPicsArray[i].name == hangoutItems[(indexPath as NSIndexPath).item].organizer {
                let userUrl = NSURL(string: "http://graph.facebook.com/"+globalPicsArray[i].id+"/picture?type=large")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL: userUrl!)
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.organizerImage.contentMode = .ScaleAspectFill
                        cell.organizerImage.image = UIImage(data: data!)
                    }
                }
            }
        }
        var goingCount = 0
        var notGoingCount = 0
        for going in (hangoutItems[(indexPath as NSIndexPath).item].going)! {
            for picture in globalPicsArray {
                if (hangoutItems[(indexPath as NSIndexPath).item].going!.count > 0) && (picture.name == going) {
                    let userUrl = NSURL(string: "http://graph.facebook.com/"+picture.id+"/picture?type=large")
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        let data = NSData(contentsOfURL: userUrl!)
                        dispatch_async(dispatch_get_main_queue()) {
                            if goingCount == 0 {
                                cell.goingImage1.contentMode = .ScaleAspectFill
                                cell.goingImage1.image = UIImage(data: data!)
                            }
                            else {
                                let image = UIImage(data: data!)
                                let imageView = UIImageView(image: image!)
                                imageView.frame = CGRect(x: (cell.goingImage1.frame.minX + CGFloat(21 * goingCount)), y: cell.goingImage1.frame.minY, width: 20, height: 20)
                                cell.addSubview(imageView)
                            }
                            goingCount += 1
                        }
                    }
                }
            }
        }
        for notGoing in (hangoutItems[(indexPath as NSIndexPath).item].notGoing)! {
            for picture in globalPicsArray {
                if (hangoutItems[(indexPath as NSIndexPath).item].notGoing!.count > 0) && (picture.name == notGoing) {
                    let userUrl = NSURL(string: "http://graph.facebook.com/"+picture.id+"/picture?type=large")
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        let data = NSData(contentsOfURL: userUrl!)
                        dispatch_async(dispatch_get_main_queue()) {
                            if notGoingCount == 0 {
                                cell.notGoingImage1.contentMode = .ScaleAspectFill
                                cell.notGoingImage1.image = UIImage(data: data!)
                            }
                            else {
                                let image = UIImage(data: data!)
                                let imageView = UIImageView(image: image!)
                                imageView.frame = CGRect(x: (cell.notGoingImage1.frame.minX + CGFloat(21 * notGoingCount)), y: cell.notGoingImage1.frame.minY, width: 20, height: 20)
                                cell.addSubview(imageView)
                            }
                            notGoingCount += 1
                        }
                    }
                }
            }
        }
        //let date = hangoutItems[indexPath.item].date
        //myTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(hangoutsViewController.updateTime(_:)), userInfo: nil, repeats: true)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if Reachability.connectedToNetwork() == true {
            let hangoutSpecificViewController: HangoutSpecificViewController = self.storyboard?.instantiateViewControllerWithIdentifier("hangoutSpecificViewController") as! HangoutSpecificViewController
            hangoutSpecificViewController.hangoutID = hangoutItems[(indexPath as NSIndexPath).item].id!

            hangoutSpecificViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height) // Make sure to decrease the total height of the view to ensure that page controller and the menu button get displayed and aren't hidden by the view
            
            
            self.addChildViewController(hangoutSpecificViewController)
            self.view.addSubview(hangoutSpecificViewController.view)
            hangoutSpecificViewController.didMoveToParentViewController(self)
        }
        else {
            let alert = UIAlertController(title: "Internet Connection Error", message: "No data connection detected. Please ensure you have a data connection to retry.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func updateTime(timer: NSTimer){
        self.hangoutTableView.reloadData()
        /*var userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        let cell = userInfo.first?.1.whenLabel
        userInfo.popFirst()
        print(cell!.text)*/
        //cell!.text = stringFromTimeInterval(Double((userInfo.first?.1)! as! NSNumber))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
