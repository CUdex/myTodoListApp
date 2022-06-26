//
//  CalendarViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/06/26.
//

import UIKit
import FSCalendar
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class CalendarViewController: UIViewController {

    
    @IBOutlet weak var calnedarView: FSCalendar!
    @IBOutlet weak var collectionVIew: UICollectionView!
    
    var taskData = [ToDoCellDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("calendarVIew - Didload")
        settingCalendar()
        getTaskData()
    }
    
    //MARK: - calendar setting
    func settingCalendar() {
        calnedarView.dataSource = self
        calnedarView.delegate = self
    }
    
    @IBAction func testButton(_ sender: Any) {
        print(taskData)
    }
}

extension CalendarViewController {
    
    //MARK: - get data
    func getTaskData() {
        print("ToDoMain - getTaskData")
        guard let user = Auth.auth().currentUser else { return }
        
        let userUid = user.uid
        let db = Firestore.firestore()
        
        db.collection("ToDoList").document(userUid).collection("Task").order(by: "startDate").getDocuments { (QuerySnapshot, Error) in
            if let err = Error {
                print("Error getting document: \(err)")
            } else {
                guard let queryData = QuerySnapshot?.documents else { return }
                let dicData = queryData.compactMap({ $0.data() })
                self.taskData = dicData.compactMap { (dicData) -> ToDoCellDataModel in
                    return ToDoCellDataModel(priority: dicData["priority"] as! Int,
                                             title: dicData["title"] as! String,
                                             startDate: dicData["startDate"] as! TimeInterval,
                                             endDate: dicData["endDate"] as! TimeInterval,
                                             description: dicData["description"] as! String,
                                             isAllDay: dicData["isAllDay"] as! Bool,
                                             isFinish: dicData["isFinish"] as! Bool)
                }
            }
        }
    }
}

extension CalendarViewController: FSCalendarDataSource {
    
}

extension CalendarViewController: FSCalendarDelegate {
    
}
