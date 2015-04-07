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
        return calendar.dateWithEra(1, year: 2015, month: 1, day: 1, hour: 9, minute: 30, second: 0, nanosecond: 0)!
    }
}



class ReminderVC: UITableViewController {

    var parameters = ["Time", "Frequency"]
    var rightbarBtn = UIBarButtonItem()
    var timeChosen = NSDate()
    lazy var setRemVC = SetReminderVC()
    
    var timeRemBool: Bool = false
    
    @IBOutlet var myTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "Reminders"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        
        rightbarBtn = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "EditReminder")
        navigationItem.rightBarButtonItems = [rightbarBtn]
        
        setValueForReminder()
    }
   
    
    override func viewWillAppear(animated: Bool) {
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        self.tableView.reloadData()
    }
    
    
    func setValueForReminder(){
        if(NSUserDefaults.standardUserDefaults().objectForKey("Set Reminder") == nil) {
            timeChosen = NSDate.defaultTime()
        } else {
            timeChosen = NSUserDefaults.standardUserDefaults().objectForKey("Set Reminder") as NSDate
            println("Time Changed: \(timeChosen)")
        }
    }
    
    
    func saveTimeForReminder(){
          NSUserDefaults.standardUserDefaults().setObject(timeChosen, forKey: "Set Reminder")
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
            let formatter = NSDateFormatter()
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            cell.reminderValue?.text = formatter.stringFromDate(timeChosen)
        } else {
            cell.reminderValue?.text = "Daily"
        }
        
        cell.reminderLabel.text = parameters[indexPath.row]
        return cell
    }
   
    
    @IBAction func AddReminderButtonPressed(sender: AnyObject) {
        scheduleLocalNotification()
        saveTimeForReminder()
        
        var alert = UIAlertController(title: nil, message: "Reminder Added !!", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            println("Reminder Added")
            self.navigationController?.popViewControllerAnimated(true)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func setTimeChosen(date: NSDate) {
        timeChosen = date
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
        vc.dateChosen = timeChosen
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}
