 //
//  ItemViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/9/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ItemViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var image = UIImage()
    
    var imageArray = [UIImage]()
    
    var imageCache = [String:UIImage]()
    
    var imageName:String?
    
    
    var imageList = [UIImage]()
    
    var imageNameList = [String]()
    
    var imageIndex: Int = 0
    
    var maxImages: Int = 0
    
    @IBOutlet weak var bookPrice: UILabel!
    
    
    @IBOutlet weak var bookName: UILabel!

    
    @IBOutlet weak var bookDescription: UITextView!
    
    let databaseRef = FIRDatabase.database().referenceFromURL("https://givniteapp.firebaseio.com/")
    let storageRef = FIRStorage.storage().referenceForURL("gs://givniteapp.appspot.com")
    let user = FIRAuth.auth()!.currentUser
    
    
    @IBOutlet weak var pageControl: UIPageControl!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
        self.imageView.image = self.image
        
        
        if imageNameList.count == 0 {
            databaseRef.child("marketplace").child(imageName!).child("images").observeSingleEventOfType(.Value, withBlock: { (snapshot)
                in
            
                let itemDictionary = snapshot.value! as! NSDictionary
                
                let sortKeys = itemDictionary.keysSortedByValueUsingComparator {
                    (obj1: AnyObject!, obj2: AnyObject!) -> NSComparisonResult in
                    let x = obj1 as! NSNumber
                    let y = obj2 as! NSNumber
                    return x.compare(y)
                }
                
                
                for key in sortKeys {
                    self.imageNameList.append("\(key)")
                }
                
                for imagename in self.imageNameList {
                
                    let profilePicRef = self.storageRef.child(self.imageName!).child("\(imagename).jpg")
                    //sets the image on profile
                    profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                        if (error != nil) {
                        print ("File does not exist")
                        return
                        } else {
                            if (data != nil){
                                self.imageList.append(UIImage(data:data!)!)
                            }
                            
                        }
                        self.maxImages  = self.imageList.count - 1
                        self.pageControl.currentPage = 0
                        self.pageControl.numberOfPages = self.maxImages + 1

                    
                    }
                }
            })
        
        }
        
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        
        
        
        databaseRef.child("marketplace").child(imageName!).observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
                // Get item value
                let bookName = snapshot.value!["book name"] as! String
                self.bookName.text = bookName
                let bookDescription = snapshot.value!["description"] as! String
                self.bookDescription.text = bookDescription
                let bookPrice = snapshot.value!["price"] as! String
                self.bookPrice.text = bookPrice
        })
    }

    
    @IBAction func backButton(sender: AnyObject) {
        self.performSegueWithIdentifier("returnBack", sender: self)
    }
    
    
    @IBAction func deleteItem(sender: AnyObject) {
        
        
        let alert = UIAlertController(title: "Delete \"\(bookName.text!)\"", message: "Deleting \"\(bookName.text!)\" will also delete all of its data", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style:.Default, handler: { action in
            for imageName in self.imageNameList{
            
                self.storageRef.child(imageName).deleteWithCompletion { (error) -> Void in
                    if (error != nil) {
                    // Uh-oh, an error occurred!
                    } else {
                        // File deleted successfully
                        print("file deleted")
                    }
                }
            }
            self.databaseRef.child("user").child(self.user!.uid).child("items").child(self.imageName!).removeValue()
            self.databaseRef.child("marketplace").child(self.imageName!).removeValue()
            self.imageArray.removeAtIndex(self.imageArray.indexOf(self.imageCache[self.imageName!]!)!)
            let profileViewController: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("profile")
            self.presentViewController(profileViewController, animated: false, completion: nil)
        }))
    
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
        print("Click of cancel button")
            
            
        }))
        
        
        
        alert.view.tintColor = UIColor(red: 0.984314, green: 0.211765, blue: 0.266667, alpha: 1)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func swiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Right :
                print("User swiped right")
                
                // decrease index first
                
                imageIndex -= 1
                self.pageControl.currentPage -= 1
                
                // check if index is in range
                
                
                if imageIndex < 0 {
                    
                    imageIndex = maxImages
                    self.pageControl.currentPage = maxImages + 1
                    
                }
                                
                imageView.image =  imageList[imageIndex]
                
            case UISwipeGestureRecognizerDirection.Left:
                print("User swiped Left")
                
                // increase index first
                
                imageIndex += 1
                
                 self.pageControl.currentPage += 1
                
                // check if index is in range
                
                
                if imageIndex > maxImages {
                    
                    imageIndex = 0
                    self.pageControl.currentPage = 0
                    
                }
                
                
                
                
                imageView.image = imageList[imageIndex]
                
                
                
                
            default:
                break //stops the code/codes nothing.
                
                
            }
            
        }
        
        
    }
    
    

    
    @IBAction func addPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
        actionSheet.addAction(UIAlertAction(title: "Upload from Photo Library", style:.Default, handler: { action in
    
    
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.delegate = self
            self.presentViewController(picker,animated: true, completion:nil)
    
        }))
    
        actionSheet.addAction(UIAlertAction(title: "Take a photo", style:.Default, handler: { action in
    
    
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.delegate = self
            self.presentViewController(picker,animated: true, completion:nil)
    
    
        }))
    
        actionSheet.addAction(UIAlertAction(title: "Cancel", style:.Cancel, handler: { action in
            print("No photo added")
    
        }))
    
    
        self.presentViewController(actionSheet, animated: true, completion: nil)
    
    }
 
 
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let imageRandomName = NSUUID().UUIDString
        
        var picRef = storageRef.child(imageName!).child("\(imageRandomName).jpg")
        var imageData: NSData = UIImageJPEGRepresentation(image!, 0)!
        let uploadTask = picRef.putData(imageData, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL
                self.databaseRef.child("marketplace").child(self.imageName!).child("images").child(imageRandomName).setValue(FIRServerValue.timestamp())
                self.dismissViewControllerAnimated(true, completion: nil)
                self.imageList.append(image!)
                self.maxImages += 1
                self.pageControl.numberOfPages += 1
                self.viewDidLoad()
            }
        }
    }
 
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "returnBack" {
            let destinationVC = segue.destinationViewController as! ProfileViewController
            
            destinationVC.imageCache = self.imageCache
            destinationVC.imageArray = self.imageArray
            
            self.imageList.removeAll()
            self.imageNameList.removeAll()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
