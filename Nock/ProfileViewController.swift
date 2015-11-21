//
//  ProfileViewController.swift
//  Nock
//
//  Created by Albin Martinsson on 2015-10-05.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Alamofire

class ProfileViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companyLocation: UILabel!
    @IBOutlet weak var companyDescription: UILabel!
    @IBOutlet weak var employeeCollectionView: UICollectionView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet var headerLabel:UILabel!
    @IBOutlet var headerImageView:UIImageView!
    @IBOutlet var headerBlurImageView:UIImageView!
    @IBOutlet weak var companyImageSmall: UIImageView!
    var blurredHeaderImageView:UIImageView?
    @IBOutlet weak var editButtonSmall: NockButtonWhite!
    @IBOutlet weak var companyNameSmall: UILabel!
    var employees = [Employee]()
    let offset_HeaderStop:CGFloat = 90.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 110.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label
    let nockPurple = UIColor(red:0.44, green:0.00, blue:1.00, alpha:1.0)
    
    override func viewWillAppear(animated: Bool) {
        headerImageView = UIImageView(frame: header.bounds)
        //headerImageView?.image = UIImage(named: "company-logo")
        headerImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        header.insertSubview(headerImageView, belowSubview: headerLabel)
        header.insertSubview(headerImageView, belowSubview: editButtonSmall)
        
        // Header - Blurred Image
        
        headerBlurImageView = UIImageView(frame: header.bounds)
        //headerBlurImageView?.image = UIImage(named: "company-logo")?.blurredImageWithRadius(10, iterations: 20, tintColor: UIColor.clearColor())
        headerBlurImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        headerBlurImageView?.alpha = 0.0
        header.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        header.insertSubview(headerBlurImageView, belowSubview: editButtonSmall)
        header.clipsToBounds = true
        
        fetchDescription()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.backgroundColor = nockPurple.CGColor
        scrollView.delegate = self
        companyImage.layer.cornerRadius = 2
        companyImage.layer.masksToBounds = true
        
        //scrollView.alwaysBounceVertical = true
        fetchCompany()
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchCompany", name: "updateData", object: nil)
    }
    
    @IBAction func editButtonAction(sender: AnyObject) {
        presentOptionSheet()
    }
    
    func fetchDescription() {
        let realm = try! Realm()
        let user = realm.objects(User)[0]
        print(user)
        let headers = ["X-Authentication-Token": user.token]
        Alamofire.request(.GET, "http://nockapp.se/api/v1/company/\(user.companyId)", headers: headers)
            .responseData { (request, response, data) in
                if response?.statusCode == 200 {
                    let json = JSON(data: data.value!)
                    print(json)
                    self.companyDescription.text = json["data"]["description"].description
                    
                    /*Alamofire.request(.GET, json["data"]["company_imageURL"].description).response { (request, response, data, error) in
                    return print(data!)
                    self.companyImageSmall.image = UIImage(data: data!, scale:1)
                    }*/
                } else {
                    print("Error fetching data")
                    print(response?.statusCode)
                }
        }
    }

    func leaveCompany() {
        let realm = try! Realm()
        let user = realm.objects(User)[0]
        let headers = ["X-Authentication-Token": user.token]
        Alamofire.request(.PUT, "http://nockapp.se/api/v1/company/\(user.companyId)/leave", headers: headers)
            .responseData { (request, response, result) in
                if response?.statusCode == 200 {
                    print("STATUS = 200")
                    self.logout()
                    
                } else {
                    print("Error")
                    print(response)
                    print(result)
                }
        }
    }
    
    func fetchCompany() {
        print("fetch company")
        let realm = try! Realm()
        let user = realm.objects(User)[0]
        let headers = ["X-Authentication-Token": user.token]
        print(user)
        Alamofire.request(.GET, "http://nockapp.se/api/v1/company/\(user.companyId)", headers: headers)
            .responseData { (request, response, data) in
                if response?.statusCode == 200 {
                    self.employees.removeAll()
                    let json = JSON(data: data.value!)
                    print(json)
                    self.companyName.text = json["data"]["name"].description
                    self.companyDescription.text = json["data"]["description"].description
                    self.headerLabel.text = json["data"]["name"].description
                    
                    //TODO: LÄgg till från API, hårdkodat
                    self.companyLocation.text = "Science Park Halmstad"
                    Alamofire.request(.GET, json["data"]["company_imageURL"].description).response { (request, response, data, error) in
                        //return print(data!)
                        //self.companyImageSmall.image = UIImage(data: data!, scale:1)
                    }
                    Alamofire.request(.GET, json["data"]["company_imageURL"].description).response { (request, response, data, error) in
                        self.companyImage.image = UIImage(data: data!, scale:1)
                    }
                    Alamofire.request(.GET, json["data"]["company_backdropURL"].description).response { (request, response, data, error) in
                        self.headerImageView?.image = UIImage(data: data!, scale:1)
                        self.headerBlurImageView?.image = UIImage(data: data!, scale:1)?.blurredImageWithRadius(10, iterations: 20, tintColor: UIColor.clearColor())
                    }
                    
                    for employee in json["data"]["users"] {
                        let tempEmployee = Employee(profileImageURL: employee.1["profile_image"].description)
                        self.employees.append(tempEmployee)
                        //self.employeeCollectionView.insertItemsAtIndexPaths([insertIndexPath])
                        self.employeeCollectionView.reloadData()
                    }
                } else {
                    print("Error fetching data")
                    print(response?.statusCode)
                    let json = JSON(data: data.value!)
                    print(json)
                }
        }
    }
    
    func logout() {
        let realm = try! Realm()
        let user = realm.objects(User)[0]
        removeDeviceToken(user)
        do {
            let realm = try Realm()
            try realm.write() {
                realm.deleteAll()
                self.performSegueWithIdentifier("logoutSegue", sender: nil)
            }
        } catch {
            print("Something went wrong with realm!")
        }
    }
    
    func removeDeviceToken(user: User) {
        let headers = ["X-Authentication-Token": user.token]
        let parameters: [String: AnyObject] = ["user_id": user.id, "device_token": ""]
        Alamofire.request(.PUT, "http://nockapp.se/api/v1/user/devicetoken", headers: headers, parameters: parameters)
            .responseData { (request, response, data) in
                if response?.statusCode == 200 {
                    print("DEVICE TOKEN removed!")
                } else {
                    print("Error from api")
                    print(response?.statusCode)
                }
        }
    }
    
    func editProfile() {
        performSegueWithIdentifier("editProfileSegue", sender: nil)
    }
    
    func presentOptionSheet() {
        let optionActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        
        optionActionSheet.addAction(UIAlertAction(title:"Redigera Profil", style:UIAlertActionStyle.Default, handler:{ action in
            self.editProfile()
        }))
        
        optionActionSheet.addAction(UIAlertAction(title:"Lämna Företag", style:UIAlertActionStyle.Destructive, handler:{ action in
            self.leaveCompany()
        }))
        
        optionActionSheet.addAction(UIAlertAction(title:"Logga Ut", style:UIAlertActionStyle.Destructive, handler:{ action in
            self.logout()
        }))

        optionActionSheet.addAction(UIAlertAction(title:"Cancel", style:UIAlertActionStyle.Cancel, handler:{ action in
            optionActionSheet.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        presentViewController(optionActionSheet, animated:true, completion:nil)
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            header.layer.transform = headerTransform
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
            editButtonSmall.layer.transform = labelTransform
            
            //  ------------ Blur
            
            headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            // Avatar -----------
            
            
        }
        
        // Apply Transformations
        
        header.layer.transform = headerTransform
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return employees.count ?? 0
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("profileEmployeeCell", forIndexPath: indexPath) as! ProfileEmployeeCollectionViewCell
        
        cell.employeeImage.layer.cornerRadius = 2
        cell.employeeImage.layer.masksToBounds = true
        Alamofire.request(.GET, employees[indexPath.row].profileImageURL).response { (request, response, data, error) in
            cell.employeeImage.image = UIImage(data: data!, scale:1)
        }
        
        return cell
        
    }
    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
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
