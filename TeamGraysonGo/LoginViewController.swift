//
//  LoginViewController.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 8/15/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import SystemConfiguration

class pictures: NSObject {
    var name: String
    var id: String
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
}

let globalPicsArray = [pictures(name: "Alan", id: "100000674808472"), pictures(name: "Rahul", id: "1050570262"), pictures(name: "Molly", id: "1553593244"), pictures(name: "Brittnie", id: "508642311"), pictures(name: "Graham", id: "571994343")]

public class Reachability {
    
    class func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        //let isReachable = flags.contains(.reachable)
        //let needsConnection = flags.contains(.connectionRequired)
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        // For Swift 3, replace the last two lines by
        // let isReachable = flags.contains(.reachable)
        // let needsConnection = flags.contains(.connectionRequired)
        
        
        return (isReachable && !needsConnection)
    }
}

protocol GetUsersProtocal: class {
    func itemsDownloaded(items: NSArray)
}

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, NSURLSessionDataDelegate {
    
    
    @IBOutlet weak var verifyLabel: UILabel!
    @IBOutlet weak var verifySpinner: UIActivityIndicatorView!
    
    weak var delegate: GetUsersProtocal!
    var data: NSMutableData = NSMutableData()
    var urlPath: String = "http://10.0.0.246/get_house_members.php"
    
    var first: String = ""
    var last: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.verifyLabel.hidden = true
        self.verifySpinner.hidden = true
    }
    
    func reloadData() {
        if Reachability.connectedToNetwork() == true {
            print("Internet Connection Successful")
            if (FBSDKAccessToken.currentAccessToken() != nil)
            {
                // User is already logged in, go to next view controller.
                returnUserData()
            }
            else
            {
                let loginView : FBSDKLoginButton = FBSDKLoginButton()
                self.view.addSubview(loginView)
                loginView.center = self.view.center
                loginView.readPermissions = ["public_profile", "email", "user_friends"]
                loginView.delegate = self
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if Reachability.connectedToNetwork() == true {
        
            if ((error) != nil){
                // Process error
                let alert = UIAlertController(title: "Facebook Login Error", message: "There was an error when trying to log you in. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else if result.isCancelled {
                // Handle cancellations
            }
            else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                if result.grantedPermissions.contains("email")
                {
                    // Maybe set a flag here???
                }
                returnUserData()
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        
        self.verifyLabel.hidden = false
        self.verifySpinner.hidden = false
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, first_name, last_name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error better here
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let firstName : NSString = result.valueForKey("first_name") as! NSString
                self.first = result.valueForKey("first_name") as! String
                print("First name is: \(firstName)")
                self.last = result.valueForKey("last_name") as! String
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
                
                self.verifyURL()
            }
        })
    }
    
    func verifyURL() {
        
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
            if self.urlPath == "http://10.0.0.246/get_house_members.php"{
                self.urlPath = "http://50.156.82.136/get_house_members.php"
                self.verifyURL()
            }
            else {
                let alert = UIAlertView(title: "Connection Error", message: "There was an error connecting to the server. Please try again later.", delegate: nil, cancelButtonTitle: "Close")
                alert.show()
            }
        }
        else {
            self.parseJSON()
        }
    }
    
    func parseJSON() {
        
        let url: NSURL = NSURL(string:self.urlPath)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        let bodyData = "first=\(self.first)&last=\(self.last)"
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request as NSURLRequest, queue: NSOperationQueue.mainQueue())
        {(response, data, error) in
            if let HTTPResponse = response as? NSHTTPURLResponse {
                let statusCode = HTTPResponse.statusCode
                if statusCode == 200 {
                    let output: NSString = (NSString(data: data!, encoding: NSUTF8StringEncoding))!
                    
                    if let data = output.dataUsingEncoding(NSUTF8StringEncoding) {
                        do {
                            let ret = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String:AnyObject]
                            if (ret["success"] as! NSNumber) == 1 {
                                self.verifyLabel.hidden = true
                                self.verifySpinner.hidden = true
                                self.performSegueWithIdentifier("loginSuccess", sender: nil)
                            }
                            else {
                                self.verifyLabel.hidden = true
                                self.verifySpinner.hidden = true
                                
                                let alert = UIAlertController(title: "Application Login Error", message: "Sorry, this app can only be used by those who are a part of team Grayson.", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                            
                        } catch let error as NSError {
                            self.verifyLabel.hidden = true
                            self.verifySpinner.hidden = true
                            
                            let alert = UIAlertController(title: "Application Login Error", message: "Sorry, there seems to be a server issue currently, please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
                else {
                    self.verifyLabel.hidden = true
                    self.verifySpinner.hidden = true
                    
                    let alert = UIAlertController(title: "Application Login Error", message: "Sorry, there seems to be a server issue currently, please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
