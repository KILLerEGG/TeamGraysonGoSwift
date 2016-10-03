//
//  GarageContentViewController.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 8/9/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import UIKit

class GarageContentViewController: UIViewController {

    @IBOutlet weak var garageLargeBackground: UIImageView!
    
    @IBOutlet weak var passLargeBackground: UIImageView!
    @IBOutlet weak var weekTitleLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var garageUser1NameLabel: UILabel!
    @IBOutlet weak var garageUser2NameLabel: UILabel!
    @IBOutlet weak var passUserNameLabel: UILabel!
    
    @IBOutlet weak var garageUser1ImageView: UIImageView!
    @IBOutlet weak var garageUser2ImageView: UIImageView!
    @IBOutlet weak var passImageView: UIImageView!
    
    var pageIndex: Int = 0
    
    var weekText: String?
    var dateText: String?
    var garageUser1Text: String?
    var garageUser2Text: String?
    var passUserText: String?
    
    var garageUser1ImageData: NSData?
    var garageUser2ImageData: NSData?
    var passImageData: NSData?
    
    var garageBackgroundColors = [UIColor(red: 244/255, green: 134/255, blue: 0/255, alpha: 1.0), UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0), UIColor(red: 234/255, green: 230/255, blue: 0/255, alpha: 1.0), UIColor(red: 28/255, green: 188/255, blue: 0/255, alpha: 1.0), UIColor(red: 0/255, green: 183/255, blue: 140/255, alpha: 1.0), UIColor(red: 0/255, green: 112/255, blue: 173/255, alpha: 1.0), UIColor(red: 160/255, green: 0/255, blue: 155/255, alpha: 1.0), UIColor(red: 178/255, green: 0/255, blue: 32/255, alpha: 1.0)]
    
    var passBackgroundColors = [UIColor(red: 242/255, green: 177/255, blue: 104/255, alpha: 1.0), UIColor(red: 209/255, green: 94/255, blue: 94/255, alpha: 1.0), UIColor(red: 232/255, green: 228/255, blue: 118/255, alpha: 1.0), UIColor(red: 111/255, green: 186/255, blue: 98/255, alpha: 1.0), UIColor(red: 92/255, green: 181/255, blue: 158/255, alpha: 1.0), UIColor(red: 99/255, green: 145/255, blue: 170/255, alpha: 1.0), UIColor(red: 158/255, green: 91/255, blue: 155/255, alpha: 1.0), UIColor(red: 175/255, green: 79/255, blue: 95/255, alpha: 1.0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let randNum = Int(arc4random_uniform(UInt32(self.garageBackgroundColors.count)))
        
        if (garageLargeBackground != nil){
            garageLargeBackground.backgroundColor = self.garageBackgroundColors[randNum]
        }
        
        if (passLargeBackground != nil){
            passLargeBackground.backgroundColor = self.passBackgroundColors[randNum]
        }
        
        if (weekTitleLabel != nil){
            weekTitleLabel.text = self.weekText
        }
        
        if (dateTextLabel != nil){
            dateTextLabel.text = self.dateText
        }
        
        if (garageUser1NameLabel != nil){
            garageUser1NameLabel.text = self.garageUser1Text
        }
        
        if (garageUser2NameLabel != nil){
            garageUser2NameLabel.text = self.garageUser2Text
        }
        
        if (passUserNameLabel != nil){
            passUserNameLabel.text = self.passUserText
        }
    }
}
