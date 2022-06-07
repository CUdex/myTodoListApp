//
//  DataModel.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/12.
//

import Foundation



struct ToDoCellDataModel{
    let priority: Int
    let title: String
    let startDate: Date
    let endDate: Date
    let description: String?
    let UUID: String
}

struct UserDataModel {
    var userEmail: String
    var password: String
    var userName: String?
    var userPhoneNumber: String?
}
