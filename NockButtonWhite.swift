//
//  NockButton.swift
//  Nock
//
//  Created by Albin Martinsson on 2015-10-06.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import UIKit

class NockButtonWhite: UIButton {
    
    override func awakeFromNib() {
        
        
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.layer.cornerRadius = 2;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
}
