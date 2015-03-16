//
//  ShowNotesVC.swift
//  TestDate
//
//  Created by Ankit Mishra on 13/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.
//

import UIKit


class ShowNotesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {

    var dateArray = [AnyObject]()
    var parseData = [AnyObject]()
    var index = 0
    var section = 0
    var currentElement = 0
    var navTitle = ""
    var tableData = [NSDate]()
    let dateFormter = NSDateFormatter()
    var rightbarBtn = UIBarButtonItem()
    var noteTextView = UITextView()
    var cellImageView = UIImageView()
    var fromAdd = 0;
    var addNoteObject = AddNoteVC()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var removeButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.hidden = false
        removeButton.hidden = true
        
        tableView.pagingEnabled = true
        tableView.dataSource = self
        tableView.delegate = self

        self.noteTextView.delegate = self
        noteTextView.userInteractionEnabled = true
        noteTextView.editable = false
      
        // Auto-resize textfield
        autoResizeText()
        
        if(!noteTextView.text.isEmpty){
            let tapGestureRecognizer = UITapGestureRecognizer(target: self.noteTextView, action: "showPopupWithText:")
            tapGestureRecognizer.numberOfTapsRequired = 2
            noteTextView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        // Change textview text color
        changeTextColor()
        
        var innerDateArr: Array = (dateArray[section] as NSArray) as Array
        var date: (AnyObject) = innerDateArr[index]
        self.automaticallyAdjustsScrollViewInsets = false;

        dateFormter.dateFormat = "MMM dd, yyyy"
        navTitle = dateFormter.stringFromDate(date as NSDate)
        self.navigationItem.title = navTitle
        
        rightbarBtn = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editClicked")
        navigationItem.rightBarButtonItems = [rightbarBtn]
        
        //Also calculate the index
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

        if(fromAdd == 1) {
            for(var i=0;i<tableData.count;i++){
                
                var d1 = dateFormter.stringFromDate(tableData[i])
                var d2 = dateFormter.stringFromDate(NSDate())
                
                var dateComparisionResult:NSComparisonResult = d2.compare(d1)
                if dateComparisionResult == NSComparisonResult.OrderedSame
                {
                    navTitle = dateFormter.stringFromDate(tableData[i])
                    currentElement  = i
                }
            }
        }
        
        
        let indexPath = NSIndexPath(forRow: currentElement, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        
        // Move camera view when keyboard appears
        moveViewForKeyboard()
        
        let aSelector : Selector = "touchOutsideTextView"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
    }

    
    func touchOutsideTextView(){
         self.view.endEditing(true)
    }
    
    func showPopupWithText() {
        var popUpView = UIView()
        popUpView.frame = CGRectMake(UIScreen.mainScreen().bounds.width/2-100, UIScreen.mainScreen().bounds.height/2-125, 200, 250)
        popUpView.backgroundColor = UIColor.grayColor()

       
        var noteText = UITextView(frame: CGRectMake(popUpView.frame.width/2-90, popUpView.frame.height/2-110, 180, 380))
        noteText.text = noteTextView.text
        noteText.textColor = UIColor.blackColor()
        noteText.textAlignment = NSTextAlignment.Center
        noteText.backgroundColor = UIColor.clearColor()
        
        popUpView.addSubview(noteText)
        self.view.addSubview(popUpView)
    }
    
    
    func editClicked(){
        noteTextView.editable = true
        
        if(self.navigationItem.rightBarButtonItem?.title == "Done"){
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            updateDataInParse()
        }else{
            self.navigationItem.rightBarButtonItem?.title = "Done"
            noteTextView.becomeFirstResponder()
        }
        
        removeButton.hidden = false
        println("Edit clicked")
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool{
        if text == "\n" {
            println("Here")
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    

    
    func updateDataInParse(){
        JHProgressHUD.sharedHUD.showInView(UIApplication.sharedApplication().keyWindow!, withHeader: "Saving", andFooter: "")
        
        println(navTitle)
        
        var query = PFQuery(className: "NotesApp")
        query.whereKey("User", equalTo: PFUser.currentUser())
        query.whereKey("Date", equalTo: navTitle)
        query.findObjectsInBackgroundWithBlock { (objects:Array!, error:NSError!) -> Void in
            
            if(error == nil){
                if(objects.count>0){
                    var obj :PFObject! = objects[0] as PFObject
                    var objID = objects[0].objectId
                    if(self.noteTextView.text.isEmpty){
                        obj["Note"] = ""
                    }
                    else{
                        obj["Note"] = self.noteTextView.text
                    }
                    
                    if(self.cellImageView.image != nil){
                        var imageData = UIImagePNGRepresentation(self.cellImageView.image)
                        var imageFile = PFFile(name:"Image.png", data:imageData)
                        obj["ImageFileData"] = imageFile
                    }
        
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
                else{
                    self.hideHud()
                }
            }
            else{
                self.hideHud()
            }
        }

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ShowDetailsCell") as ShowDetailsCell
        
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
                    
                    let bgimage = dict["Image"] as PFFile
                    bgimage.getDataInBackgroundWithBlock({
                        (imageData: NSData!, error: NSError!) -> Void in
                        if (error == nil && imageData != nil) {
                            let image = UIImage(data:imageData)
                            cell.bgImage.image = image
                            cell.noteLbl.textColor = UIColor.whiteColor()
                        }
                    })
                    break
                }
            }
        }
        
        if isfound{
            cell.noteLbl.text = noteData
        }else{
            cell.noteLbl.text = ""
        }
        
        if(cell.bgImage.image == nil){
            removeButton.setTitle("Camera", forState: UIControlState.Normal)
        }else{
            removeButton.setTitle("Remove", forState: UIControlState.Normal)
        }
        
        cellImageView = cell.bgImage
        noteTextView = cell.noteLbl
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.height - 50
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
    }
    
    
    @IBAction func shareButtonPressed(sender: AnyObject){
       // share(sender)
        
        var noteText = noteTextView
        let myWebsite = NSURL(string: "http.//www.google.com")!
//        var noteImage : UIImage = UIImage()
        var objectToShare = [noteText, myWebsite]
        
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
        
      //  self.presentViewController(activityVC, animated: true, completion: nil)
        
        if respondsToSelector("popoverPresentationController") {
            self.presentViewController(activityVC, animated: true, completion: nil)
            activityVC.popoverPresentationController?.sourceView = sender as UIView
        }else{
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    
  /*  func share(sender: AnyObject) {
        //  if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
        self.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
        //  } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        //        iPad(sender)
        //   }
    }
    
    
    lazy var activityPopover: UIPopoverController = {
        return UIPopoverController(contentViewController: self.activityViewController)
        }()
    
    lazy var activityViewController: UIActivityViewController = {
        return self.createActivityController()
        }()
    
    
    func createActivityController() -> UIActivityViewController {
        var noteText = noteTextView
       
       let myWebsite = NSURL(string: "http.//www.google.com")!
     //   var noteImage = cellImageView.image
        
        var objectToShare = [noteText, myWebsite]
            
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
        
  /*      activityVC.completionHandler = {(activityType, completed:Bool) in
            if !completed{
                println("Cancelled")
            }
            
            if activityType == UIActivityTypePostToTwitter{
                println("twitter")
            }
        }   */
  //      self.presentViewController(activityVC, animated: true, completion: nil)
        return activityViewController
    }
    
    */
    
    @IBAction func removeButtonPressed(sender: AnyObject) {
        if(cellImageView.image == nil){
       //     addNoteObject.loadImage()
            loadImage()
        }else{
            removePhoto()
        }
    }
    
    
    func loadImage()
    {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        var bgImage = info[UIImagePickerControllerOriginalImage] as UIImage
        cellImageView.image = bgImage
        cellImageView.contentMode = UIViewContentMode.Center
        cellImageView.frame = CGRectMake(0, 0, cellImageView.frame.size.width, cellImageView.frame.size.height)
        centerImageViewContents()
        
        if(cellImageView.image == nil){
            noteTextView.textColor = UIColor.blackColor()
        }else{
            noteTextView.textColor = UIColor.whiteColor()
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Centers the imageview image
    func centerImageViewContents()
    {
        let boundsSize = cellImageView.bounds.size
        var contentsFrame = cellImageView.frame
        
        if contentsFrame.size.width < boundsSize.width{
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }else{
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height{
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }else{
            contentsFrame.origin.y = 0
        }
        
        cellImageView.frame = contentsFrame
    }
    

    func removePhoto(){
        let optionMenu: UIAlertController = UIAlertController()
        
        let deleteAction = UIAlertAction(title: "Remove Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("File Deleted")
            // Update in parse
            self.updateDataInParse()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    func hideHud(){
        JHProgressHUD.sharedHUD.hide()
        
        let alert = UIAlertView(title: "Error", message: "Some thing went Wrong", delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
////        self.noteTextView.endEditing(true)
//        println("Here")
//        noteTextView.editable = false
//    }
//    
   
    func keyboardWillShow(sender: NSNotification) {
        self.removeButton.frame.origin.y -= 255
        tableView.scrollEnabled = false
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.removeButton.frame.origin.y += 255
        tableView.scrollEnabled = true
    }

    
    func changeTextColor(){
        if(cellImageView.image == nil){
            if(noteTextView.text == "Write Here ....."){
                noteTextView.textColor = UIColor.lightGrayColor()
            }else{
                noteTextView.textColor = UIColor.blackColor()
            }
        }else{
            if(noteTextView.text == "Write Here ....."){
                noteTextView.textColor = UIColor.lightGrayColor()
            }
            else{
                noteTextView.textColor = UIColor.whiteColor()
            }
        }
    }
    
    
    func autoResizeText(){
        if !noteTextView.text.isEmpty {
            var textLength = countElements(noteTextView.text)
        
            if textLength > 50 {
                noteTextView.font = UIFont.boldSystemFontOfSize(12)
            }else{
                noteTextView.font = UIFont.boldSystemFontOfSize(30)
            }
        }
    }
    
    
    func moveViewForKeyboard(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
}
