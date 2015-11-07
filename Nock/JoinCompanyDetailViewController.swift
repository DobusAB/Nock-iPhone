//
//  JoinCompanyDetailViewController.swift
//  Nock
//
//  Created by Albin Martinsson on 2015-10-02.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class JoinCompanyDetailViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var companyDescription: UILabel!
    @IBOutlet weak var companyBuildingLabel: UILabel!
    @IBOutlet weak var displayCompanyName: UILabel!
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var joinButton: NockButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var joinButtonSmall: NockButtonWhite!

    
    let nockPurple = UIColor(red:0.44, green:0.00, blue:1.00, alpha:1.0)
    var company: Company!
    var user: User!
    var employees = [Employee]()
    
    override func viewWillAppear(animated: Bool) {
        view.layer.backgroundColor = nockPurple.CGColor
        scrollView.delegate = self
        companyImage.layer.cornerRadius = 2
        companyImage.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateCompany()
        getCompanyEmployees()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func populateCompany() {
        print(company.description)
        companyDescription.text = company.description
        displayCompanyName.text = company.name
        
        Alamofire.request(.GET, company.companyImageURL).response { (request, response, data, error) in
            self.companyImage.image = UIImage(data: data!, scale:1)
        }
    }
    
    func getCompanyEmployees() {
        let realm = try! Realm()
        user = realm.objects(User)[0]
        let headers = ["X-Authentication-Token": user!.token]
        Alamofire.request(.GET, "http://52.31.123.168/api/v1/company/\(company.id)", headers: headers)
            .responseData { (request, response, data) in
                if response?.statusCode == 200 {
                    let json = JSON(data: data.value!)
                    print(json)
                    for employee in json["data"]["users"] {
                        let tempEmployee = Employee(profileImageURL: employee.1["profile_image"].description)
                        self.employees.append(tempEmployee)
                        self.collectionView.reloadData()
                    }
                } else {
                    print("Error fetching data")
                    print(response?.statusCode)
                }
        }
    }
    
    
    
    func joinCompany() {
        let headers = ["X-Authentication-Token": user!.token]
        Alamofire.request(.GET, "http://52.31.123.168/api/v1/company/\(company.id)/join", headers: headers)
            .responseData { (request, response, data) in
                if response?.statusCode == 200 {
                    let json = JSON(data: data.value!)
                    print(json)
                    self.performSegueWithIdentifier("toProfileSegue", sender: nil)
                } else {
                    print("Error fetching data")
                    print(response)
                    print(JSON(data: data.value!))
                }
        }

    }

    @IBAction func join(sender: AnyObject) {
        joinCompany()        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return employees.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmployeeCollectionViewCell", forIndexPath: indexPath) as! EmployeeCollectionViewCell
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
