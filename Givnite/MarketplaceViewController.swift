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
                
                
                timeArray.sort()
                
                for time in timeArray {
                    for key in itemDictionary.allKeys {
                        if let keyDictionary = itemDictionary["\(key)"] as? NSDictionary {
                            if let time2 = keyDictionary["time"]{
                                if time == time2 as! Int {
                                    self.imageNameArray.append("\(key)")
                                }
                            }
                        }

                    }
                }
                
                for index in 0..<self.imageNameArray.count {
                    self.imageArray.append(UIImage(named: "Examples")!)
                }
        
                
                print(self.imageNameArray)
        
                
            
                dispatch_async(dispatch_get_main_queue(),{
                    self.collectionView.reloadData()
                })
            }
        })
        
    }

    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.imageNameArray)
        return self.imageNameArray.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as!
        MarketCollectionViewCell
        
        
        if let imageName = self.imageNameArray[indexPath.row] as? String {
            
                
            var profilePicRef = storageRef.child(imageName).child("\(imageName).jpg")
            //sets the image on profile
            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    print ("File does not exist")
                    return
                } else {
                    if (data != nil){
                        let imageStored = UIImage(data:data!)
                        dispatch_async(dispatch_get_main_queue(),{
                            self.imageArray[indexPath.row] = imageStored!
                            cell.itemImageView.image = imageStored
                                
                        })
                    }
                }
            }.resume()
        }
        return cell
    }
    
}
