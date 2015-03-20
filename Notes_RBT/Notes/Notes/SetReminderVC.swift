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
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var leftbarBtn = UIBarButtonItem(title: "Reminders", style: UIBarButtonItemStyle.Plain, target: self, action: "PickDateFromDatePicker")
        navigationItem.leftBarButtonItems = [leftbarBtn]
 
        self.navigationItem.title = "Time"
       
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func PickDateFromDatePicker() {
        var dateChosen = reminderDatePicker.date
        
        reminderDatePicker.datePickerMode = UIDatePickerMode.Time
        
        println("Date: \(dateChosen)")
        NSUserDefaults.standardUserDefaults().setObject(dateChosen, forKey: "Set Reminder")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.navigationController?.popViewControllerAnimated(true)
    }

  
}
