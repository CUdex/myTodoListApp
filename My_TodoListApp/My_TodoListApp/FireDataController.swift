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
    
    let db = Firestore.firestore()
    
    deinit {
        print("FireDataController - deinit")
    }
    
    func addData(_ data: ToDoCellDataModel, _ user: User, completion: @escaping () -> ()) -> Void {
        
        let userUid = user.uid
        
        //MARK: - 데이터 추가
        do {
            try _ = db.collection("ToDoList").document(userUid).collection("Task").addDocument(from: data) { err in
                if err == nil {
                    
                    print("add document -- who \(userUid)")
                    NotificationCenter.default.post(name: NSNotification.Name("reloadTask") , object: nil)
                    completion()
                }
            }
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    func modifyData(_ data: ToDoCellDataModel, _ modifyData: ToDoCellDataModel, _ user: User, completion: @escaping () -> ()) -> Void {
        
        let userUid = user.uid
        let cellData = data
        
        //modify 진행
        db.collection("ToDoList").document(userUid).collection("Task").whereField("title", isEqualTo: cellData.title ).whereField("description", isEqualTo: cellData.description).whereField("startDate", isEqualTo: cellData.startDate).getDocuments { (querySnapshot, err) in
            
            if let err = err {
                print("firestore update get document err \(err)")
            } else {
                
                guard let document = querySnapshot?.documents.first else { return }
                
                document.reference.updateData([
                    "description": modifyData.description,
                    "endDate": modifyData.endDate,
                    "isAllDay": modifyData.isAllDay,
                    "priority": modifyData.priority,
                    "startDate": modifyData.startDate,
                    "title": modifyData.title
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
    
    func getData(_ user: User, completion: @escaping ([ToDoCellDataModel]) -> ()) -> Void {
        
        var getData = [ToDoCellDataModel]()
        let userUid = user.uid
        
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
