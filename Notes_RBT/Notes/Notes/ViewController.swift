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
    @IBOutlet weak var bgTableView: UITableView!
    
    var startIndex = NSIndexPath(forRow: 0, inSection: 0)
    var nextIndex = NSIndexPath(forRow: 0, inSection: 0)
    
    @IBOutlet weak var bgimage: UIImageView!
    
    @IBOutlet weak var bgImageSecond: UIImageView!
    var dateArray = [AnyObject]()
    var monthSection = [Int]()
    var isLoading = false
    var lastDate = NSDate()
    
    var bgImages = ["1BG","2BG","3BG","4BG","5BG","6BG","7BG","8BG","9BG","10BG","11BG","12BG","13BG","14BG.png","15BG","16BG","17BG","18BG","19BG","20BG","21BG","22BG","23BG","24BG.png","25BG","26BG","27BG","28BG.png","29BG.png","30BG","31BG","32BG","33BG","34BG","35BG","36BG","37BG","38BG","39BG","40BG","41BG","42BG","44BG","45BG","46BG","47BG","43BG.png"]
    var parseData = [AnyObject]()
    var indexValue = 0;
    var sectionValue = 0;
    var visibleBGCells = 0;
    var nextTimeIndex = 0;
    var nextTimeSection = 0;
    var thresoldHeight =  CGFloat(0)
    var currentLocation = CGFloat(0)
    let userCalendar = NSCalendar.currentCalendar()
    let dateFormter = NSDateFormatter()
   
    var oldSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
    
//    var newSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height + UIScreen.mainScreen().bounds.size.height)
    
    var firstImage = UIImage()
    var nextImage = UIImage()
    var finalImage = UIImage()
    
    var imageIndex = 0
    
    var start = false
    var y = CGFloat(0)
    var fullScroll = false
    var scrollable = true
    var image1 = true
    var divisor = 4
    
