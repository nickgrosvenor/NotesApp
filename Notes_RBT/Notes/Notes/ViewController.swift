//
//  ViewController.swift
//  TestDate
//
//  Created by Ankit Mishra on 12/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dateArray = [AnyObject]()
    var monthSection = [Int]()
    var isLoading = false
    var lastDate = NSDate()
    var bgImages = ["1BG.png","2BG.png","3BG.png","4BG.png"]
    var parseData = [AnyObject]()
    var indexValue = 0;
    var sectionValue = 0;
    let userCalendar = NSCalendar.currentCalendar()
    let dateFormter = NSDateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get Date Data
        
        self.navigationItem.title = "Timeline"
        let logo = UIImage(named: "uploadistLogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.dataSource = self
        tableView.delegate = self
        getDateData(false)
        
        var bgImageView = UIImageView()
        for i in 1...bgImages.count {
            var randomIndex = Int(arc4random_uniform(UInt32(bgImages.count)))
            bgImageView.image = UIImage(named: "\(bgImages[randomIndex])")
            self.tableView.backgroundView = bgImageView
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        if (PFUser.currentUser() == nil)
        {
            var logInViewController = PFLogInViewController()
            logInViewController.delegate = self
            
            var signUpViewController = PFSignUpViewController()
            signUpViewController.delegate = self
            
            logInViewController.signUpController = signUpViewController
            self.presentViewController(logInViewController, animated: true, completion: nil)
        }
        else{
            fetchDataFromParse()
        }
        
    }
    
    
    // Method for Parse Login & Delegates
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        if (!username.isEmpty || !password.isEmpty) {
            return true
        } else {
            return false
        }
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        println("Ankti login")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        println("Failed to login")
    }
    
    // Method for Parse SignUp & Delegates
    func signUpViewController(signUpController: PFSignUpViewController!, shouldBeginSignUp info: [NSObject : AnyObject]!) -> Bool {
        if let password = info?["password"] as? String{
            return true
        } else {
            return false
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        println("Ankiti login")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        println("User dismissed signup")
    }
    
    
    func isYearLeapYear(year:Int)->Bool{
        return (( year%100 != 0) && (year%4 == 0)) || year%400 == 0
    }
    
    //    - (BOOL)isYearLeapYear:(NSDate *) aDate {
    //    NSInteger year = [self yearFromDate:aDate];
    //    return (( year%100 != 0) && (year%4 == 0)) || year%400 == 0;
    //    }
    
    
    // Date Work
    func getDateData(loadingMoreData:Bool){
        var total = 75
        var i = 0
        var previousMonth = 0
        var currentdate = NSDate()
        var oneTimeExecute = false
        
        
        if(loadingMoreData){
            currentdate = lastDate
            isLoading = true
            i=1
            oneTimeExecute = true
            previousMonth = monthSection.last!
        }else{
            currentdate = NSDate()
            previousMonth = 0
        }
        
        dateFormter.dateFormat = "yyyy"
        var year  = dateFormter.stringFromDate(NSDate()).toInt()
        
        var check = isYearLeapYear(year!)
        
        if(check){
            total = 366
        }
        else{
            total = 365
        }
        
        dateFormter.dateFormat = "yyyy-MM-dd"
        currentdate = dateFormter.dateFromString("\(year!)-01-01")!
        
        let userCalendar = NSCalendar.currentCalendar()
        var tempArr = [AnyObject]()
        for (i;i<total;i++){
            
            let date = userCalendar.dateByAddingUnit(
                .DayCalendarUnit,
                value: i,
                toDate: currentdate,
                options: nil)!
            
            var dateComp = userCalendar.components(.CalendarUnitMonth, fromDate: date)
            var month = dateComp.month
            
            
            var d1 = dateFormter.stringFromDate(date)
            var d2 = dateFormter.stringFromDate(NSDate())
            
            var dateComparisionResult:NSComparisonResult = d2.compare(d1)
            if dateComparisionResult == NSComparisonResult.OrderedSame
            {
                indexValue = tempArr.count
                sectionValue = monthSection.last! - 1
            }
            
            
            if(contains(monthSection, month)){
                // check
            }
            else{
                if(i==0){
                    monthSection.append(month)
                }
                else if(month != previousMonth){
                    
                    if isLoading && contains(monthSection, previousMonth) && oneTimeExecute{
                        oneTimeExecute = false
                        var arr: Array = (dateArray.last as NSArray) as Array
                        for (var k=0;k<tempArr.count;k++){
                            arr.append(tempArr[k])
                        }
                        dateArray.removeLast()
                        dateArray.append(arr)
                        tempArr.removeAll()
                        
                        monthSection.append(month)
                    }
                    else{
                        monthSection.append(month)
                        dateArray.append(tempArr)
                        tempArr.removeAll()
                    }
                }
            }
            
            tempArr.append(date)
            
            // assign for next Itteration
            previousMonth = month
            
            // Add last element
            if(i==total-1){
                lastDate = date
                dateArray.append(tempArr)
            }
        }
        tableView.reloadData()
        isLoading = false
        
        let indexPath = NSIndexPath(forRow: indexValue, inSection: sectionValue)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MainCell") as TableViewCell
        
        let tempArr = dateArray[indexPath.section] as NSArray
        let date = tempArr[indexPath.row] as NSDate
        
        var dateComp = userCalendar.components(.CalendarUnitDay | .CalendarUnitWeekday, fromDate: date)
        var day = dateComp.day
        var weekDay = dateComp.weekday
        
        dateFormter.dateFormat = "MMM dd, yyyy"
        var dateTitle = dateFormter.stringFromDate(date as NSDate)
        var isfound = false
        var noteData = ""
        
        if(parseData.count>0)
        {
            for (var i=0;i<parseData.count;i++) {
                var dict: (AnyObject) = parseData[i]
                
                if ( dict["Date"] as String == dateTitle ){
                    isfound = true
                    noteData = dict["Note"] as String
                    break
                }
            }
        }
        
        cell.dateLabel.text = String(format:"%d", day) as NSString
        cell.weekDayLbl.text = getDayOfWeek(dateComp.weekday)
        
        if isfound {
            cell.noteLabel.text = noteData
        }
        else{
            cell.noteLabel.text = ""
        }
        
        cell.dateLabel.textColor = UIColor.whiteColor()
        cell.weekDayLbl.textColor = UIColor.whiteColor()
        cell.noteLabel.textColor = UIColor.whiteColor()
        
        cell.dateLabel.font = UIFont(name: "HelveticaNeue-Ultralight", size: 32)
        cell.weekDayLbl.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        cell.noteLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    
    
    // Table View Delegate & DataSource Method
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ShowNoteVC") as ShowNotesVC
        vc.dateArray = dateArray
        vc.parseData = parseData
        vc.section = indexPath.section
        vc.index = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateArray[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return monthSection.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRectMake(0,0, tableView.frame.width, 50))
        view.backgroundColor = UIColor.clearColor()
        var label = UILabel()
        label.frame = CGRectMake(0, 0, tableView.frame.width, 50)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(30)
        label.text = getMonthName(monthSection[section])
        label.textColor = UIColor.whiteColor()
        view.addSubview(label)
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 107
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height){
            if !isLoading{
                //                getDateData(true)
            }
        }
    }
    
    
    // Method to get Week Name
    func getDayOfWeek(today: Int) -> String {
        var day : String = "" //weekDay as String
        
        switch today {
        case 1:      day = "Sunday"
        case 2:      day = "Monday"
        case 3:      day = "Tuesday"
        case 4:      day = "Wednesday"
        case 5:      day = "Thursday"
        case 6:      day = "Friday"
        case 7:      day = "Saturday"
        default:     day = "Ankit"
            break
        }
        
        return day
    }
    
    // Method to get Month Name
    func getMonthName(today: Int) -> String {
        var currentMonth = ""
        switch today {
        case 1:      currentMonth = "JANUARY"
        case 2:      currentMonth = "FEBRUARY"
        case 3:      currentMonth = "MARCH"
        case 4:      currentMonth = "APRIL"
        case 5:      currentMonth = "MAY"
        case 6:      currentMonth = "JUNE"
        case 7:      currentMonth = "JULY"
        case 8:      currentMonth = "AUGUST"
        case 9:      currentMonth = "SEPTEMBER"
        case 10:     currentMonth = "OCTOBER"
        case 11:     currentMonth = "NOVEMBER"
        case 12:     currentMonth = "DECEMBER"
        default:     currentMonth = "Ankit"
            break
        }
        
        return currentMonth
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func openAddNoteVC(sender: UIBarButtonItem) {
        var isfound = false
        
        dateFormter.dateFormat = "MMM dd, yyyy"
        var dateTitle = dateFormter.stringFromDate(NSDate())
        
        if(parseData.count>0) {
            for (var i=0;i<parseData.count;i++) {
                var dict: (AnyObject) = parseData[i]
                
                if ( dict["Date"] as String == dateTitle ){
                    isfound = true
                    break
                }
            }
        }
        
        if (isfound){
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ShowNoteVC") as ShowNotesVC
            vc.dateArray = dateArray
            vc.parseData = parseData
            vc.section = 0
            vc.index = 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddNoteVC") as AddNoteVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func openOptionVC(sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("OptionVC") as OptionVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func fetchDataFromParse()
    {
        JHProgressHUD.sharedHUD.showInView(UIApplication.sharedApplication().keyWindow!, withHeader: "Loading", andFooter: "")
        
        var userImageFile : PFFile = PFFile()
        
        var findQuery = PFQuery(className: "NotesApp")
        findQuery.whereKey("User", equalTo: PFUser.currentUser())
        
        findQuery.findObjectsInBackgroundWithBlock { (objects: Array!, error : NSError!) -> Void in
            if error == nil && (objects.count > 0)
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    for object in objects {
                        if var imageObj = object["ImageFileData"] as? PFFile{
                            userImageFile = imageObj as PFFile
                        }
                        
                        var userNote = object["Note"] as String
                        var date = object["Date"] as String
                        var dict = ["Image":userImageFile, "Note":userNote, "Date":date]
                        self.parseData.append(dict)
                        
                        userImageFile.getDataInBackgroundWithBlock {(imageData: NSData!, error: NSError!) -> Void in
                            if error == nil {
                                if var uploadImage = imageData as NSData! {
                                    var image = UIImage(data: uploadImage)
                                    var img: String = "\(uploadImage).png"
                                    self.bgImages.append(img)
                                }
                            }
                        }
                    }
                    
                    JHProgressHUD.sharedHUD.hide()
                    self.tableView.reloadData()
                    let indexPath = NSIndexPath(forRow:self.indexValue, inSection: self.sectionValue)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                })
            }
            else{
                JHProgressHUD.sharedHUD.hide()
                println("Error: \(error)")
            }
        }
    } // end of Func
    
}