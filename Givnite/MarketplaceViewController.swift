//
//  MarketplaceViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/16/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class MarketplaceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {


    @IBOutlet weak var collectionView: UICollectionView!
    
  

    let storageRef = FIRStorage.storage().referenceForURL("gs://givniteapp.appspot.com")
    let dataRef = FIRDatabase.database().referenceFromURL("https://givniteapp.firebaseio.com/")
    
    var imageNameArray = [String]()
    var imageArray = [UIImage]()
    
    var bookNameArray = [String]()
    var bookPriceArray = [String]()
    var userArray = [String]()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImages()
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        
        
    }
    
    
    func swiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
        
                
            case UISwipeGestureRecognizerDirection.Left:
                print("User swiped Left")
                
                
            let profileViewController: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("profile")
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.addAnimation(transition, forKey: kCATransition)
            self.presentViewController(profileViewController, animated: false, completion: nil)
                
                
            default:
                break //stops the code/codes nothing.
                
                
            }
            
        }
    
    }
    
    
    

    
    
    
    
    //layout for cell size
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 2 ) / 2, height: (collectionView.frame.size.width + 100) / 2  )
    }


    
    func loadImages() {
        dataRef.child("marketplace").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
            
            //adds image name from firebase database to an array
            
            if let itemDictionary = snapshot.value! as? NSDictionary {
                
                
                var timeArray = [Int]()
                
               
                for key in itemDictionary.allKeys {
                    if let keyDictionary = itemDictionary["\(key)"] as? NSDictionary {
                        if let time = keyDictionary["time"] {
                            let time2 = time as! Int
                            timeArray.append(time2)
                        }
                    }
                }
                
                
                timeArray = timeArray.sort().reverse()
                
                
                for time in timeArray {
                    for key in itemDictionary.allKeys {
                        if let keyDictionary = itemDictionary["\(key)"] as? NSDictionary {
                            if let time2 = keyDictionary["time"]{
                                if time == time2 as! Int {
                                    self.imageNameArray.append("\(key)")
                                    if let bookName = keyDictionary["book name"] as? String {
                                        self.bookNameArray.append(bookName)
                                    }
                                    if let bookPrice = keyDictionary["price"] as? String {
                                        self.bookPriceArray.append(bookPrice)
                                    }
                                    if let userID = keyDictionary["user"] as? String {
                                        self.userArray.append(userID)
                                    }

                                }
                            

                            }
                        }
                            
                    }
                }
                
           
                
                for index in 0..<self.imageNameArray.count {
                    self.imageArray.append(UIImage(named: "Examples")!)
                    self.bookNameArray.append("")
                    self.bookPriceArray.append("")
                    
                }
        
                
            
        
                
            
                dispatch_async(dispatch_get_main_queue(),{
                    self.collectionView.reloadData()
                })
            }
        })
        
    }

    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageNameArray.count
    }
    
    
    
    var imageCache = [String:UIImage] ()
    
    var userImageCache = [String:UIImage] ()
    
    var priceCache = [String:String]()
    
    var bookCache = [String:String]()
    
    

    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as!
        MarketCollectionViewCell
        
        
        if let imageName = self.imageNameArray[indexPath.row] as? String {
            cell.itemImageView.image = nil
            
            
            if let image = imageCache[imageName]  {
                cell.itemImageView.image = image
                
            }
                
            else {
                
                var imagesRef = storageRef.child(imageName).child("\(imageName).jpg")
                //sets the image on profile
                imagesRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        print ("File does not exist")
                        return
                    } else {
                        if (data != nil){
                            let imageToCache = UIImage(data:data!)
                            self.imageCache[imageName] = imageToCache
                            dispatch_async(dispatch_get_main_queue(),{
                                cell.itemImageView.image = imageToCache
                                self.imageArray[indexPath.row] = imageToCache!
                                    
                            })
                        }
                    }
                }.resume()
 
            }
 
        
            
            if let userImage = userImageCache[imageName] {
                cell.profilePicView.image = userImage
            }

            else {
                
                let userID = userArray[indexPath.row]
                var profilePicRef = storageRef.child(userID).child("profile_pic.jpg")
                
               
                //sets the image on profile
                profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        print ("File does not exist")
                        
                        return
                    } else {
                        if (data != nil){
                            let imageToCache = UIImage(data:data!)
                            self.userImageCache[imageName] = imageToCache
                            dispatch_async(dispatch_get_main_queue(),{
                                cell.profilePicView.image = imageToCache
                            })
                        }
                    }
                }.resume()
            }
 
 

            
            if let bookName = bookCache[imageName] {
                cell.bookName.text = bookName
            
            }
            
            
            else {
                let bookNameToCache = bookNameArray[indexPath.row]
                self.bookCache[imageName] = bookNameToCache
                 cell.bookName.text = bookNameToCache
            }
            
            if let bookPrice = priceCache[imageName] {
                cell.bookPrice.text = bookPrice
            }
            
            else {
                let bookPriceToCache = bookPriceArray[indexPath.row]
                self.priceCache[imageName] = bookPriceToCache
                cell.bookPrice.text = bookPriceToCache
                
            }
 
        }
        return cell
    }
    
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("marketEnlarge", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "marketEnlarge" {
            
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath
            let destinationVC = segue.destinationViewController as! MarketItemViewController
            
            
    
            destinationVC.image = self.imageArray[indexPath.row]
            
            destinationVC.imageName = self.imageNameArray[indexPath.row]
            
            destinationVC.name = self.bookNameArray[indexPath.row]
            
            destinationVC.price = self.bookPriceArray[indexPath.row]
            
            destinationVC.userID = self.userArray[indexPath.row]
        }
    }

}
