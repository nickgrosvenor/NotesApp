//
//  OptionVC.swift
//  TestDate
//
//  Created by Ankit Mishra on 13/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.



import UIKit

class OptionVC: UIViewController {
   
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings"
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor(red:247/255.0, green:247/255.0, blue:247/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor(red:73.0/255.0, green: 155.0/255.0, blue: 255.0/255.0, alpha:1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.clearColor()]
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func bookAMonthButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http://www.google.com")!)
    }
    
    
    @IBAction func reminderButtonPressed(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ReminderVC") as ReminderVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func signOutButtonPressed(sender: AnyObject) {
        PFUser.logOut()
        self.navigationController?.popViewControllerAnimated(true)
    }
    

}
