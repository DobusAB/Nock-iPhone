//
//  NockButton.swift
//  Nock
//
//  Created by Albin Martinsson on 2015-10-06.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import UIKit

class NockButton: UIButton {
    
    override func awakeFromNib() {
        
        let nockPurple = UIColor(red:0.44, green:0.00, blue:1.00, alpha:1.0)
        
        self.setTitleColor(nockPurple, forState: UIControlState.Normal)
        self.layer.cornerRadius = 2;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = nockPurple.CGColor
        
    }
    
}
