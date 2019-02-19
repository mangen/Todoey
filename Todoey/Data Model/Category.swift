//
//  Category.swift
//  Todoey
//
//  Created by Gio on 2/17/19.
//  Copyright © 2019 giomanveli. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
