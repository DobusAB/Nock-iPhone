//
//  CompanyRealm.swift
//  Nock
//
//  Created by Sebastian Marcusson on 2015-10-07.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import Foundation
import RealmSwift

class CompanyRealm: Object {
    dynamic var id = 0
    dynamic var name: String = ""
    dynamic var companyDescription: String = ""
    dynamic var companyImageURL: String = ""
    dynamic var companyBackdropURL: String = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
}