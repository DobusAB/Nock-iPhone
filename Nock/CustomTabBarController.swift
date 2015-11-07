//
//  CustomTabBarController.swift
//  Nock
//
//  Created by Sebastian Marcusson on 2015-10-05.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        
        let first: UIImage! = UIImage(named: "profile-tab-inactive")?.imageWithRenderingMode(.AlwaysOriginal)
        let second: UIImage! = UIImage(named: "feed-icon-inactive")?.imageWithRenderingMode(.AlwaysOriginal)
        
        let home_selected: UIImage! = UIImage(named: "profile-tab-active")?.imageWithRenderingMode(.AlwaysOriginal)
        let add_idea_selected: UIImage! = UIImage(named: "feed-icon-active")?.imageWithRenderingMode(.AlwaysOriginal)
        
        (tabBar.items![0] ).image = first
        (tabBar.items![1] ).image = second
        
        (tabBar.items![0] ).imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        (tabBar.items![1] ).imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        
        (tabBar.items![0] ).selectedImage = home_selected
        (tabBar.items![1] ).selectedImage = add_idea_selected
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGrayColor()], forState:.Selected)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
