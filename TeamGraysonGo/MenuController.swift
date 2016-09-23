//
//  MenuController.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class MenuController: UITableViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var usernameWelcomeLabel: UILabel!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
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
                self.usernameWelcomeLabel.text = "Welcome, \(firstName)"
            }
        })
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
