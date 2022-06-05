//
//  DataModel.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/12.
//

import Foundation



struct ToDoCellData {
    var priority: Int
    var title: String
    var startDate: Date
    var endDate: Date
    var description: String?
    var custom: String?
    var index: Int?
}

struct UserData {
    var userEmail: String
    var password: String
}
