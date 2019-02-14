//
//  Item.swift
//  Todoey
//
//  Created by Gio on 2/12/19.
//  Copyright © 2019 giomanveli. All rights reserved.
//

import Foundation

class Item: Encodable, Decodable {
    
    var title: String = ""
    var done: Bool = false
    
}
