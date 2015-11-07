//
//  Company.swift
//  Nock
//
//  Created by Sebastian Marcusson on 2015-10-03.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import Foundation

struct Company {
    var id: Int
    var name: String
    var description: String
    var companyImageURL: String
    var companyBackdropURL: String
    
    init(id: Int, name: String, description: String, companyImageURL: String, companyBackdropURL: String) {
        self.id = id
        self.name = name
        self.description = description
        self.companyImageURL = companyImageURL
        self.companyBackdropURL = companyBackdropURL
    }
}