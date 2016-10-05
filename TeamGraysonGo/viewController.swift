//
//  ViewController.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 8/7/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class viewController: UIViewController, UIPageViewControllerDataSource, GarageModelProtocal {
    
    @IBOutlet weak var garageNavBar: UINavigationItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    var garageUsers: [GarageModelObj] = [GarageModelObj]()
    var passUser: GarageModelObj = GarageModelObj()
    var outsideUsers: [GarageModelObj] = [GarageModelObj]()
    var feedItems: [GarageModelObj] = [GarageModelObj]()
    var prevGarageUser1: GarageModelObj = GarageModelObj()
    var prevGarageUser2: GarageModelObj = GarageModelObj()
    var prevPassUser: GarageModelObj = GarageModelObj()
    var nextGarageUser1: GarageModelObj = GarageModelObj()
    var nextGarageUser2: GarageModelObj = GarageModelObj()
    var nextPassUser: GarageModelObj = GarageModelObj()
    
    var garagePageViewController: UIPageViewController!
    
    func reloadData() {
        
        if Reachability.connectedToNetwork() == true {
            // Load garage data from PHP call
            let garageModel = GarageModel()
            garageModel.delegate = self
            garageModel.downloadItems()
            
            // Initialize the menu button and its action
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
    
    func getWeekDaysInEnglish() -> [String] {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        //calendar.locale = NSLocale(localeIdentifier: "en_US")
        return calendar.weekdaySymbols
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarOptions: NSCalendarOptions {
            switch self {
            case .Next:
                return .MatchNextTime
            case .Previous:
                return [.SearchBackwards, .MatchNextTime]
            }
        }
    }
    
    func getDate(direction: SearchDirection, _ dayName: String, considerToday consider: Bool = false, newStartDate sDate: NSDate) -> NSDate {
        let weekdaysName = getWeekDaysInEnglish()
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let nextWeekDayIndex = weekdaysName.indexOf(dayName)! + 1 // weekday is in form 1 ... 7 where as index is 0 ... 6
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        if consider && calendar.component(.Weekday, fromDate: sDate) == nextWeekDayIndex {
            return sDate
        }
        
        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        
        
        let date = calendar.nextDateAfterDate(sDate, matchingComponents: nextDateComponent, options: direction.calendarOptions)
        return date!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPrevWeek(numWeeks: Int){
        let weekAddition: Int = (2 * numWeeks) * -1
        var garage_user1_it: Int = ((Int(self.garageUsers[0].order!)! % self.feedItems.count) + weekAddition) % self.feedItems.count
        if garage_user1_it < 0{
            garage_user1_it = garage_user1_it + self.feedItems.count
        }
        var garage_user2_it: Int = ((Int(self.garageUsers[1].order!)! % self.feedItems.count) + weekAddition) % self.feedItems.count
        if garage_user2_it < 0{
            garage_user2_it = garage_user2_it + self.feedItems.count
        }
        var pass_user_it: Int = ((Int(self.passUser.order!)! % self.feedItems.count) + weekAddition) % self.feedItems.count
        if pass_user_it < 0{
            pass_user_it = pass_user_it + self.feedItems.count
        }
        
        for i in 0...(self.feedItems.count-1){
            let item: GarageModelObj = self.feedItems[i]
            if Int(item.order!)! == garage_user1_it {
                prevGarageUser1 = item
            }
            else if Int(item.order!)! == garage_user2_it {
                prevGarageUser2 = item
            }
            else if Int(item.order!)! == pass_user_it {
                prevPassUser = item
            }
        }
    }
    
    func getNextWeek(numWeeks: Int){
        let weekAddition: Int = 2 * numWeeks
        let garage_user1_it: Int = (Int(self.garageUsers[0].order!)! + weekAddition) % self.feedItems.count
        let garage_user2_it: Int = (Int(self.garageUsers[1].order!)! + weekAddition) % self.feedItems.count
        let pass_user_it: Int = (Int(self.passUser.order!)! + weekAddition) % self.feedItems.count
        
        for i in 0...(self.feedItems.count-1){
            let item: GarageModelObj = self.feedItems[i]
            if Int(item.order!)! == garage_user1_it {
                nextGarageUser1 = item
            }
            else if Int(item.order!)! == garage_user2_it {
                nextGarageUser2 = item
            }
            else if Int(item.order!)! == pass_user_it {
                nextPassUser = item
            }
        }
    }
    
    func getPictures() -> [pictures]{
        var newArray = [pictures]()
        for i in 0...(feedItems.count-1){
            let newPic = pictures(name: feedItems[i].name!, id: feedItems[i].idNum!)
            newArray.append(newPic)
        }
        return newArray
    }

    func itemsDownloaded(items: NSArray){
        
        loadingSpinner.stopAnimating()
        
        for i in 0...(items.count-1) {
            let item: GarageModelObj = items[i] as! GarageModelObj
            if item.garage == "1"{
                garageUsers.append(GarageModelObj(name: item.name!, garage: item.garage!, outside: item.outside!, pass: item.pass!, order: item.order!, idNum: item.idNum!))
            }
            else if item.pass == "1" {
                passUser = item
            }
            else {
                outsideUsers.append(GarageModelObj(name: item.name!, garage: item.garage!, outside: item.outside!, pass: item.pass!, order: item.order!, idNum: item.idNum!))
            }
            feedItems.append(GarageModelObj(name: item.name!, garage: item.garage!, outside: item.outside!, pass: item.pass!, order: item.order!, idNum: item.idNum!))
        }
        self.getPrevWeek(1)
        self.getNextWeek(1)
        
        self.garagePageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GaragePageViewController") as! UIPageViewController
        self.garagePageViewController.dataSource = self
        
        let startingViewController = self.viewControllerAtIndex(1) as GarageContentViewController!
        let viewControllers = NSArray(object: startingViewController)
        
        self.garagePageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)

        self.garagePageViewController.view.frame = CGRect(x: 0, y: 55, width: self.view.frame.width, height: self.view.frame.size.height - 55) // Make sure to decrease the total height of the view to ensure that page controller and the menu button get displayed and aren't hidden by the view
        
        
        self.addChildViewController(self.garagePageViewController!)
        self.view.addSubview(self.garagePageViewController.view)
        self.garagePageViewController.didMoveToParentViewController(self)
        
    }
    
    func scaleUIImageToSize(image: UIImage, size: CGSize) -> UIImage {
        //let hasAlpha = false
        //let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        //UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        //image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func viewControllerAtIndex(index: Int) -> GarageContentViewController {
        // Return the data view controller for the given index.
        if (index == -1) || (index == 3) {
            return GarageContentViewController()
        }
        
        if Reachability.connectedToNetwork() == true {
            let garageContentController: GarageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GarageContentViewController") as! GarageContentViewController
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            
            if index == 0 {
                //self.garageNavBar.title = String(index)
                garageContentController.weekText = "Last Week"
                let prevEnd: NSDate = getDate(.Previous, "Sunday", newStartDate: NSDate())
                garageContentController.dateText = dateFormatter.stringFromDate(getDate(.Previous, "Monday", newStartDate: prevEnd)) + " - " + dateFormatter.stringFromDate(prevEnd)
                garageContentController.garageUser1Text = self.prevGarageUser1.name
                garageContentController.garageUser2Text = self.prevGarageUser2.name
                garageContentController.passUserText = self.prevPassUser.name
                
                let garageUser1Url = NSURL(string: "http://graph.facebook.com/"+self.prevGarageUser1.idNum!+"/picture?type=large")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL: garageUser1Url!)
                    dispatch_async(dispatch_get_main_queue()) {
                        garageContentController.garageUser1ImageView.contentMode = .ScaleAspectFill
                        if data != nil {
                            garageContentController.garageUser1ImageView.image = UIImage(data: data!)
                        }
                    }
                }
                
                let garageUser2Url = NSURL(string: "http://graph.facebook.com/"+self.prevGarageUser2.idNum!+"/picture?type=large")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL: garageUser2Url!)
                    dispatch_async(dispatch_get_main_queue()) {
                        garageContentController.garageUser2ImageView.contentMode = .ScaleAspectFill
                        if data != nil {
                            garageContentController.garageUser2ImageView.image = UIImage(data: data!)
                        }
                    }
                }
            
                let passUrl = NSURL(string: "http://graph.facebook.com/"+self.prevPassUser.idNum!+"/picture?type=large")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL: passUrl!)
                    dispatch_async(dispatch_get_main_queue()) {
                        garageContentController.passImageView.contentMode = .ScaleAspectFill
                        if data != nil {
                            garageContentController.passImageView.image = UIImage(data: data!)
                        }
                    }
                }
            }
            else if index == 1 {
                //self.garageNavBar.title = String(index)
                garageContentController.weekText = "This Week"
                garageContentController.dateText = dateFormatter.stringFromDate(getDate(.Previous, "Monday", considerToday: true, newStartDate: NSDate())) + " - " + dateFormatter.stringFromDate(getDate(.Next, "Sunday", considerToday: true, newStartDate: NSDate()))
                garageContentController.garageUser1Text = self.garageUsers[0].name
                garageContentController.garageUser2Text = self.garageUsers[1].name
                garageContentController.passUserText = self.passUser.name
                
                let garageUser1Url = NSURL(string: "http://graph.facebook.com/"+self.garageUsers[0].idNum!+"/picture?type=large")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL: garageUser1Url!)
                    dispatch_async(dispatch_get_main_queue()) {
                        garageContentController.garageUser1ImageView.contentMode = .ScaleAspectFill
                        if data != nil {
                            garageContentController.garageUser1ImageView.image = UIImage(data: data!)
                        }
                    }
                }
                
                let garageUser2Url = NSURL(string: "http://graph.facebook.com/"+self.garageUsers[1].idNum!+"/picture?type=large")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL: garageUser2Url!)
                    dispatch_async(dispatch_get_main_queue()) {
                        garageContentController.garageUser2ImageView.contentMode = .ScaleAspectFill
                        if data != nil {
                            garageContentController.garageUser2ImageView.image = UIImage(data: data!)
                        }
                    }
                }
                
                let passUrl = NSURL(string: "http://graph.facebook.com/"+self.passUser.idNum!+"/picture?type=large")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {                    let data = NSData(contentsOfURL: passUrl!)
                    dispatch_async(dispatch_get_main_queue()) {
                        garageContentController.passImageView.contentMode = .ScaleAspectFill
                        if data != nil {
                            garageContentController.passImageView.image = UIImage(data: data!)
                        }
                    }
                }
            }
            else {
                //self.garageNavBar.title = String(index)
                let nextStart: NSDate = getDate(.Next, "Monday", newStartDate: NSDate())
                garageContentController.weekText = "Next Week"
                garageContentController.dateText = dateFormatter.stringFromDate(nextStart) + " - " + dateFormatter.stringFromDate(getDate(.Next, "Sunday", newStartDate: nextStart))
                garageContentController.garageUser1Text = self.nextGarageUser1.name
                garageContentController.garageUser2Text = self.nextGarageUser2.name
                garageContentController.passUserText = self.nextPassUser.name
                
                let garageUser1Url = NSURL(string: "http://graph.facebook.com/"+self.nextGarageUser1.idNum!+"/picture?type=large")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL: garageUser1Url!)
                    dispatch_async(dispatch_get_main_queue()) {
                        garageContentController.garageUser1ImageView.contentMode = .ScaleAspectFill
                        if data != nil {
                            garageContentController.garageUser1ImageView.image = UIImage(data: data!)
                        }
                    }
                }
                
                let garageUser2Url = NSURL(string: "http://graph.facebook.com/"+self.nextGarageUser2.idNum!+"/picture?type=large")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {                    let data = NSData(contentsOfURL: garageUser2Url!)
                    dispatch_async(dispatch_get_main_queue()) {
                        garageContentController.garageUser2ImageView.contentMode = .ScaleAspectFill
                        if data != nil {
                            garageContentController.garageUser2ImageView.image = UIImage(data: data!)
                        }
                    }
                }
            
                let passUrl = NSURL(string: "http://graph.facebook.com/"+self.nextPassUser.idNum!+"/picture?type=large")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL: passUrl!)
                    dispatch_async(dispatch_get_main_queue()) {
                        garageContentController.passImageView.contentMode = .ScaleAspectFill
                        if data != nil {
                            garageContentController.passImageView.image = UIImage(data: data!)
                        }
                    }
                }
            }
            
            garageContentController.pageIndex = index
            return garageContentController
        }
        else {
            let alert = UIAlertController(title: "Internet Connection Error", message: "No data connection detected. Please ensure you have a data connection to retry.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
                self.reloadData()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return GarageContentViewController()
        }
    }
    
    // MARK - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as? GarageContentViewController
        var index = vc!.pageIndex as Int
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as? GarageContentViewController
        var index = vc!.pageIndex as Int
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == 3 {
            return nil
        }
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 3
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 1
    }
}

