//
//  User.swift
//  Nock
//
//  Created by Sebastian Marcusson on 2015-10-03.
//  Copyright © 2015 Albin Martinsson. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    dynamic var id = 0
    dynamic var token: String = ""
    dynamic var companyId = 0
    dynamic var deviceToken: String = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
}