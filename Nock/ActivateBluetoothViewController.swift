//
//  ActivateBluetoothViewController.swift
//  Nock
//
//  Created by Albin Martinsson on 2015-10-03.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import UIKit

class ActivateBluetoothViewController: UIViewController {

    @IBOutlet weak var bluetoothButton: NockButtonWhite!
    
    let nockPurple = UIColor(red:0.44, green:0.00, blue:1.00, alpha:1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.backgroundColor = nockPurple.CGColor
        bluetoothButton.layer.borderColor = UIColor.whiteColor().CGColor
        bluetoothButton.layer.borderWidth = 1
        bluetoothButton.layer.cornerRadius = 2

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func activateBluetoothAction(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        
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
