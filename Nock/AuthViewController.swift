//
//  ViewController.swift
//  Nock
//
//  Created by Albin Martinsson on 2015-10-02.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import SwiftyJSON
//import AlamofireObjectMapper
import RealmSwift

class AuthViewController: UIViewController {
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var facebookButtonView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    let defaults = NSUserDefaults.standardUserDefaults()
    let nockPurple = UIColor(red:0.44, green:0.00, blue:1.00, alpha:1.0)
    let facebookBlue = UIColor(red:0.22, green:0.31, blue:0.52, alpha:1.0)
    var user: User!
    var userJson: JSON!
    
    override func viewWillAppear(animated: Bool) {
        facebookButtonView.layer.backgroundColor = facebookBlue.CGColor
        backgroundView.layer.backgroundColor = nockPurple.CGColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func connectWithFacebookAction(sender: AnyObject) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["email", "public_profile"], fromViewController: self, handler: { (fbResult, error) -> Void in
            if error == nil {
                self.connectWithNock(fbResult)
            } else {
                //Error logging in
                print (error)
            }
        })
    }
    
    func connectWithNock(fbResult: FBSDKLoginManagerLoginResult) {
        print(fbResult.token.tokenString)
        let parameters = ["token": fbResult.token.tokenString, "device_token": self.defaults.valueForKey("userDeviceToken") as! String]
        print(parameters)
        Alamofire.request(.POST, "http://nockapp.se/api/v1/login", parameters: parameters)
            .responseData { (request, response  , result) in
                if response?.statusCode == 200 {
                    print("STATUS = 200")
                    let json = JSON(data: result.value!)
                    if json["data"]["company_id"] == nil {
                        self.userJson = json
                        self.performSegueWithIdentifier("joinCompanySegue", sender: nil)
                    } else {
                        //User already have selected a company
                        print("LOGIN USER")
                        self.userJson = json
                        self.performSegueWithIdentifier("loginSegue", sender: nil)
                    }
                } else {
                    print("Error")
                    print(response)
                    print(result)
                }
        }
    }
    
    func saveUser(json: JSON) {
        let realm = try! Realm()
        let user = User()
        user.id = json["data"]["id"].intValue
        user.token = json["data"]["token"].description
        user.deviceToken = self.defaults.valueForKey("userDeviceToken") as! String
        if json["data"]["company_id"] != nil {
            user.companyId = json["data"]["company_id"].intValue
        }
        realm.write({ () -> Void in
            realm.add(user)
            self.storeDeviceToken(user)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func storeDeviceToken(user: User) {
        let headers = ["X-Authentication-Token": user.token]
        let parameters: [String: AnyObject] = ["user_id": user.id, "device_token": user.deviceToken]
        Alamofire.request(.PUT, "http://nockapp.se/api/v1/user/devicetoken", headers: headers, parameters: parameters)
            .responseData { (request, response, data) in
                if response?.statusCode == 200 {
                    print("DEVICE TOKEN STORED!")
                } else {
                    print("Crappy API")
                    print(response?.statusCode)
                }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "joinCompanySegue" || segue.identifier == "loginSegue" {
            if let user = userJson as? JSON {
                self.saveUser(user)
            }
        }
    }
}