//
//  CompanyTableViewCell.swift
//  Nock
//
//  Created by Albin Martinsson on 2015-10-02.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import UIKit

class CompanyTableViewCell: UITableViewCell {
    @IBOutlet weak var companyDisplayName: UILabel?
    @IBOutlet weak var companyImage: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
