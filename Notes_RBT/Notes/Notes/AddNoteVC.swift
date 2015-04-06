//
//  AddNoteVC.swift
//  TestDate
//
//  Created by Ankit Mishra on 13/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.
//

import UIKit

extension Array {
    func shuffled() -> [T] {
        var list = self
        for i in 0..<(list.count - 1) {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
}



class AddNoteVC: UIViewController, UIScrollViewAccessibilityDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var currentDate = NSDate()
    var dateTitle: String = ""
    var bgImage: UIImage!
    var rightbarBtn = UIBarButtonItem()
    var questionText = UITextView()
    
    var placeholderArray : [String] = ["What’d you do?","What upset you?","Learn anything?","Buy anything?","Go anywhere?","Looking forward to anything?","Talk to anyone different?","New ideas?","Tell me about this fine day?"]
    var randomBGImages = ["1BG","2BG","3BG","4BG","5BG","6BG","7BG","8BG","9BG","10BG","11BG","12BG","13BG","14BG.png","15BG","16BG","17BG","18BG","19BG","20BG","21BG","22BG","23BG","24BG.png","25BG","26BG","27BG","28BG.png","29BG.png","30BG","31BG","32BG","33BG","34BG","35BG","36BG","37BG","38BG","39BG","40BG","41BG","42BG","44BG","45BG","46BG","47BG","43BG.png"]
  
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var crossButton: UIButton!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(crossButton != nil) {
            crossButton.hidden = true
        }
        
        if(textView != nil){
            self.textView.contentSize = self.textView.bounds.size
            textView.userInteractionEnabled = true
            textView.editable = true
            textView.delegate = self
            
            // Auto-resize textfield
            if !textView.text.isEmpty {
                var textLength = countElements(textView.text)
                
                if textLength > 35 {
                    textView.font = UIFont.boldSystemFontOfSize(20)
                }else{
                    textView.font = UIFont.boldSystemFontOfSize(30)
                }
            }
        }
        
        // Changing textview text color
        changeTextColor()
        
        let dateFormter = NSDateFormatter()
        dateFormter.dateFormat = "MMM dd, yyyy"
        dateTitle = dateFormter.stringFromDate(currentDate as NSDate)
        self.navigationItem.title = dateTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        
        
        // Placeholder text
        placeholderArray = placeholderArray.shuffled()
        var multiLineString = join("\n", placeholderArray)
        if(placeholderLabel != nil){
            placeholderLabel.text = multiLineString
            placeholderLabel.userInteractionEnabled = true
            placeholderLabel.numberOfLines = 0
            placeholderLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            placeholderLabel.textColor = UIColor.grayColor()
            placeholderLabel.sizeToFit()
        
            if(placeholderLabel.hidden == false){
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "showCrossMark:")
                tapGestureRecognizer.numberOfTapsRequired = 1
                placeholderLabel.addGestureRecognizer(tapGestureRecognizer)
            }
        }
        
        rightbarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "saveDataInParse")
        navigationItem.rightBarButtonItems = [rightbarBtn]
        
        // Dismiss Keyboard
        let aSelector : Selector = "touchOutsideTextView"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)

        // Move view when keyboard appears
        registerNotificationOfKeyboard()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.showKeyboard()
        })
    }

    func showKeyboard(){
        self.textView.becomeFirstResponder()
    }
    
    
    internal func checkForInsertUpdateInParse(){
        
        JHProgressHUD.sharedHUD.showInView(UIApplication.sharedApplication().keyWindow!, withHeader: "Saving", andFooter: "")
        
        var query = PFQuery(className: "NotesApp")
        query.whereKey("Date", equalTo: dateTitle)
        query.whereKey("User", equalTo: PFUser.currentUser())
        query.findObjectsInBackgroundWithBlock { (objects:Array!, error:NSError!) -> Void in
            
            if(error == nil){
                if(objects.count > 0){
                    var obj :PFObject! = objects[0] as PFObject
                    var objID = objects[0].objectId
                    if(self.textView.text.isEmpty){
                        obj["Note"] = ""
                    }else{
                        obj["Note"] = self.textView.text
                    }
                    
                    if(self.bgImage != nil){
                        var imageData = UIImagePNGRepresentation(self.bgImage)
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
                    self.saveDataInParse()
                }
            }
            else{
                JHProgressHUD.sharedHUD.hide()
                
                let alert = UIAlertView(title: "Error", message: "Some thing went Wrong", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
    } // End of Method
    
    
    func saveDataInParse(){
        JHProgressHUD.sharedHUD.showInView(UIApplication.sharedApplication().keyWindow!, withHeader: "Saving", andFooter: "")
        
        var imageFile : PFFile!
        var testObject : PFObject = PFObject(className: "NotesApp")
        testObject["User"] = PFUser.currentUser()
        
        if(self.textView.text.isEmpty){
            testObject["Note"] = ""
        }else{
            testObject["Note"] = self.textView.text
        }
        testObject["Date"] = dateTitle
        testObject["isDeleted"] = false
       
        if(bgImage != nil){
            var imageData = UIImagePNGRepresentation(bgImage)
            imageFile = PFFile(name:"Image.png", data:imageData)
            testObject["ImageFileData"] = imageFile
        }else{
            bgImage = getRandomImageFromAssets()
            var imageData = UIImagePNGRepresentation(bgImage)
            imageFile = PFFile(name:"Random Image.png", data:imageData)
            testObject["ImageFileData"] = imageFile
        }
        
        if(bgImage != nil){
            imageFile.saveInBackgroundWithBlock {(success: Bool, error: NSError!) -> Void in
                if (success) {
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
    } // End of method
    
    
    func getRandomImageFromAssets() -> UIImage{
        var randomIndex = Int(arc4random_uniform(UInt32(randomBGImages.count)))
        var noteImage = UIImage(named: "\(randomBGImages[randomIndex])")
        return noteImage!
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func showCrossMark(gesture: UIGestureRecognizer){
        crossButton.hidden = false
    }
    
    
    @IBAction func crossButtonPressed(sender: AnyObject) {
        placeholderLabel.hidden = true
        crossButton.hidden = true
    }
 
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        loadImage()
    }
 
    
    internal func loadImage(){
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
 
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        bgImage = info[UIImagePickerControllerOriginalImage] as UIImage
 
        imageView.image = bgImage
        imageView.alpha = 0.9
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)
        centerImageViewContents()
       
        if(imageView.image == nil){
            textView.textColor = UIColor.blackColor()
            placeholderLabel.textColor = UIColor.blackColor()
            imageView.backgroundColor = UIColor.whiteColor()
        }else{
            textView.textColor = UIColor.whiteColor()
            placeholderLabel.textColor = UIColor.whiteColor()
            imageView.backgroundColor = UIColor.blackColor()
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Centers the imageview image
    func centerImageViewContents() {
        let boundsSize = imageView.bounds.size
        var contentsFrame = imageView.frame
        
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
        
        imageView.frame = contentsFrame
    }
    
    
    func textViewDidBeginEditing(te: UITextView) {
          if(imageView.image == nil){
              textView.textColor = UIColor.blackColor()
          }else{
              textView.textColor = UIColor.whiteColor()
          }
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {

    }
  
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool{
        resizeTextSize()
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    
    func resizeTextSize(){
        var textLength = countElements(textView.text)
        
        if textLength > 35 {
            textView.font = UIFont.boldSystemFontOfSize(20)
        }else{
            textView.font = UIFont.boldSystemFontOfSize(30)
        }
    }
   
   
    func touchOutsideTextView(){
        self.view.endEditing(true)
    }
    
    
    func changeTextColor(){
        if(imageView.image == nil){
            textView.textColor = UIColor.blackColor()
            placeholderLabel.textColor = UIColor.blackColor()
        }else{
            textView.textColor = UIColor.whiteColor()
            placeholderLabel.textColor = UIColor.whiteColor()
        }
    }
    
    
    func registerNotificationOfKeyboard(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func keyboardWillShow(sender: NSNotification) {
        self.cameraButton.frame.origin.y -= 255
        self.placeholderLabel.frame.origin.y -= 255
        self.crossButton.frame.origin.y -= 255
        
        let quesView = UIView(frame: CGRectMake(UIScreen.mainScreen().bounds.width/2-10, self.cameraButton.frame.origin.y+10, 60, 100))
        quesView.tag = 100
        quesView.backgroundColor = UIColor.clearColor()
        
        questionText = UITextView(frame: CGRectMake(0, 50, 60, 100))
        questionText.text = "???"
        questionText.textColor = UIColor.grayColor()
        questionText.textAlignment = NSTextAlignment.Center
        questionText.backgroundColor = UIColor.clearColor()
        questionText.font = UIFont(name: "HelveticaNeue", size: 28)
       
        quesView.addSubview(questionText)
        self.view.addSubview(quesView)
    }
    
    
    func keyboardWillHide(sender: NSNotification) {
        self.cameraButton.frame.origin.y += 255
        self.placeholderLabel.frame.origin.y += 255
        self.crossButton.frame.origin.y += 255
        
        var view  = self.view.viewWithTag(100)
        view?.removeFromSuperview()
    }

    
}
