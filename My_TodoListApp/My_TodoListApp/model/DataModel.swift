//
//  DataModel.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/12.
//

import Foundation



public struct ToDoCellDataModel {
    
    let priority: Int
    let title: String
    let startDate: TimeInterval
    let endDate: TimeInterval
    let description: String
    let isAllDay: Bool
    let isFinish: Bool
    
    var taskData: [String: Any] {
        return [
            "priority": priority,
            "title": title,
            "startDate": startDate,
            "endDate": endDate,
            "description": description,
            "isAllDay": isAllDay,
            "isFinish": isFinish
        ]
    }
}

public struct UserDataModel {
    var userEmail: String
    var password: String
    var userName: String?
    var userPhoneNumber: String?
}
