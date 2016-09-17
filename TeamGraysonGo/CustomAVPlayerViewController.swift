//
//  CustomAVPlayerViewController.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 9/16/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class CustomAVPlayerViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyViewController.onVideoEnd(_:), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: <#T##AnyObject?#>).addObserver(self, selector: #
        super.viewWillDisappear(animated)
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
