//
//  AddHangoutViewController.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 9/1/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker

class AddHangoutViewController: UIViewController, NSURLSessionDataDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var showPlacePicker: UIButton!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var whenDatePicker: UIDatePicker!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var canOpenPlacePicker: Bool = true
    var address: String = ""
    
   
    @IBOutlet weak var addHangoutBtn: UIButton!
    
    var urlPath: String = "http://10.0.0.246/post_hangout.php"
    var first_name: String = ""
    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, first_name, last_name"])
    
    var locationManager: CLLocationManager!
    var placePicker: GMSPlacePicker!
    var latitude: Double!
    var longitude: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddHangoutViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
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
                
            }
        })

        loadingIndicator.stopAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
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
    
    func checkHangout(){
        if Reachability.connectedToNetwork() == true {
            loadingIndicator.startAnimating()
            locationLabel.hidden = true
            locationTextField.hidden = true
            whenLabel.hidden = true
            whenDatePicker.hidden = true
            addHangoutBtn.hidden = true
            showPlacePicker.hidden = true
            verifyUrl()
        }
    }
    
    func postHangout(){
        let minutes = Int((whenDatePicker.date.timeIntervalSinceNow)/60) + 1
        if locationTextField.hasText() && minutes > 0{
            let location: String = locationTextField.text!
            let url: NSURL = NSURL(string: self.urlPath)!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            let bodyData = "organizer=\(self.first_name)&location=\(location)&address=\(self.address)&minutes=\(String(minutes))"
            request.HTTPMethod = "POST"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            
            NSURLConnection.sendAsynchronousRequest(request as NSURLRequest, queue: NSOperationQueue.mainQueue())
            {(response, data, error) in
                if let HTTPResponse = response as? NSHTTPURLResponse {
                    let statusCode = HTTPResponse.statusCode
                    if statusCode == 200 {
                        self.performSegueWithIdentifier("returnToHangouts", sender: self)
                    }
                }
            }
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
            if self.urlPath == "http://10.0.0.246/post_hangout.php"{
                self.urlPath = "http://50.156.82.136/post_hangout.php"
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
            self.postHangout()
        }
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

    // MARK: - Navigation
    
    
    @IBAction func showPlacePickerAction(sender: UIButton) {
        /*self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()*/
        
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
                    let coordinates = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
                    self.locationTextField.text = place.name
                    self.address = place.formattedAddress!
                    //store address here as well
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
    
    @IBAction func addHangoutButton(sender: UIButton) {
        self.checkHangout()
    }
}
