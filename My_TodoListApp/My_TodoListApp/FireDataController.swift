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
    
    
    func getData(_ user: User, completion: @escaping ([ToDoCellDataModel]) -> ()) -> Void {
        
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
    
    func updateData(_ data: ToDoCellDataModel, _ user: User, completion: @escaping () -> ()) -> Void {
        
        let userUid = user.uid
        let db = Firestore.firestore()
        let cellData = data
        
        //update 진행
        db.collection("ToDoList").document(userUid).collection("Task").whereField("title", isEqualTo: cellData.title ).whereField("description", isEqualTo: cellData.description).whereField("startDate", isEqualTo: cellData.startDate).getDocuments { (querySnapshot, err) in
            
            if let err = err {
                print("firestore update get document err \(err)")
            } else {
                
                guard let document = querySnapshot?.documents.first else { return }
                let changeIsFinish = document.data()
                let nowBool = !(changeIsFinish["isFinish"] as! Bool)
                
                document.reference.updateData([
                    "isFinish": nowBool
                ]) { err in
                    if let err = err {
                        print("firestore update err \(err)")
                    } else {
                        completion()
                    }
                }
            }
        }
    }
    
    func deleteData(_ data: ToDoCellDataModel, _ user: User, completion: @escaping () -> ()) -> Void {
        
        let userUid = user.uid
        let db = Firestore.firestore()
        let cellData = data
        
        //delete 진행
        db.collection("ToDoList").document(userUid).collection("Task").whereField("title", isEqualTo: cellData.title ).whereField("description", isEqualTo: cellData.description).whereField("startDate", isEqualTo: cellData.startDate).getDocuments { (querySnapshot, err) in
            
            if let err = err {
                print("firestore delete document err \(err)")
            } else {
                guard let document = querySnapshot?.documents.first else { return }
                //삭제
                document.reference.delete()
                completion()
            }
        }
    }
  
}
