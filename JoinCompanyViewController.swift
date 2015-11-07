//
//  JoinCompanyViewController.swift
//  Nock
//
//  Created by Albin Martinsson on 2015-10-02.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class JoinCompanyViewController: UIViewController {
    @IBOutlet weak var companyTableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    let nockPurple = UIColor(red:0.44, green:0.00, blue:1.00, alpha:1.0)
    var companies = [Company]()
    
    override func viewWillAppear(animated: Bool) {
        companyTableView.separatorColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.1)
        backgroundView.layer.backgroundColor = nockPurple.CGColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCompanies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchCompanies() {
        let realm = try! Realm()
        let user = realm.objects(User)[0]
        let headers = ["X-Authentication-Token": user.token]
        Alamofire.request(.GET, "http://52.31.123.168//api/v1/companies", headers: headers)
            .responseData { (request, response, data) in
                if response?.statusCode == 200 {
                    let json = JSON(data: data.value!)
                    for company in json["data"] {
                        let tempComp = Company(id: company.1["id"].intValue, name: company.1["name"].description, description: company.1["description"].description, companyImageURL: company.1["company_imageURL"].description, companyBackdropURL: company.1["company_backdropURL"].description)
                        self.companies.append(tempComp)
                        self.companyTableView.reloadData()
                    }
                } else {
                    print("Error fetching data")
                    print(response?.statusCode)
                }
        }
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.companies.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("companyCell", forIndexPath: indexPath) as! CompanyTableViewCell
        cell.companyImage?.layer.cornerRadius = 2
        cell.companyImage?.layer.masksToBounds = true
        cell.companyDisplayName?.text = companies[indexPath.row].name
        Alamofire.request(.GET, companies[indexPath.row].companyImageURL).response { (request, response, data, error) in
            cell.companyImage?.image = UIImage(data: data!, scale:1)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("joinDetailSegue", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = sender as? NSIndexPath {
            if segue.identifier == "joinDetailSegue" {
                let svc = segue.destinationViewController as! JoinCompanyDetailViewController
                svc.company = companies[indexPath.row]
            }
        }
    }
}
