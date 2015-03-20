//
//  ReminderVC.swift
//  Notes
//
//  Created by Rational Bits on 20/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.
//

import UIKit

extension NSDate
{
    class func defaultTime() -> NSDate
    {
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        return calendar.dateWithEra(1, year: 2015, month: 1, day: 1, hour: 9, minute: 59, second: 0, nanosecond: 0)!
    }
}



class ReminderVC: UITableViewController {

    var parameters = ["Time", "Frequency"]
    var rightbarBtn = UIBarButtonItem()
    var timeChosen = NSDate()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rightbarBtn = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "EditReminder")
        navigationItem.rightBarButtonItems = [rightbarBtn]
       
        if(NSUserDefaults.standardUserDefaults().objectForKey("Set Reminder") == nil){
            timeChosen = NSDate.defaultTime()
            println("My Time: \(timeChosen)")
        }else{
            timeChosen = NSUserDefaults.standardUserDefaults().objectForKey("Set Reminder") as NSDate
            println("My Time: \(timeChosen)")
        }
        
       
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

  
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Reminder Cell", forIndexPath: indexPath) as ReminderCell

        
        if(indexPath.row == 0){
           var dateComponets: NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: timeChosen)
            dateComponets.second = 0
            var selectedDate: NSDate! = NSCalendar.currentCalendar().dateFromComponents(dateComponets)
            
            let formatter = NSDateFormatter()
            formatter.timeZone = NSTimeZone.localTimeZone()
            formatter.dateFormat = "HH:MM a"
            
            cell.reminderValue?.text = formatter.stringFromDate(selectedDate)
        }else{
            cell.reminderValue?.text = "Daily"
        }
        
        cell.reminderLabel.text = parameters[indexPath.row]
        println(cell.reminderValue.text)

        return cell
    }
   
    
    @IBAction func AddReminderButtonPressed(sender: AnyObject) {
        scheduleLocalNotification()
        println("Add my reminder!! ")
        
        self.navigationController?.popViewControllerAnimated(true)
    }
        
        
    func scheduleLocalNotification() {
        var localNotification = UILocalNotification()
        localNotification.fireDate = fixNotificationDate(timeChosen)
        localNotification.alertBody = "Hey, Check you Notes."
        localNotification.alertAction = "Notes"
        localNotification.repeatInterval = .CalendarUnitDay
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    
    func fixNotificationDate(dateToFix: NSDate) -> NSDate {
        var dateComponets: NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: dateToFix)
        
        dateComponets.second = 0
        var fixedDate: NSDate! = NSCalendar.currentCalendar().dateFromComponents(dateComponets)
        
        return fixedDate
    }
    

    func EditReminder(){
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SetReminderVC") as SetReminderVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

   
}
