//
//  OptionVC.swift
//  TestDate
//
//  Created by Ankit Mishra on 13/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.
//

import UIKit

class OptionVC: UIViewController {
   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
        override func viewDidLoad() {
            super.viewDidLoad()
            datePicker.hidden = true;
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        
        @IBAction func bookAMonthButtonPressed(sender: AnyObject) {
            UIApplication.sharedApplication().openURL(NSURL(string:"http://www.google.com")!)
            
        }
        
        @IBAction func reminderButtonPressed(sender: AnyObject) {
            if(datePicker.hidden == true){
                datePicker.hidden = false;
            }
            else{
                var alert = UIAlertView(title: "Reminder Ser", message: String(format: "Reminder Set for %@", datePicker.date), delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                datePicker.hidden = true
                scheduleLocalNotification()
            }
        }
        
        
        @IBAction func signOutButtonPressed(sender: AnyObject) {
            PFUser.logOut()
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        func scheduleLocalNotification() {
            
            var localNotification = UILocalNotification()
            localNotification.fireDate = fixNotificationDate(datePicker.date)
            localNotification.alertBody = "Hey, Check you Notes."
            localNotification.alertAction = "Notes"
            localNotification.repeatInterval = .CalendarUnitDay
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
        
        func fixNotificationDate(dateToFix: NSDate) -> NSDate {
            
            var dateComponets: NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: dateToFix)
            
            dateComponets.second = 0
            var fixedDate: NSDate! = NSCalendar.currentCalendar().dateFromComponents(dateComponets)
            
            return fixedDate
        }
        
        
   

}
