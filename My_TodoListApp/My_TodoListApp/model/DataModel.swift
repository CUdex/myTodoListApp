//
//  DataModel.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/12.
//

import Foundation

public struct ToDoCellDataModel: Codable, Hashable {
    
    let priority: Int
    let title: String
    let startDate: TimeInterval
    let endDate: TimeInterval
    let description: String
    let isAllDay: Bool
    let isFinish: Bool
    
    enum CodingKeys: String, CodingKey {
        
        case priority
        case title
        case startDate
        case endDate
        case description
        case isAllDay
        case isFinish
        
    }
    
//    init(priority: Int, title: String, startDate: TimeInterval, endDate: TimeInterval, description: String, isAllDay: Bool, isFinish: Bool) {
//
//        self.priority = priority
//        self.title = title
//        self.startDate = startDate
//        self.endDate = endDate
//        self.description = description
//        self.isAllDay = isAllDay
//        self.isFinish = isFinish
//    }
//
//    public static func ==(lhs: ToDoCellDataModel, rhs: ToDoCellDataModel) -> Bool {
//      return lhs.priority == rhs.priority
//    }
//
//    public func hash(into hasher: inout Hasher) {
//      hasher.combine(priority)
//    }
    
//    var taskData: [String: Any] {
//        return [
//            "priority": priority,
//            "title": title,
//            "startDate": startDate,
//            "endDate": endDate,
//            "description": description,
//            "isAllDay": isAllDay,
//            "isFinish": isFinish
//        ]
//    }
}

public struct UserDataModel {
    
    var userEmail: String
    var password: String
    var userName: String?
    var userPhoneNumber: String?
}

public struct FilterSettingData {
    
    var startDay: TimeInterval = Date().zeroOfDay.timeIntervalSince1970
    var endDay: TimeInterval = Date().zeroOfDay.timeIntervalSince1970 + 86400 - 1
    var isFinished: IsFinishedCase = .all
    var priority: PriorityCase = .all
}

enum PriorityCase: Int {
    
    case low
    case middle
    case high
    case all
}

enum IsFinishedCase: Int {
    
    case notFinished
    case finished
    case all
}

//weak 선언을 위해 AnyObject 상속
protocol TaskDataDeleteDelegate: AnyObject {
    
    func deleteTaskData(_ data: ToDoCellDataModel) -> Void
    func modifyTaskData(_ data: ToDoCellDataModel) -> Void
}

protocol FilterSettingDelegate: AnyObject {
    
    func changeFilterSet(_ data: FilterSettingData) -> Void
}
