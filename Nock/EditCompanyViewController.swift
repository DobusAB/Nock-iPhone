//
//  EditCompanyViewController.swift
//  Nock
//
//  Created by Albin Martinsson on 2015-10-06.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Alamofire

class EditCompanyViewController: UIViewController {

    @IBOutlet weak var header: UIView!
    @IBOutlet weak var companyDescription: UITextView!

    let nockPurple = UIColor(red:0.44, green:0.00, blue:1.00, alpha:1.0)
    
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.layer.backgroundColor = nockPurple.CGColor
        companyDescription.becomeFirstResponder()
        fetchCompany()
    }
    
    
    func fetchCompany() {
        let realm = try! Realm()
        let user = realm.objects(User)[0]
        let headers = ["X-Authentication-Token": user.token]
        Alamofire.request(.GET, "http://52.31.123.168/api/v1/company/\(user.companyId)", headers: headers)
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

    
    
    
    func updateCompany() {
        let realm = try! Realm()
        let user = realm.objects(User)[0]
        let headers = ["X-Authentication-Token": user.token]
        let parameters = ["description": companyDescription.text]
        Alamofire.request(.PUT, "http://52.31.123.168/api/v1/company/\(user.companyId)/update", headers: headers, parameters: parameters)
            .responseData { (request, response, result) in
                if response?.statusCode == 200 {
                    print("STATUS = 200")
                } else {
                    print("Error")
                    print(response)
                    print(result)
                }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)        
    }
    
    func saveChanges() {
        print("HAHAHAHA")
    }
    
    @IBAction func save(sender: AnyObject) {
         updateCompany()
         saveChanges()
         dismissViewControllerAnimated(true, completion: nil)
    }
}
