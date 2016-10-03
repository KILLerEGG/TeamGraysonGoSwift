//
//  hangoutSpecificViewController.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 9/4/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class HangoutSpecificViewController: UIViewController, NSURLSessionDelegate, SpecificHangoutsModelProtocal, GMSMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var organizerImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var organizerTitleLabel: UILabel!
    @IBOutlet weak var googleMap: GMSMapView!
    @IBOutlet weak var goingTextLabel: UILabel!
    
    @IBOutlet weak var goingBackgroundImage: UIImageView!
    
    @IBOutlet weak var notGoingTextLabel: UILabel!
    @IBOutlet weak var notGoingBackgroundImage: UIImageView!
    var urlPath: String = "http://10.0.0.246/update_hangout.php"
    var cancelUrlPath: String = "http://10.0.0.246/cancel_hangout.php"
    var urlBase: String = "http://10.0.0.246/"
    
    var hangoutItems: [HangoutModelObj] = [HangoutModelObj]()
    
    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, first_name, last_name"])
    
    var locationManager: CLLocationManager!
    
    var organizerImageData: NSData?
    var locationText: String?
    var dateText: String?
    var hangoutID: String?
    var organizer: String?
    var goingList: [String]?
    var notGoingList: [String]?
    var userGoingTag: Int?
    var userNotGoingTag: Int?
    var going_xPos: CGFloat = 19
    var user_going_xPos: CGFloat?
    var user_notGoing_xPos: CGFloat?
    var notGoing_xPos: CGFloat = 197
    var yPos: CGFloat = 441
    
    var userGoingImage: UIImageView?
    var userNotGoingImage: UIImageView?
    
    var goingButton: UIButton?
    var notGoingButton: UIButton?
    var cancelButton: UIButton?
    var editButton: UIButton?
    
    var userUIImage: UIImageView?
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var canPlaceLocation = true
    
    var going = 0
    var notGoing = 0
    var isCancelled = false
    
    var first_name: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.googleMap.hidden = true
        
        self.loadingIndicator.startAnimating()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                let alert = UIAlertController(title: "Connection Error", message: "Unable to connect to server right now. Please try again, or wait until later to try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                    self.checkHangout()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                self.first_name = result.valueForKey("first_name") as! String
                
                let hangoutsModel = SpecificHangoutModel()
                hangoutsModel.delegate = self
                hangoutsModel.downloadItems(self.hangoutID!)
                self.googleMap.delegate = self
                self.googleMap.myLocationEnabled = true
            }
        })
    }
    
    func locationManager(manager: CLLocationManager,
                         didFailWithError error: NSError){
        
        print("An error occurred while tracking location changes : \(error.description)")
        self.canPlaceLocation = false
    }
    
    func locationManager(manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]){
        
        //let location:CLLocation = locations.last!
        
    }

    
    func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateFormat = "h:mm a, MMM d"
        return dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: interval))
        /*let intInterval = Int(interval)
        let days = (intInterval / 86400)
        var hours = (intInterval / 3600)
        let minutes = Int(interval / 60) % 60
        
        if days > 0 && days < 2 {
            hours = hours - (24 * days)
            if hours > 0 && hours < 2{
                if minutes == 0 {
                    return String(format: "%d day, %d hour", days, hours)
                }
                else if minutes == 1 {
                    return String(format: "%d day, %d hour, %d minute", days, hours, minutes)
                }
                else {
                    return String(format: "%d day, %d hour, %d minutes", days, hours, minutes)
                }
            }
            else if hours >= 2 {
                if minutes == 0 {
                    return String(format: "%d day, %d hours", days, hours)
                }
                else if minutes == 1 {
                    return String(format: "%d day, %d hours, %d minute", days, hours, minutes)
                }
                else {
                    return String(format: "%d day, %d hours, %d minutes", days, hours, minutes)
                }
            }
            else {
                if minutes == 0 {
                    return String(format: "%d day", days)
                }
                else if minutes == 1 {
                    return String(format: "%d day, %d minute", days, minutes)
                }
                else {
                    return String(format: "%d day, %d minutes", days, minutes)
                }
            }
        }
        else if days >= 2 {
            hours = hours - (24 * days)
            if hours > 0 && hours < 2{
                if minutes == 0 {
                    return String(format: "%d days, %d hour", days, hours)
                }
                else if minutes == 1 {
                    return String(format: "%d days, %d hour, %d minute", days, hours, minutes)
                }
                else {
                    return String(format: "%d days, %d hour, %d minutes", days, hours, minutes)
                }
            }
            else if hours >= 2 {
                if minutes == 0 {
                    return String(format: "%d days, %d hours", days, hours)
                }
                else if minutes == 1 {
                    return String(format: "%d days, %d hours, %d minute", days, hours, minutes)
                }
                else {
                    return String(format: "%d days, %d hours, %d minutes", days, hours, minutes)
                }
            }
            else {
                if minutes == 0 {
                    return String(format: "%d days", days)
                }
                else if minutes == 1 {
                    return String(format: "%d days, %d minute", days, minutes)
                }
                else {
                    return String(format: "%d days, %d minutes", days, minutes)
                }
            }
        }
        else {
            if hours > 0 && hours < 2{
                if minutes == 0 {
                    return String(format: "%d hour", hours)
                }
                else if minutes == 1 {
                    return String(format: "%d hour, %d minute", hours, minutes)
                }
                else {
                    return String(format: "%d hour, %d minutes", hours, minutes)
                }
            }
            else if hours >= 2 {
                if minutes == 0 {
                    return String(format: "%d hours", hours)
                }
                else if minutes == 1 {
                    return String(format: "%d hours, %d minute", hours, minutes)
                }
                else {
                    return String(format: "%d hours, %d minutes", hours, minutes)
                }
            }
            else {
                if minutes == 0 {
                    return "Now"
                }
                else if minutes == 1 {
                    return String(format: "%d minute", minutes)
                }
                else {
                    return String(format: "%d minutes", minutes)
                }
            }
        }*/
    }
    
    func forwardGeocoding(address: String, place: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
                self.googleMap.hidden = true
            }
            if placemarks?.count > 0 {
                
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                self.latitude = coordinate!.latitude
                self.longitude = coordinate!.longitude
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
                marker.snippet = "\(place)\n\(address)"
                marker.appearAnimation = kGMSMarkerAnimationPop
                marker.map = self.googleMap
                
                let camera = GMSCameraPosition.cameraWithLatitude(coordinate!.latitude,
                    longitude:coordinate!.longitude, zoom:15)
                
                self.googleMap.hidden = false
                self.googleMap.animateToCameraPosition(camera)
                
                if self.canPlaceLocation {
                    
                    var bounds = GMSCoordinateBounds()
                    
                    bounds = bounds.includingCoordinate(marker.position)
                    bounds = bounds.includingCoordinate((self.googleMap?.myLocation?.coordinate)!)
                
                    let delay = 2 * Double(NSEC_PER_SEC)
                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        // After 2 seconds this line will be executed
                        self.googleMap.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
                    }
                }
            }
        })
    }
    
    func itemsDownloaded(items: NSArray){
        if items.count > 0 {
            for i in 0...(items.count-1){
                let item: HangoutModelObj = items[i] as! HangoutModelObj
                if item.date != NSTimeInterval(-1) {
                    hangoutItems.append(HangoutModelObj(id: item.id!, organizer: item.organizer!, going: item.going!, notGoing: item.notGoing!, location: item.location!, address: item.address!, date: item.date!))
                }
            }
            
            if hangoutItems[0].address != "" {
                forwardGeocoding((hangoutItems[0].address)!, place: (hangoutItems[0].location)!)
            }
            /*else {
                forwardGeocoding(hangoutItems[0].location!, place: hangoutItems[0].location!)
            }*/
            
            self.loadingIndicator.stopAnimating()
            
            self.goingTextLabel.hidden = false
            self.notGoingTextLabel.hidden = false
            
            self.goingBackgroundImage.backgroundColor = UIColor.clearColor()
            self.goingBackgroundImage.layer.borderColor = UIColor.blueColor().CGColor
            self.goingBackgroundImage.layer.borderWidth = 1
            self.goingBackgroundImage.layer.cornerRadius = 5
            
            self.notGoingBackgroundImage.backgroundColor = UIColor.clearColor()
            self.notGoingBackgroundImage.layer.borderColor = UIColor.blueColor().CGColor
            self.notGoingBackgroundImage.layer.borderWidth = 1
            self.notGoingBackgroundImage.layer.cornerRadius = 5
            
            self.organizer = hangoutItems[0].organizer

            if self.organizer! == self.first_name {
                self.organizerTitleLabel.text = "You are hosting a hangout:"
            }
            else {
                self.organizerTitleLabel.text = "\(self.organizer!) invited you to a hangout:"
            }
            self.organizerTitleLabel.hidden = false
            self.locationLabel.hidden = false
            self.whenLabel.hidden = false
            
            self.locationLabel.text = hangoutItems[0].location
            self.whenLabel.text = self.stringFromTimeInterval(hangoutItems[0].date!)
            self.goingList = hangoutItems[0].going
            self.notGoingList = hangoutItems[0].notGoing
            
            for i in 0...(globalPicsArray.count-1) {
                if globalPicsArray[i].name == hangoutItems[0].organizer {
                    let userUrl = NSURL(string: "http://graph.facebook.com/"+globalPicsArray[i].id+"/picture?type=large")
                    
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        let data = NSData(contentsOfURL: userUrl!)!

                        dispatch_async(dispatch_get_main_queue()) {
                            self.organizerImage.contentMode = UIViewContentMode.ScaleAspectFill
                            self.organizerImage.image = UIImage(data: data)
                        }
                    }
                }
            }
            
            for going in (self.goingList)! {
                for picture in globalPicsArray {
                    if (self.goingList!.count > 0) && (picture.name == going) {
                        let userUrl = NSURL(string: "http://graph.facebook.com/"+picture.id+"/picture?type=large")
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            let data = NSData(contentsOfURL: userUrl!)
                            dispatch_async(dispatch_get_main_queue()) {
                                let image = UIImage(data: data!)
                                let imageView = UIImageView(image: image!)
                                imageView.frame = CGRect(x: self.going_xPos, y: self.yPos, width: 30, height: 30)
                                if going == self.first_name {
                                    self.userGoingImage = imageView
                                    self.user_going_xPos = self.going_xPos
                                }
                                self.view.addSubview(imageView)
                                self.going_xPos = self.going_xPos + 32
                            }
                        }
                    }
                }
            }
            
            for notGoing in (self.notGoingList)! {
                for picture in globalPicsArray {
                    if (self.notGoingList!.count > 0) && (picture.name == notGoing) {
                        let userUrl = NSURL(string: "http://graph.facebook.com/"+picture.id+"/picture?type=large")
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            let data = NSData(contentsOfURL: userUrl!)
                            dispatch_async(dispatch_get_main_queue()) {
                                let image = UIImage(data: data!)
                                let imageView = UIImageView(image: image!)
                                imageView.frame = CGRect(x: self.notGoing_xPos, y: self.yPos, width: 30, height: 30)
                                if notGoing == self.first_name {
                                    self.userNotGoingImage = imageView
                                    self.user_notGoing_xPos = self.notGoing_xPos
                                }
                                self.view.addSubview(imageView)
                                self.notGoing_xPos = self.notGoing_xPos + 32
                            }
                        }
                    }
                }
            }
            
            if self.first_name != self.organizer {
                self.goingButton = UIButton(frame: CGRect(x: 70, y: 520, width: 100, height: 50))
                self.goingButton!.layer.cornerRadius = 5
                self.goingButton!.layer.borderWidth = 1
                self.goingButton!.layer.borderColor = UIColor(red: 0/255, green: 178/255, blue: 2/255, alpha: 1.0).CGColor
                self.goingButton!.backgroundColor = UIColor.clearColor()
                self.goingButton!.setTitle("Going", forState: UIControlState.Normal)
                self.goingButton!.setTitleColor(UIColor(red: 0/255, green: 178/255, blue: 2/255, alpha: 1.0), forState: .Normal)
                self.goingButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
                self.goingButton!.setTitleColor(UIColor(red: 151/255, green: 175/255, blue: 151/255, alpha: 1.0), forState: .Disabled)
                self.goingButton!.addTarget(self, action: #selector(self.changeGoingButtonColor), forControlEvents: .TouchDown)
                self.goingButton!.addTarget(self, action: #selector(self.goingAction), forControlEvents: .TouchUpInside)
                self.goingButton!.addTarget(self, action: #selector(self.resetGoingButtonColor), forControlEvents: .TouchUpOutside)
                
                self.notGoingButton = UIButton(frame: CGRect(x: 200, y: 520, width: 100, height: 50))
                self.notGoingButton!.layer.cornerRadius = 5
                self.notGoingButton!.layer.borderWidth = 1
                self.notGoingButton!.layer.borderColor = UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0).CGColor
                self.notGoingButton!.backgroundColor = UIColor.clearColor()
                self.notGoingButton!.setTitle("Not Going", forState: .Normal)
                self.notGoingButton!.setTitleColor(UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0), forState: .Normal)
                self.notGoingButton!.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
                self.notGoingButton!.setTitleColor(UIColor(red: 232/255, green: 192/255, blue: 192/255, alpha: 1.0), forState: .Disabled)
                self.notGoingButton!.addTarget(self, action: #selector(self.changeNotGoingButtonColor), forControlEvents: .TouchDown)
                self.notGoingButton!.addTarget(self, action: #selector(self.notGoingAction), forControlEvents: .TouchUpInside)
                self.notGoingButton!.addTarget(self, action: #selector(self.resetNotGoingButtonColor), forControlEvents: .TouchUpOutside)
                
                if self.goingList?.count > 0 {
                    for name in self.goingList! {
                        if name == self.first_name {
                            self.goingButton?.enabled = false
                            self.goingButton!.layer.borderColor = UIColor(red: 151/255, green: 175/255, blue: 151/255, alpha: 1.0).CGColor
                            break
                        }
                    }
                }
                if self.notGoingList?.count > 0 {
                    for name in self.notGoingList! {
                        if name == self.first_name {
                            self.notGoingButton?.enabled = false
                            self.notGoingButton!.layer.borderColor = UIColor(red: 232/255, green: 192/255, blue: 192/255, alpha: 1.0).CGColor
                            break
                        }
                    }
                }
                self.view.addSubview(self.goingButton!)
                self.view.addSubview(self.notGoingButton!)
                
            }
            else {
                self.cancelButton = UIButton(frame: CGRect(x: 110, y: 520, width: 150, height: 50))
                self.cancelButton!.layer.cornerRadius = 5
                self.cancelButton!.layer.borderWidth = 1
                self.cancelButton!.layer.borderColor = UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0).CGColor
                self.cancelButton!.backgroundColor = UIColor.clearColor()
                self.cancelButton!.setTitle("Cancel Hangout", forState: .Normal)
                self.cancelButton!.setTitleColor(UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0), forState: .Normal)
                self.cancelButton!.setTitleColor(UIColor(red: 232/255, green: 192/255, blue: 192/255, alpha: 1.0), forState: .Disabled)
                self.cancelButton!.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
                self.cancelButton!.addTarget(self, action: #selector(self.changeCancelButtonColor), forControlEvents: UIControlEvents.TouchDown)
                self.cancelButton!.addTarget(self, action: #selector(self.cancelAction), forControlEvents: UIControlEvents.TouchUpInside)
                self.cancelButton!.addTarget(self, action: #selector(self.resetCancelButtonColor), forControlEvents: UIControlEvents.TouchUpOutside)
                self.view.addSubview(self.cancelButton!)
                
                self.editButton = UIButton(frame: CGRect(x: 110, y: 580, width: 150, height: 50))
                self.editButton!.layer.cornerRadius = 5
                self.editButton!.layer.borderWidth = 1
                self.editButton!.layer.borderColor = UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0).CGColor
                self.editButton!.backgroundColor = UIColor.clearColor()
                self.editButton!.setTitle("Edit Hangout", forState: .Normal)
                self.editButton!.setTitleColor(UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0), forState: .Normal)
                self.editButton!.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
                self.editButton!.addTarget(self, action: #selector(self.changeEditButtonColor), forControlEvents: UIControlEvents.TouchDown)
                self.editButton!.addTarget(self, action: #selector(self.editAction), forControlEvents: UIControlEvents.TouchUpInside)
                self.editButton!.addTarget(self, action: #selector(self.resetEditButtonColor), forControlEvents: UIControlEvents.TouchUpOutside)
                self.view.addSubview(self.editButton!)
            }
        }
    }
    
    func changeGoingButtonColor(sender: UIButton!) {
        self.goingButton!.backgroundColor = UIColor(red: 0/255, green: 178/255, blue: 2/255, alpha: 1.0)
    }
    
    func resetGoingButtonColor(sender: UIButton!) {
        self.goingButton!.backgroundColor = UIColor.clearColor()
        self.goingButton!.layer.borderColor = UIColor(red: 0/255, green: 178/255, blue: 2/255, alpha: 1.0).CGColor
    }

    func goingAction(sender: UIButton!) {
        self.goingButton!.backgroundColor = UIColor.clearColor()
        self.going = 1
        self.notGoing = 0
        self.goingButton?.enabled = false
        self.goingButton!.layer.borderColor = UIColor(red: 151/255, green: 175/255, blue: 151/255, alpha: 1.0).CGColor
        self.checkHangout()
    }
    
    func changeNotGoingButtonColor(sender: UIButton!) {
        self.notGoingButton!.backgroundColor = UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0)
    }
    
    func resetNotGoingButtonColor(sender: UIButton!) {
        self.notGoingButton!.backgroundColor = UIColor.clearColor()
        self.notGoingButton!.layer.borderColor = UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0).CGColor
    }
    
    func notGoingAction(sender: UIButton!) {
        self.notGoingButton!.backgroundColor = UIColor.clearColor()
        self.going = 0
        self.notGoing = 1
        self.notGoingButton?.enabled = false
        self.notGoingButton!.layer.borderColor = UIColor(red: 232/255, green: 192/255, blue: 192/255, alpha: 1.0).CGColor
        self.checkHangout()
    }
    
    func changeCancelButtonColor(sender: UIButton!) {
        self.cancelButton!.backgroundColor = UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0)
    }
    
    func resetCancelButtonColor(sender: UIButton!) {
        self.cancelButton!.backgroundColor = UIColor.clearColor()
        self.cancelButton!.layer.borderColor = UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0).CGColor
    }
    
    func cancelAction(sender: UIButton!) {
        self.cancelButton!.backgroundColor = UIColor.clearColor()
        self.isCancelled = true
        self.cancel()
    }
    
    func changeEditButtonColor(sender: UIButton!) {
        self.editButton!.backgroundColor = UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0)
    }
    
    func resetEditButtonColor(sender: UIButton!) {
        self.editButton!.backgroundColor = UIColor.clearColor()
        self.editButton!.layer.borderColor = UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0).CGColor
    }
    
    func editAction(sender: UIButton!) {
        self.editButton!.backgroundColor = UIColor.clearColor()
        self.performSegueWithIdentifier("editHangout", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkHangout() {
        if Reachability.connectedToNetwork() == true {
            self.loadingIndicator.startAnimating()
            verifyUrl()
        }
        else {
            let alert = UIAlertController(title: "Internet Connection Error", message: "No data connection detected. Please ensure you have a data connection to retry.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            if self.going == 1 {
                self.goingButton!.enabled = true
                self.goingButton!.backgroundColor = UIColor.clearColor()
                self.goingButton!.layer.borderColor = UIColor(red: 0/255, green: 178/255, blue: 2/255, alpha: 1.0).CGColor
            }
            else {
                self.notGoingButton!.enabled = true
                self.notGoingButton!.backgroundColor = UIColor.clearColor()
                self.notGoingButton!.layer.borderColor = UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0).CGColor
            }
        }
    }
    
    func cancel() {
        if Reachability.connectedToNetwork() == true {
            self.cancelButton?.enabled = false
            self.cancelButton?.layer.borderColor = UIColor(red: 232/255, green: 192/255, blue: 192/255, alpha: 1.0).CGColor
            self.loadingIndicator.startAnimating()
            verifyUrl()
        }
        else {
            let alert = UIAlertController(title: "Internet Connection Error", message: "No data connection detected. Please ensure you have a data connection to retry.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.cancelButton!.enabled = true
            self.cancelButton!.backgroundColor = UIColor.clearColor()
            self.cancelButton!.layer.borderColor = UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0).CGColor
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editHangout" {
            let nextScene =  segue.destinationViewController as! EditHangoutViewController
            print("id: \(self.hangoutID!)")
            nextScene.hangoutID = self.hangoutID!
            nextScene.location = self.hangoutItems[0].location!
            nextScene.address = self.hangoutItems[0].address!
            nextScene.seconds = self.hangoutItems[0].date!
        }
    }
    
    func cancelHangout() {
        
        let cancelPushUrl: NSURL = NSURL(string: self.urlBase+"cancelHangoutPush.php")!
        let cancelPushRequest:NSMutableURLRequest = NSMutableURLRequest(URL: cancelPushUrl)
        let cancelPushBodyData = "id=\(self.hangoutID!)&organizer=\(self.organizer!)&location=\(hangoutItems[0].location!)"
        print(cancelPushUrl)
        print(cancelPushBodyData)
        cancelPushRequest.HTTPMethod = "POST"
        cancelPushRequest.HTTPBody = cancelPushBodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(cancelPushRequest as NSURLRequest, queue: NSOperationQueue.mainQueue())
        {(response, data, error) in
            if let HTTPResponse = response as? NSHTTPURLResponse {
                let statusCode = HTTPResponse.statusCode
                if statusCode == 200 {
                    print("sent cancel push request successfully")
                }
            }
        }
        
        let url: NSURL = NSURL(string: self.cancelUrlPath)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        let bodyData = "id=\(self.hangoutID!)&user=\(self.first_name)"
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request as NSURLRequest, queue: NSOperationQueue.mainQueue())
        {(response, data, error) in
            if let HTTPResponse = response as? NSHTTPURLResponse {
                let statusCode = HTTPResponse.statusCode
                self.loadingIndicator.stopAnimating()
                if statusCode == 200 {
                    self.performSegueWithIdentifier("exitHangoutDetail", sender: nil)
                }
                else {
                    let alert = UIAlertController(title: "Database Error", message: "Error when trying to cancel hangout. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                        self.cancel()
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func updateHangout() {
        let url: NSURL = NSURL(string: self.urlPath)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        let bodyData = "id=\(self.hangoutID!)&user=\(self.first_name)&going=\(String(self.going))&notGoing=\(String(self.notGoing))"
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request as NSURLRequest, queue: NSOperationQueue.mainQueue())
        {(response, data, error) in
            if let HTTPResponse = response as? NSHTTPURLResponse {
                let statusCode = HTTPResponse.statusCode
                if statusCode == 200 {
                    for picture in globalPicsArray {
                        if picture.name == self.first_name {
                            let userUrl = NSURL(string: "http://graph.facebook.com/"+picture.id+"/picture?type=large")
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                                let data = NSData(contentsOfURL: userUrl!)
                                dispatch_async(dispatch_get_main_queue()) {
                                    let image = UIImage(data: data!)
                                    let imageView = UIImageView(image: image!)
            
                                    if self.going == 1 {
                                        if self.user_going_xPos != nil {
                                            imageView.frame = CGRect(x: self.user_going_xPos!, y: self.yPos, width: 30, height: 30)
                                        }
                                        else {
                                            imageView.frame = CGRect(x: self.going_xPos, y: self.yPos, width: 30, height: 30)
                                        }
                                        self.goingButton?.enabled = false
                                        self.notGoingButton?.enabled = true
                                        self.notGoingButton!.layer.borderColor = UIColor(red: 214/255, green: 57/255, blue: 57/255, alpha: 1.0).CGColor
                                        if self.userNotGoingImage != nil {
                                            self.userNotGoingImage?.removeFromSuperview()
                                            self.userGoingImage = imageView
                                        }
                                    }
                                    else if self.notGoing == 1 {
                                        if self.user_notGoing_xPos != nil {
                                            imageView.frame = CGRect(x: self.user_notGoing_xPos!, y: self.yPos, width: 30, height: 30)
                                        }
                                        else {
                                            imageView.frame = CGRect(x: self.notGoing_xPos, y: self.yPos, width: 30, height: 30)
                                        }
                                        self.notGoingButton?.enabled = false
                                        self.goingButton?.enabled = true
                                        self.goingButton!.layer.borderColor = UIColor(red: 0/255, green: 178/255, blue: 2/255, alpha: 1.0).CGColor
                                        if self.userGoingImage != nil {
                                            self.userGoingImage?.removeFromSuperview()
                                            self.userNotGoingImage = imageView
                                        }
                                    }
                                    
                                    self.view.addSubview(imageView)
                                    self.going = 0
                                    self.notGoing = 0
                                    self.loadingIndicator.stopAnimating()
                                }
                            }
                        }
                    }
                }
                else {
                    self.loadingIndicator.stopAnimating()
                    let alert = UIAlertController(title: "Database Error", message: "Error when trying to update hangout. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                        self.checkHangout()
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func verifyUrl() {
        var url: NSURL?
        if self.isCancelled {
            url = NSURL(string: self.cancelUrlPath)!
        }
        else {
            url = NSURL(string: self.urlPath)!
        }
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 2
        configuration.timeoutIntervalForResource = 2
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url!)
        
        task.resume()
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if self.isCancelled {
            if error != nil {
                if self.cancelUrlPath == "http://10.0.0.246/cancel_hangout.php"{
                    self.cancelUrlPath = "http://50.156.82.136/cancel_hangout.php"
                    self.urlBase = "http://50.156.82.136/"
                    self.verifyUrl()
                }
                else {
                    let alert = UIAlertController(title: "Connection Error", message: "Unable to connect to server right now. Please try again, or wait until later to try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                        self.cancel()
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else {
                self.cancelHangout()
            }
        }
        else {
            if error != nil {
                if self.urlPath == "http://10.0.0.246/update_hangout.php"{
                    self.urlPath = "http://50.156.82.136/update_hangout.php"
                    self.verifyUrl()
                }
                else {
                    let alert = UIAlertController(title: "Connection Error", message: "Unable to connect to server right now. Please try again, or wait until later to try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                        self.checkHangout()
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else {
                self.updateHangout()
            }
        }
    }
    
    // MARK: - Navigation
    

}
