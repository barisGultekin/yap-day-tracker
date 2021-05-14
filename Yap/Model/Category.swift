//
//  Category.swift
//  Yap
//
//  Created by Ali Barış Gültekin on 12.05.2021.
//

import Foundation
import RealmSwift

class Category: Object
{
    @objc dynamic var name: String = ""
    
    let items = List<Item>()
}
