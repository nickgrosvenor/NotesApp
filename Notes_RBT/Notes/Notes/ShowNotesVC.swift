//
//  ShowNotesVC.swift
//  TestDate
//
//  Created by Ankit Mishra on 13/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.
//

import UIKit


class ShowNotesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UIActionSheetDelegate {

    // Variables
    var index = 0
    var section = 0
    var currentElement = 0
    var navTitle = ""
    var fromAdd = 0
    var isDeleted = false
    
    // Array
    var dateArray = [AnyObject]()
    var parseData = [AnyObject]()
    var tableData = [NSDate]()
    let dateFormter = NSDateFormatter()
    var rightbarBtn = UIBarButtonItem()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var removeButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        shareButton.hidden = false
        removeButton.hidden = true
        
        tableView.pagingEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        
        // Change textview text color
//        changeTextColor()
        
        var innerDateArr: Array = (dateArray[section] as NSArray) as Array
        var date: (AnyObject) = innerDateArr[index]
        self.automaticallyAdjustsScrollViewInsets = false;
        
        dateFormter.dateFormat = "MMM dd, yyyy"
        navTitle = dateFormter.stringFromDate(date as NSDate)
        self.navigationItem.title = navTitle
        
        rightbarBtn = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editClicked")
        navigationItem.rightBarButtonItems = [rightbarBtn]
        
        
        //calculating the index to Open Current Row
        for(var i=0;i<=section;i++){
            var innerArr: Array = (dateArray[i] as NSArray) as Array
            if(i == section){
                currentElement = currentElement + index
            }else{
                currentElement = currentElement + innerArr.count
            }
        }
        
        // Store data in an array
        for(var i=0;i<dateArray.count;i++){
            var innerArr: Array = (dateArray[i] as NSArray) as Array
            for(var j=0;j<innerArr.count;j++){
                tableData.append(innerArr[j] as NSDate)
            }
        }
        
        //
        if(fromAdd == 1) {
            for(var i=0;i<tableData.count;i++){
                
                var d1 = dateFormter.stringFromDate(tableData[i])
                var d2 = dateFormter.stringFromDate(NSDate())
                
                var dateComparisionResult:NSComparisonResult = d2.compare(d1)
                if dateComparisionResult == NSComparisonResult.OrderedSame {
                    navTitle = dateFormter.stringFromDate(tableData[i])
                    currentElement  = i
                    break
                }
            }
        }
        