//    #define DEVICE_SIZE UIScreen.mainScreen()..size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Timeline"
        let logo = UIImage(named: "uploadistLogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
        self.bgimage.frame = CGRectMake(0.0, 0.0, self.bgimage.frame.size.width, self.bgimage.frame.size.height)
        self.bgimage.contentMode = UIViewContentMode.ScaleAspectFit
        self.bgimage.image = self.getRandomImageFromAssets()
        
        
        self.bgImageSecond.frame = CGRectMake(0.0, self.oldSize.height, self.oldSize.width, self.oldSize.height)
        self.bgImageSecond.contentMode = UIViewContentMode.ScaleAspectFit
        self.bgImageSecond.image = self.getRandomImageFromAssets()
        

        println("How parallax is working")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getDateData(false)
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        println("FullScroll: \(self.fullScroll) Scrollable \(self.scrollable)")
        
        if(!start){//called only once when system based scrolling is done
            println("scrollViewDidScroll - Start")
            start = !start
        }else{
            if(scrollable){
                if(fullScroll){
                    scrollable = false
                    UIView.animateWithDuration(1, delay: 0,
                        options: UIViewAnimationOptions.CurveEaseOut,
                        animations: {
                            if(self.image1){
                                self.bgimage.frame = CGRectMake(0, -self.oldSize.height,self.bgimage.frame.size.width, self.bgimage.frame.size.height)
                                self.bgImageSecond.frame = CGRectMake(0, 0,self.bgImageSecond.frame.size.width, self.bgImageSecond.frame.size.height)
                            }else{
                                self.bgimage.frame = CGRectMake(0, 0,self.bgimage.frame.size.width, self.bgimage.frame.size.height)
                                self.bgImageSecond.frame = CGRectMake(0, -self.oldSize.height,self.bgImageSecond.frame.size.width, self.bgImageSecond.frame.size.height)
                            }
                        }, completion: { finished in
                            
                            if(self.image1){
                                self.bgimage.image = self.getRandomImageFromAssets()
                            }else{
                                self.bgImageSecond.image = self.getRandomImageFromAssets()
                            }
                            self.y = 0
                            self.image1 = !self.image1
                            println("1. FullScroll: \(self.fullScroll) 2. Scrollable \(self.scrollable)")
                    })
                }else{
                    if(image1){
                        bgimage.frame = CGRectMake(0, --y,bgimage.frame.size.width, bgimage.frame.size.height)
                        bgImageSecond.frame = CGRectMake(0, (oldSize.height + y),bgImageSecond.frame.size.width, bgImageSecond.frame.size.height)
                    }else{
                        bgimage.frame = CGRectMake(0, (oldSize.height + y),bgimage.frame.size.width, bgimage.frame.size.height)
                        bgImageSecond.frame = CGRectMake(0, --y,bgImageSecond.frame.size.width, bgImageSecond.frame.size.height)
                    }
                }
            }
        }
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        println("ScrollViewDidEndDecelerating")
        fullScroll = false
        scrollable = true
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if(indexPath.row % divisor == 0 && start && !fullScroll){
            
            fullScroll = true
        }
        
    }
    
    
    func getRandomImageFromAssets() -> UIImage{
        var randomIndex = Int(arc4random_uniform(UInt32(bgImages.count)))
        var noteImage = UIImage(named: "\(bgImages[randomIndex])")
        return noteImage!
    }
    
    
    
    
    override func viewWillAppear(animated: Bool) {
       self.navigationController?.navigationBar.barTintColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
        
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
        self.dismissViewControllerAnimated(true, completion: nil)
        fetchDataFromParse()
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
        self.dismissViewControllerAnimated(true, completion: nil)
        fetchDataFromParse()
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
  
    func maxOffsetForScrollView(scrollView: UIScrollView) -> CGFloat{
        
        var  contentWidth = scrollView.contentSize.height as CGFloat
        var  frameWidth = CGRectGetWidth(scrollView.frame) as CGFloat
        
        return contentWidth - frameWidth
        
        
    }
    
    
    
    
    
    
    /*
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        currentLocation = scrollView.contentOffset.y
    }*/
    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        for (UICollectionViewCell *cell in [self.mainImageCollection visibleCells]) {
//            NSIndexPath *indexPath = [self.mainImageCollection indexPathForCell:cell];
//            NSLog(@"%@",indexPath);
//        }
//    }
    
    
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if(tableView.tag == 100){
//            println("cellForRowAtIndexPath")
//            
//            
//            println(self.bgTableView.numberOfRowsInSection(0))
//            
//            if var imageView = self.bgTableView.cellForRowAtIndexPath(startIndex) as? TableViewCell
//            {
//                imageView.imageView?.image = getRandomImageFromAssets();
//            }
//            
//            nextIndex =  NSIndexPath(forRow: (startIndex.row + 1) , inSection: startIndex.section)
//            
//            if var imageView2 = self.bgTableView.cellForRowAtIndexPath(nextIndex) as? TableViewCell
//            {
//                imageView2.imageView?.image = getRandomImageFromAssets();
//            }
//
//            
//            let parallaxCell = tableView.dequeueReusableCellWithIdentifier("ImageCell", forIndexPath: startIndex) as TableViewCell
////            var bgImage: UIImage = getRandomImageFromAssets()
////                parallaxCell.imageView!.conte image.size
////            parallaxCell.imageView?.alpha = 0.9
////            
//            
//            
//            return parallaxCell
//        }
//        else{
            //println("adding rows")
            
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
            } else {
                cell.noteLabel.text = ""
            }
            
            cell.dateLabel.textColor = UIColor.whiteColor()
            cell.weekDayLbl.textColor = UIColor.whiteColor()
            cell.noteLabel.textColor = UIColor.whiteColor()
            
            cell.dateLabel.font = UIFont(name: "HelveticaNeue-Ultralight", size: 34)
            cell.weekDayLbl.font = UIFont(name: "HelveticaNeue-Light", size: 12)
            cell.noteLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            
            cell.backgroundColor = UIColor.clearColor()
            return cell
        //}
    }
    
    
    
    // Table View Delegate & DataSource Method
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if(tableView.tag == 100){
//            
//            
//        }
//        else{
        
            let tempArr = dateArray[indexPath.section] as NSArray
            let selectedDate = tempArr[indexPath.row] as NSDate
            
            let dateFormter = NSDateFormatter()
            dateFormter.dateFormat = "MMM dd, yyyy"
            var d1 = dateFormter.stringFromDate(selectedDate)
            var d2 = dateFormter.stringFromDate(NSDate())
            
            var dateComparisionResult:NSComparisonResult = d2.compare(d1)
            
            if dateComparisionResult == NSComparisonResult.OrderedSame {
                showDetailVC(indexPath.section, row: indexPath.row)
            }
            else if dateComparisionResult == NSComparisonResult.OrderedAscending {
               // Mark check for current Data in parse
                if(parseData.count > 0) {
                    var isfound = false
                    for (var i=0;i<parseData.count;i++) {
                        var dict: (AnyObject) = parseData[i]
                        if ( dict["Date"] as String == d1) {
                            isfound = true
                            break
                        }
                    }
                    
                    if !isfound{
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddNoteVC") as AddNoteVC
                        vc.currentDate = selectedDate
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else{
                        showDetailVC(indexPath.section, row: indexPath.row)
                    }
                }
                else{
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddNoteVC") as AddNoteVC
                    vc.currentDate = selectedDate
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if dateComparisionResult == NSComparisonResult.OrderedDescending{
                 // Mark check for current Data in parse
                if(parseData.count>0)
                {
                    var isfound = false
                    for (var i=0;i<parseData.count;i++) {
                        var dict: (AnyObject) = parseData[i]
                        if ( dict["Date"] as String == d2 ){
                           isfound = true
                            break
                        }
                    }
                    
                    if !isfound{
                        let alert = UIAlertView(title: nil, message: "First, Enter today's note !! ", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    else{
                        showDetailVC(indexPath.section, row: indexPath.row)
                    }
                }
                else{
                    let alert = UIAlertView(title: nil, message: "First, Enter today's note !! ", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
//        }
    } // end of Method
    
    
    func showDetailVC(section:Int,row:Int){
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ShowNoteVC") as ShowNotesVC
        vc.dateArray = dateArray
        vc.parseData = parseData
        vc.section = section
        vc.index = row
        vc.fromAdd = 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(tableView.tag == 100){
//            return 2
//        }else{
            return dateArray[section].count
//        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        if(tableView.tag == 100){
//            return 1
//        } else{
            return monthSection.count
//        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRectMake(0,0, tableView.frame.width, 50))
        view.backgroundColor = UIColor.clearColor()
        var label = UILabel()
        label.frame = CGRectMake(0, 0, tableView.frame.width, 50)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        label.text = getMonthName(monthSection[section])
        label.textColor = UIColor.whiteColor()
        view.addSubview(label)
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if(tableView.tag == 100){
//            return 0
//        } else {
            return 50
//        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//       if(tableView.tag == 100){
//            return UIScreen.mainScreen().bounds.height
//        } else {
            return 107
//        }
    }
  

    // Method to get WeekDay Name
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
            default:     day = " "
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
            default:     currentMonth = " "
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
            vc.fromAdd = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddNoteVC") as AddNoteVC
            self.navigationController?.pushViewController(vc, animated: true)
            vc.currentDate = NSDate()
        }
    }
    
    
    @IBAction func openOptionVC(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("OptionVC") as OptionVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func fetchDataFromParse(){
        return
        self.parseData.removeAll()
        
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
                        var dict = ["Image":userImageFile, "Note":userNote, "Date":date, "isDeleted":object["isDeleted"] as Bool]
                        self.parseData.append(dict)
                        
                        userImageFile.getDataInBackgroundWithBlock {(imageData: NSData!, error: NSError!) -> Void in
                            if error == nil {
                                if(imageData == nil){
                                    if var uploadImage = imageData as NSData! {
                                        var image = UIImage(data: uploadImage)
                                        var img: String = "\(uploadImage).png"
                                        self.bgImages.append(img)
                                    }
                                } // Image Data
                            }
                        }
                    }
                   
                    self.tableView.reloadData()
                    
                    JHProgressHUD.sharedHUD.hide()
//                    println("2: \(self.bgImages.count)")

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