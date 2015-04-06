//
//  SetReminderVC.swift
//  Notes
//
//  Created by Rational Bits on 20/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.
//

import UIKit

class SetReminderVC: UIViewController {

    @IBOutlet var reminderDatePicker: UIDatePicker!
   
    internal var userDateChosen = NSDate()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Time"
        reminderDatePicker.datePickerMode = UIDatePickerMode.Time
        
        reminderDatePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    func datePickerChanged(datePicker:UIDatePicker) {
        userDateChosen = datePicker.date
        println("Date: \(userDateChosen)")
        NSUserDefaults.standardUserDefaults().setObject(datePicker.date, forKey: "Set Reminder")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    
 
    
  
}
