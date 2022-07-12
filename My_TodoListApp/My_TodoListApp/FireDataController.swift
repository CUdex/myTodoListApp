//
//  FireDataController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/07/12.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FireDataController {
    
    
    func getData(completion: @escaping ([ToDoCellDataModel]) -> ()) -> Void {
        guard let user = Auth.auth().currentUser else {
            return 
        }
        var getData = [ToDoCellDataModel]()
        let userUid = user.uid
        let db = Firestore.firestore()
        
        db.collection("ToDoList").document(userUid).collection("Task").order(by: "startDate").getDocuments { (QuerySnapshot, Error) in
            if let err = Error {
                print("Error getting document: \(err)")
            } else {
                guard let queryData = QuerySnapshot?.documents else { return }
                let dicData = queryData.compactMap({ $0.data() })
                getData = dicData.compactMap { (dicData) -> ToDoCellDataModel in
                    return ToDoCellDataModel(priority: dicData["priority"] as! Int,
                                             title: dicData["title"] as! String,
                                             startDate: dicData["startDate"] as! TimeInterval,
                                             endDate: dicData["endDate"] as! TimeInterval,
                                             description: dicData["description"] as! String,
                                             isAllDay: dicData["isAllDay"] as! Bool,
                                             isFinish: dicData["isFinish"] as! Bool)
                }
                
                completion(getData)
            }
        }
    }
}
