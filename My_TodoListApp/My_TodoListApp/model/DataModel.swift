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
    let startDate: TimeInterval
    let endDate: TimeInterval
    let description: String
    let uid: String
    let isAllDay: Bool
    
    var sendDate: [String: Any] {
        return [
            "priority": priority,
            "taskTitle": title,
            "startDate": startDate,
            "endDate": endDate,
            "description": description,
            "isAllDay": isAllDay
        ]
    }
}

struct UserDataModel {
    var userEmail: String
    var password: String
    var userName: String?
    var userPhoneNumber: String?
}
