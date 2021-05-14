//
//  Item.swift
//  Yap
//
//  Created by Ali Barış Gültekin on 12.05.2021.
//

import Foundation
import RealmSwift

class Item: Object
{
    @objc dynamic var name: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
