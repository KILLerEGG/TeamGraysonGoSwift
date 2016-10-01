//
//  MenuController.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class MenuController: UITableViewController, NSURLSessionDataDelegate, FBSDKLoginButtonDelegate {
    @IBOutlet weak var usernameWelcomeLabel: UILabel!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    var first_name:String = ""
    var device_token:String = ""
    var urlBase: String = "http://10.0.0.246/"
    
    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, first_name, last_name"])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fbLoginButton.delegate = self
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                self.usernameWelcomeLabel.text = "Welcome!"
            }
            else
            {
                let firstName : NSString = result.valueForKey("first_name") as! NSString
                self.first_name = firstName as String
                self.usernameWelcomeLabel.text = "Welcome, \(firstName)"
                
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let deviceToken = delegate.tokenString
                self.device_token = deviceToken
                print("Menu-Device Token: " + self.device_token)
                self.checkConnection()
            }
        })
    }
    
    func addDevice() {
        let registerUrl: NSURL = NSURL(string: self.urlBase+"addDevice.php")!
        let registerRequest:NSMutableURLRequest = NSMutableURLRequest(URL: registerUrl)
        let registerBodyData = "user=\(self.first_name)&id=\(self.device_token)"
        registerRequest.HTTPMethod = "POST"
        registerRequest.HTTPBody = registerBodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(registerRequest as NSURLRequest, queue: NSOperationQueue.mainQueue())
        {(response, data, error) in
            if let HTTPResponse = response as? NSHTTPURLResponse {
                let statusCode = HTTPResponse.statusCode
                if statusCode == 200 {
                    print("registered device successfully")
                }
                else {
                    print("error occurred in device registration")
                }
            }
        }
    }
    
    func checkConnection(){
        if Reachability.connectedToNetwork() == true {
            verifyUrl()
        }
    }
    
    func verifyUrl() {
        
        let url: NSURL = NSURL(string: self.urlBase)!
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
            if self.urlBase == "http://10.0.0.246/"{
                self.urlBase = "http://50.156.82.136/"
                self.verifyUrl()
            }
            else {
                let alert = UIAlertController(title: "Connection Error", message: "Unable to connect to server right now. Please try again, or wait until later to try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                    self.checkConnection()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
        else {
            self.addDevice()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!){
        
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
                // Nothing to do right now, everything worked well
            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        performSegueWithIdentifier("logOut", sender: nil)
    }

    
    // MARK: - Table view data source


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