        let indexPath = NSIndexPath(forRow: currentElement, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        
        // Dismiss Keyboard
        let aSelector : Selector = "touchOutsideTextView"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Move view when keyboard appears
        registerNotificationOfKeyboard()
   }
    
    
    override func viewDidAppear(animated: Bool) {
        var checkBool = checkDataContains()
        
        if(!checkBool){
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                // your function here
                self.editClicked()
            })
        }
    }
    
    
    func checkDataContains()->Bool{
        let date = tableData[currentElement] as NSDate
        let userCalendar = NSCalendar.currentCalendar()
        var dateComp = userCalendar.components(.CalendarUnitDay | .CalendarUnitWeekday, fromDate: date)
        var day = dateComp.day
        var weekDay = dateComp.weekday
        
        
        var title = dateFormter.stringFromDate(date)
        self.navigationItem.title = title
        
        var isfound = false
        var noteData = ""
        if(parseData.count>0)
        {
            for (var i=0;i<parseData.count;i++) {
                var dict: (AnyObject) = parseData[i]
                
                if ( dict["Date"] as String == title ){
                    isfound = true
                    noteData = dict["Note"] as String
                    
                    let bgimage = dict["Image"] as PFFile
                    return true
                }
            }
        }
        return false
    }
    
   
    func showPopupWithText() {
        var indexPaths = self.tableView.indexPathsForVisibleRows() as [NSIndexPath]
        var cell = self.tableView.cellForRowAtIndexPath(indexPaths[0]) as ShowDetailsCell
        
        tableView.scrollEnabled = false
        
        var height =  self.navigationController?.navigationBar.frame.size.height
        
        let popUpView = UIView(frame: CGRectMake(30, height! + 50, UIScreen.mainScreen().bounds.width - 60, UIScreen.mainScreen().bounds.height - height! - 80))
        popUpView.tag = 1000
        popUpView.backgroundColor = UIColor.whiteColor()
        
        var noteText = UITextView(frame: CGRectMake(0, 50, CGRectGetWidth(popUpView.frame), CGRectGetHeight(popUpView.frame)))
        noteText.text = cell.noteLbl.text
        noteText.textColor = UIColor.blackColor()
        noteText.textAlignment = NSTextAlignment.Center
        noteText.backgroundColor = UIColor.clearColor()
        noteText.editable = false
        noteText.scrollEnabled = true
        noteText.font = UIFont(name: "HelveticaNeue-Light", size: 19)
        
        let crossImage = UIImage(named: "Cross") as UIImage?
        let closeButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        closeButton.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 100, 0, 40, 40)
        closeButton.backgroundColor = UIColor.clearColor()
        closeButton.setBackgroundImage(crossImage, forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "closeButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        popUpView.addSubview(noteText)
        popUpView.addSubview(closeButton)
        self.view.addSubview(popUpView)
    }
    
        
    func closeButtonAction(sender:UIButton!) {
        var view  = self.view.viewWithTag(1000)
        view?.removeFromSuperview()
        tableView.scrollEnabled = true
    }
    
    
    func editClicked(){
        var indexPaths = self.tableView.indexPathsForVisibleRows() as [NSIndexPath]
        var cell = self.tableView.cellForRowAtIndexPath(indexPaths[0]) as ShowDetailsCell
        
        shareButton.hidden = true
        removeButton.hidden = false
        
        if(self.navigationItem.rightBarButtonItem?.title == "Done"){
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            touchOutsideTextView()
            updateDataInParse()
        }else{
            self.navigationItem.rightBarButtonItem?.title = "Done"
            cell.noteLbl.editable = true
            cell.noteLbl.becomeFirstResponder()
        }
    }
    
    
    func updateDataInParse(){
        var indexPaths = self.tableView.indexPathsForVisibleRows() as [NSIndexPath]
        var cell = self.tableView.cellForRowAtIndexPath(indexPaths[0]) as ShowDetailsCell
        
        JHProgressHUD.sharedHUD.showInView(UIApplication.sharedApplication().keyWindow!, withHeader: "Saving", andFooter: "")
        
        var query = PFQuery(className: "NotesApp")
        query.whereKey("User", equalTo: PFUser.currentUser())
        query.whereKey("Date", equalTo: navTitle)
        query.findObjectsInBackgroundWithBlock { (objects:Array!, error:NSError!) -> Void in
            
            if(error == nil){
                if(objects.count>0){
                    var obj :PFObject! = objects[0] as PFObject
                    var objID = objects[0].objectId
                    obj["isDeleted"] = self.isDeleted
                    
                    if(cell.noteLbl.text.isEmpty){
                        obj["Note"] = ""
                    }
                    else{
                        obj["Note"] = cell.noteLbl.text
                    }
                    
                    if(cell.bgImage.image != nil){
                        var imageData = UIImagePNGRepresentation(cell.bgImage.image)
                        var imageFile = PFFile(name:"Image.png", data:imageData)
                        obj["ImageFileData"] = imageFile
                        
                        imageFile.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError!) -> Void in
                            if (success) {
                                
                                obj.saveInBackgroundWithBlock {
                                    (success: Bool, error: NSError!) -> Void in
                                    if (success) {
                                        JHProgressHUD.sharedHUD.hide()
                                        self.navigationController?.popViewControllerAnimated(true)
                                    } else {
                                        JHProgressHUD.sharedHUD.hide()
                                        let alert = UIAlertView(title: "Error", message:String(format: "%@", error.userInfo!) , delegate: nil, cancelButtonTitle: "Ok")
                                        alert.show()
                                    }
                                }
                            } else {
                                JHProgressHUD.sharedHUD.hide()
                                let alert = UIAlertView(title: "Error", message:String(format: "%@", error.userInfo!) , delegate: nil, cancelButtonTitle: "Ok")
                                alert.show()
                            }
                        }
                    }
                    else{
                        
                        obj.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError!) -> Void in
                            if (success) {
                                JHProgressHUD.sharedHUD.hide()
                                self.navigationController?.popViewControllerAnimated(true)
                            } else {
                                JHProgressHUD.sharedHUD.hide()
                                let alert = UIAlertView(title: "Error", message:String(format: "%@", error.userInfo!) , delegate: nil, cancelButtonTitle: "Ok")
                                alert.show()
                            }
                        }
                        
                    }
                }
                else{
                    self.saveDataInParse()
                }
            }
            else{
                self.hideHud()
            }
        }
        
    }
    
    
    func saveDataInParse(){
        var indexPaths = self.tableView.indexPathsForVisibleRows() as [NSIndexPath]
        var cell = self.tableView.cellForRowAtIndexPath(indexPaths[0]) as ShowDetailsCell
        
        var imageFile : PFFile!
        var testObject : PFObject = PFObject(className: "NotesApp")
        testObject["User"] = PFUser.currentUser()
        if(cell.noteLbl.text.isEmpty){
            testObject["Note"] = ""
        }else{
            if(cell.noteLbl.text == ""){
                testObject["Note"] = ""
            }
            else{
                testObject["Note"] = cell.noteLbl.text
            }
        }
        testObject["Date"] = navTitle
        testObject["isDeleted"] = self.isDeleted
        
        if(cell.bgImage.image != nil){
            var imageData = UIImagePNGRepresentation(cell.bgImage.image)
            var imageFile = PFFile(name:"Image.png", data:imageData)
            testObject["ImageFileData"] = imageFile
            
            imageFile.saveInBackgroundWithBlock {
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    
                    testObject.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError!) -> Void in
                        if (success) {
                            JHProgressHUD.sharedHUD.hide()
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            JHProgressHUD.sharedHUD.hide()
                            let alert = UIAlertView(title: "Error", message:String(format: "%@", error.userInfo!) , delegate: nil, cancelButtonTitle: "Ok")
                            alert.show()
                        }
                        
                    }
                } else {
                    JHProgressHUD.sharedHUD.hide()
                    let alert = UIAlertView(title: "Error", message:String(format: "%@", error.userInfo!) , delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                }
             }
         }
        else{
            testObject.saveInBackgroundWithBlock {(success: Bool, error: NSError!) -> Void in
                if (success) {
                    JHProgressHUD.sharedHUD.hide()
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    JHProgressHUD.sharedHUD.hide()
                    let alert = UIAlertView(title: "Error", message:String(format: "%@", error.userInfo!) , delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ShowDetailsCell") as ShowDetailsCell
        isDeleted = false
        cell.noteLbl.delegate = self
        cell.noteLbl.userInteractionEnabled = true
        let date = tableData[indexPath.row] as NSDate
        let userCalendar = NSCalendar.currentCalendar()
        var dateComp = userCalendar.components(.CalendarUnitDay | .CalendarUnitWeekday, fromDate: date)
        var day = dateComp.day
        var weekDay = dateComp.weekday
        
        var title = dateFormter.stringFromDate(date)
        self.navigationItem.title = title
        
        var isfound = false
        var noteData = ""
        if(parseData.count>0)
        {
            for (var i=0;i<parseData.count;i++) {
                var dict: (AnyObject) = parseData[i]
                
                if ( dict["Date"] as String == title ){
                    isfound = true
                    noteData = dict["Note"] as String
                    self.isDeleted = dict["isDeleted"] as Bool
                    if(dict["isDeleted"] as Bool == false){
                    let bgimage = dict["Image"] as PFFile
                        
                    bgimage.getDataInBackgroundWithBlock({(imageData: NSData!, error: NSError!) -> Void in
                        if (error == nil) {
                            if(imageData != nil){
                                let image = UIImage(data:imageData)
                                cell.bgImage.image = image
                                
                                self.changeTextColor(cell)
                                self.autoResizeText(cell)
                                
                                if(cell.bgImage.image != nil){
                                    cell.bgImage.alpha = 0.95
                                    self.removeButton.setBackgroundImage(cell.bgImage.image, forState: UIControlState.Normal)
                                    cell.bgImage.backgroundColor = UIColor.blackColor()
                                    cell.noteLbl.textColor = UIColor.whiteColor()
                                }else{
                                    self.removeButton.setBackgroundImage(UIImage(named:"Camera Icon"), forState: UIControlState.Normal)
                                    cell.bgImage.backgroundColor = UIColor.whiteColor()
                                    cell.noteLbl.textColor = UIColor.blackColor()
                                }
                            }
                            else{
//                                cell.bgImage.backgroundColor = UIColor.blackColor()
//                                cell.bgImage.image = self.getRandomImageFromAssets()
//                                cell.noteLbl.textColor = UIColor.whiteColor()
                            }
                        }
                    })
                    break
                    }
                }
                else{
                    cell.bgImage.backgroundColor = UIColor.whiteColor()
                }
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "showNavigationBar")
        tapGesture.numberOfTapsRequired = 1
        cell.addGestureRecognizer(tapGesture)

        
        cell.bgImage.image = nil
        
        if isfound{
            cell.noteLbl.text = noteData
            cell.noteLbl.textColor = UIColor.blackColor()
        }else{
            cell.noteLbl.text = ""
        }

//            var numLines = cell.noteLbl.contentSize.height / cell.noteLbl.font.lineHeight
//            println("Count lines: \(numLines)")
    
        
        if cell.noteLbl.text != "" {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "showPopupWithText")
            tapGestureRecognizer.numberOfTapsRequired = 2
            cell.noteLbl.addGestureRecognizer(tapGestureRecognizer)
        }
        
        self.removeButton.setBackgroundImage(UIImage(named:"Camera Icon"), forState: UIControlState.Normal)
        
        autoResizeText(cell)
        
        return cell
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool{
        var cell = tableView.dequeueReusableCellWithIdentifier("ShowDetailsCell") as ShowDetailsCell
        autoResizeText(cell)
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func showNavigationBar(){
       navigationController?.navigationBarHidden = false
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        navigationController?.navigationBarHidden = true
    }

    
    func autoResizeText(cell:ShowDetailsCell){
        cell.noteLbl.textAlignment = NSTextAlignment.Center
        var textLength = countElements(cell.noteLbl.text)
        
        if textLength > 35 {
            cell.noteLbl.font = UIFont.boldSystemFontOfSize(20)
        }else{
            cell.noteLbl.font = UIFont.boldSystemFontOfSize(30)
        }
    }
    
    
    func textViewDidChange(textView: UITextView) {
        var textLength = countElements(textView.text)

        if textLength > 35 {
            textView.font = UIFont.boldSystemFontOfSize(20)
        }else{
            textView.font = UIFont.boldSystemFontOfSize(30)
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.height - 50
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) { }
    
    
    @IBAction func shareButtonPressed(sender: AnyObject){
        var indexPaths = self.tableView.indexPathsForVisibleRows() as [NSIndexPath]
        var cell = self.tableView.cellForRowAtIndexPath(indexPaths[0]) as ShowDetailsCell
        
        var noteText = cell.noteLbl.text
        let myWebsite = NSURL(string: "http.//www.google.com")!
        var userAddedImage = cell.bgImage.image!
        var objectToShare = [noteText, userAddedImage]
        
        let activityVC: UIActivityViewController = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [
            UIActivityTypeMessage,
            UIActivityTypeMail,
            UIActivityTypePostToTwitter,
            UIActivityTypePostToFacebook,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAssignToContact,
            UIActivityTypeCopyToPasteboard,
            UIActivityTypePrint
        ]
        
        if respondsToSelector("popoverPresentationController") {
            self.presentViewController(activityVC, animated: true, completion: nil)
            activityVC.popoverPresentationController?.sourceView = sender as UIView
        }else{
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func removeButtonPressed(sender: AnyObject) {
        var indexPaths = self.tableView.indexPathsForVisibleRows() as [NSIndexPath]
        var cell = self.tableView.cellForRowAtIndexPath(indexPaths[0]) as ShowDetailsCell
        
        if(cell.bgImage.image == nil){
            loadImage()
        }else{
            removePhoto()
        }
    }
    
    // MARK : Open Image Picker View
    func loadImage()
    {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK : Picker View Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        var bgImage = info[UIImagePickerControllerOriginalImage] as UIImage
        
        var indexPaths = self.tableView.indexPathsForVisibleRows() as [NSIndexPath]
        var cell = self.tableView.cellForRowAtIndexPath(indexPaths[0]) as ShowDetailsCell
        cell.noteLbl.textColor = UIColor.blackColor()
        cell.bgImage.image = bgImage
        cell.bgImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.isDeleted = false
        
        if(cell.bgImage.image == nil){
            cell.noteLbl.textColor = UIColor.blackColor()
            cell.bgImage.backgroundColor = UIColor.whiteColor()
            
        }else{
            cell.bgImage.alpha = 0.95
            cell.noteLbl.textColor = UIColor.whiteColor()
            cell.bgImage.backgroundColor = UIColor.blackColor()
        }
        
        self.removeButton.setBackgroundImage(cell.bgImage.image, forState: UIControlState.Normal)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func removePhoto(){
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle:"Cancel", destructiveButtonTitle: "Remove Photo")
        actionSheet.showInView(self.view)
    }
    
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int)
    {
        switch buttonIndex{
            case 0:
                removePhotoFromTable()
                break;
            default:
                NSLog("Default");
                break;
                //Some code here..
        }
    }
    
    
    func removePhotoFromTable(){
        self.isDeleted = true
        
        var indexPaths = self.tableView.indexPathsForVisibleRows() as [NSIndexPath]
        var cell = self.tableView.cellForRowAtIndexPath(indexPaths[0]) as ShowDetailsCell
        cell.noteLbl.textColor = UIColor.blackColor()
        cell.bgImage.image = nil
        cell.bgImage.backgroundColor = UIColor.whiteColor()
        
        self.removeButton.setBackgroundImage(UIImage(named:"Camera Icon"), forState: UIControlState.Normal)
        self.touchOutsideTextView()
    }
    
    
    func hideHud(){
        JHProgressHUD.sharedHUD.hide()
        
        let alert = UIAlertView(title: "Error", message: "Some thing went Wrong", delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    
    func registerNotificationOfKeyboard(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
   
    func keyboardWillShow(sender: NSNotification) {
       self.removeButton.frame.origin.y -= 255
       tableView.scrollEnabled = false
    }
    
    
    func keyboardWillHide(sender: NSNotification) {
        self.removeButton.frame.origin.y += 255
        tableView.scrollEnabled = true
        
        if(self.navigationItem.rightBarButtonItem?.title == "Done"){
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }else{
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
        
    }
    
    
    func changeTextColor(cell: ShowDetailsCell){
        if(cell.bgImage.image == nil){
            cell.noteLbl.textColor = UIColor.blackColor()
        }else{
            cell.noteLbl.textColor = UIColor.whiteColor()
        }
    }
   
    
    func touchOutsideTextView(){
        self.view.endEditing(true)
    }
    
    
    
}