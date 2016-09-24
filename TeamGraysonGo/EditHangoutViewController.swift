//
//  EditHangoutViewController.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 9/19/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class EditHangoutViewController: UIViewController, UITextFieldDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, NSURLSessionDataDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var editHangoutButton: UIButton!
    @IBOutlet weak var locationSearchButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var googleMap: GMSMapView!
    @IBOutlet weak var loadingIndication: UIActivityIndicatorView!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var manualLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    var hangoutID: String?
    var location: String?
    var address: String = ""
    var seconds: NSTimeInterval?
    var urlPath: String = "http://10.0.0.246/edit_hangout.php"
    var latitude: Double!
    var longitude: Double!
    var locationMarker: GMSMarker?
    var canOpenPlacePicker: Bool = true
    var locationManager: CLLocationManager!
    var placePicker: GMSPlacePicker!
    var originalAddress: String?
    var originalDate: NSDate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.hangoutID!)
        
        self.googleMap.hidden = true
        self.googleMap.delegate = self
        self.googleMap.myLocationEnabled = true
        
        self.locationSearchButton.layer.borderColor = UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0).CGColor
        self.locationSearchButton.layer.borderWidth = 1
        self.locationSearchButton.layer.cornerRadius = 5
        
        self.loadingIndication.stopAnimating()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        self.locationTextField.delegate = self
        self.locationTextField.text = self.location
        self.editHangoutButton.layer.borderWidth = 1
        self.editHangoutButton.layer.cornerRadius = 5
        self.editHangoutButton.layer.borderColor = UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0).CGColor
        self.datePicker.date = NSDate(timeIntervalSince1970: seconds!)
        //self.datePicker.date = NSDate(timeIntervalSinceReferenceDate: seconds!)// NSDate.init(timeIntervalSinceNow: seconds!)
        self.datePicker.minimumDate = NSDate()
        self.originalDate = self.datePicker.date
        
        if self.address != "" {
            self.originalAddress = self.address
            forwardGeocoding(self.address, place: self.location!)
        }
    }
    
    func forwardGeocoding(address: String, place: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
                self.googleMap.hidden = true
            }
            if placemarks?.count > 0 {
                
                let placemark = placemarks?[0]
                let location = placemark!.location
                let coordinate = location?.coordinate
                
                let camera = GMSCameraPosition.cameraWithLatitude(coordinate!.latitude,
                    longitude:coordinate!.longitude, zoom:15)
                
                self.locationMarker = GMSMarker()
                self.locationMarker?.position = camera.target
                self.locationMarker?.snippet = "\(place)\n\(address)"
                self.locationMarker?.appearAnimation = kGMSMarkerAnimationPop
                self.locationMarker?.map = self.googleMap
                
                self.googleMap.hidden = false
                self.googleMap.animateToCameraPosition(camera)
            }
        })
    }
    
    func locationManager(manager: CLLocationManager,
                         didFailWithError error: NSError){
        
        print("An error occurred while tracking location changes : \(error.description)")
        self.canOpenPlacePicker = false
    }
    
    func locationManager(manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]){
        
        let location:CLLocation = locations.last!
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "returnToHangoutSpecific" {
            let nextScene =  segue.destinationViewController as! HangoutSpecificViewController
            nextScene.hangoutID = self.hangoutID!
        }
    }
    
    func prepareForEdit(){
        if Reachability.connectedToNetwork() == true {
            loadingIndication.startAnimating()
            manualLabel.hidden = true
            locationLabel.hidden = true
            locationTextField.hidden = true
            whenLabel.hidden = true
            datePicker.hidden = true
            editHangoutButton.hidden = true
            locationSearchButton.hidden = true
            googleMap.hidden = true
            verifyUrl()
        }
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
            if self.urlPath == "http://10.0.0.246/edit_hangout.php"{
                self.urlPath = "http://50.156.82.136/edit_hangout.php"
                self.verifyUrl()
            }
            else {
                let alert = UIAlertController(title: "Connection Error", message: "Unable to connect to server right now. Please try again, or wait until later to try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                    self.prepareForEdit()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
        else {
            self.editHangout()
        }
    }
    
    func editHangout(){
        if self.location != locationTextField.text! {
            if self.address == self.originalAddress {
                self.address = "";
            }
        }
        //let minutes = Int((datePicker.date.timeIntervalSinceNow)/60) + 1
        let seconds = datePicker.date.timeIntervalSince1970
        //let location: String = locationTextField.text!
        let customAllowedSet =  NSCharacterSet(charactersInString:"!*'();:@&=+$,/?%#[]").invertedSet
        let location: String = locationTextField.text!.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        let url: NSURL = NSURL(string: self.urlPath)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        let bodyData = "id=\(self.hangoutID!)&location=\(location)&address=\(self.address)&seconds=\(String(seconds))"
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request as NSURLRequest, queue: NSOperationQueue.mainQueue())
        {(response, data, error) in
            if let HTTPResponse = response as? NSHTTPURLResponse {
                let statusCode = HTTPResponse.statusCode
                if statusCode == 200 {
                    self.performSegueWithIdentifier("returnToHangoutSpecific", sender: self)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func showPlacePicker(sender: UIButton) {
        if self.canOpenPlacePicker && (self.latitude != nil && self.longitude != nil) {
            
            let center = CLLocationCoordinate2DMake(self.latitude, self.longitude)
            let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
            let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
            let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let config = GMSPlacePickerConfig(viewport: viewport)
            self.placePicker = GMSPlacePicker(config: config)
            
            placePicker.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
                
                if let error = error {
                    print("Error occurred: \(error.localizedDescription)")
                    return
                }
                
                if let place = place {
                    //let coordinates = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
                    self.locationTextField.text = place.name
                    self.address = place.formattedAddress!
                    
                    let camera = GMSCameraPosition.cameraWithLatitude(place.coordinate.latitude,
                        longitude:place.coordinate.longitude, zoom:15)
                    
                    self.locationMarker?.map = nil
                    
                    let marker = GMSMarker()
                    marker.position = camera.target
                    marker.snippet = "\(place.name)\n\(place.formattedAddress!)"
                    marker.appearAnimation = kGMSMarkerAnimationPop
                    marker.map = self.googleMap
                    
                    self.locationMarker = marker
                    
                    self.googleMap.hidden = false
                    self.googleMap.animateToCameraPosition(camera)
                    
                } else {
                    print("No place was selected")
                }
            })
        }
        else {
            let alert = UIAlertController(title: "Location Error", message: "Unable to get your location. Please make sure location services are enabled and try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func doneEditing(sender: UIButton) {
        let seconds = datePicker.date
        let now = NSDate()
        let timeInFiveMin = now.dateByAddingTimeInterval(4*60)
        if datePicker.date == self.originalDate {
            if locationTextField.hasText() {
                self.prepareForEdit()
            }
            else {
                let alert = UIAlertController(title: "Input Error", message: "Location field can't be empty. You have to have a hangout somewhere! Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            if locationTextField.hasText() && ((timeInFiveMin.laterDate(seconds)) == seconds){
                self.prepareForEdit()
            }
            else if (timeInFiveMin.laterDate(seconds)) == timeInFiveMin {
                let alert = UIAlertController(title: "Input Error", message: "Invalid time. Hangouts are meant to be in the future, not at this very moment! Please enter a time at least 5 minutes in the future.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Input Error", message: "Location field can't be empty. You have to have a hangout somewhere! Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}
