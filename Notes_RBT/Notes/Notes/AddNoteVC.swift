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
    
    var dateTitle: String = ""
    var bgImage: UIImage!
    var rightbarBtn = UIBarButtonItem()
    var placeholderArray : [String] = ["What’d you do?","What upset you?","Learn anything?","Buy anything?","Go anywhere?","Looking forward to anything?","Talk to anyone different?","New ideas?","Tell me about this fine day?"]
     var bgImages = ["1BG.png","2BG.png","3BG.png","4BG.png","5BG.png","6BG.png","7BG.png","8BG.png","9BG.png","10BG.png","11BG.png","12BG.png","13BG.png","14BG.png","15BG.png","16BG.png","17BG.png","18BG.png","19BG.png","20BG.png","21BG.png","22BG.png","23BG.png","24BG.png","25BG.png","26BG.png","27BG.png","28BG.png","29BG.png","30BG.png","31BG.png","32BG.png","33BG.png","34BG.png","35BG.png","36BG.png","37BG.png","38BG.png","39BG.png","40BG.png","41BG.png","42BG.png","44BG.png","45BG.png","46BG.png","47BG.png"] //"43BG.png",
    
    @IBOutlet weak var backViewOfTV: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var crossButton: UIButton!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var bgView: UIView!
    
    
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
        
        var date = NSDate()
        let dateFormter = NSDateFormatter()
        dateFormter.dateFormat = "MMM dd, yyyy"
        dateTitle = dateFormter.stringFromDate(date as NSDate)
        self.navigationItem.title = dateTitle
        
        
        // Placeholder text
        placeholderArray = placeholderArray.shuffled()
        var multiLineString = join("\n", placeholderArray)
        if(placeholderLabel != nil){
            placeholderLabel.text = multiLineString
            placeholderLabel.userInteractionEnabled = true
            placeholderLabel.numberOfLines = 0
            placeholderLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
       //     placeholderLabel.font = UIFont(name: "HelveticaNeue-Light", size: 9)
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
    }
    
    
    func touchOutsideTextView(){
        self.view.endEditing(true)
    }

    
    func changeTextColor(){
        if(imageView.image == nil){
            if(textView.text == "Write Here ....."){
                textView.textColor = UIColor.lightGrayColor()
            }else{
                textView.textColor = UIColor.blackColor()
                placeholderLabel.textColor = UIColor.blackColor()
            }
                    println("When nil: \(imageView.image)")
        }else{
            if(textView.text == "Write Here ....."){
                textView.textColor = UIColor.lightGrayColor()
            }else{
                textView.textColor = UIColor.whiteColor()
                placeholderLabel.textColor = UIColor.whiteColor()
            }
           
            println("With image: \(imageView.image)")
        }
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
                    }else{
                        self.bgImage = self.getRandomImageFromAssets()
                        var imageData = UIImagePNGRepresentation(self.bgImage)
                        var imageFile = PFFile(name:"Random Image.png", data:imageData)
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
        
        if(bgImage != nil){
            var imageData = UIImagePNGRepresentation(bgImage)
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
            
        }
    }
    
 
    func getRandomImageFromAssets() -> UIImage{
        var randomIndex = Int(arc4random_uniform(UInt32(bgImages.count)))
        var noteImage = UIImage(named: "\(bgImages[randomIndex])")
        return noteImage!
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        imageView.alpha = 0.75
        imageView.contentMode = UIViewContentMode.ScaleToFill
        imageView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)
        centerImageViewContents()
       
        if(imageView.image == nil){
            textView.textColor = UIColor.blackColor()
            placeholderLabel.textColor = UIColor.blackColor()
            bgView.backgroundColor = UIColor.whiteColor()
        }else{
            textView.textColor = UIColor.whiteColor()
            placeholderLabel.textColor = UIColor.whiteColor()
            bgView.backgroundColor = UIColor.blackColor()
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Centers the imageview image
    func centerImageViewContents()
    {
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
        if textView.text == "Write Here ....." {
            textView.text = nil
            if(imageView.image == nil){
                textView.textColor = UIColor.blackColor()
            }else{
                textView.textColor = UIColor.whiteColor()
            }
        }
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write Here ....."
            textView.textColor = UIColor.lightGrayColor()
        }
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
    
    
    
    
    /*    @IBAction func doneButtonPressed(sender: UIBarButtonItem){
    // TODO : Place a Progress Hud here
    
    JHProgressHUD.sharedHUD.showInView(self.view, withHeader: "Loading", andFooter: "Please Wait")
    //       JHProgressHUD.sharedHUD.showInView(self.view)
    
    var imageFile : PFFile!
    var testObject : PFObject = PFObject(className: "NotesApp")
    testObject["User"] = PFUser.currentUser()
    testObject["Note"] = textView.text
    testObject["Date"] = dateTitle
    
    if(bgImage != nil){
    var imageData = UIImagePNGRepresentation(bgImage)
    var imageFile = PFFile(name:"Image.png", data:imageData)
    testObject["ImageFileData"] = imageFile
    }
    
    testObject.saveInBackgroundWithBlock {
    (success: Bool, error: NSError!) -> Void in
    if (success) {
    println("Success")
    self.navigationController?.popViewControllerAnimated(true)
    } else {
    println(error.userInfo)
    self.navigationController?.popViewControllerAnimated(true)
    }
    }
    }
    */
    
    
}
