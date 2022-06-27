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
    var calendarDateData = [Date]()
    
    //diffable을 위한 설정
    var dayTaskData: UICollectionViewDiffableDataSource<Int, ToDoCellDataModel>!
    var snapshot: NSDiffableDataSourceSnapshot<Int, ToDoCellDataModel>!
    
    let oneDay: Double = 86400
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("calendarVIew - Didload")
        settingCalendar()
        settingCollectionView()
        getTaskData()
        
    }
    
    //MARK: - calendar setting
    func settingCalendar() {
        calnedarView.dataSource = self
        calnedarView.delegate = self
        self.calnedarView.appearance.headerMinimumDissolvedAlpha = 0 // 양옆 년월 삭제
        self.calnedarView.appearance.headerDateFormat = "YYYY년 MM월"
        calnedarView.reloadData()
    }
    
    func settingCollectionView() {
        collectionVIew.delegate = self
        collectionVIew.dataSource = dayTaskData
    }
    
    @IBAction func testButton(_ sender: Any) {
        
        calendarDateData = changeTimeToDate()
        calnedarView.reloadData()
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
    
    func changeTimeToDate() -> [Date] {
        
        var originDateData = [Date]()
        
        for slicingData in taskData {
            originDateData.append(contentsOf: getArrayDate(startDate: slicingData.startDate, endDate: slicingData.endDate))
        }
        
        return originDateData
    }
    
    func getArrayDate(startDate: TimeInterval, endDate: TimeInterval) -> [Date] {
        
        var resultDate = [Date]()
        var time: TimeInterval = startDate + oneDay
        
        resultDate.append(Date(timeIntervalSince1970: startDate).zeroOfDay)
        
        while time <= endDate {
            resultDate.append(Date(timeIntervalSince1970: time).zeroOfDay)
            time += oneDay
        }
        return resultDate
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        print(date)
        
        if calendarDateData.contains(date) {
            print("comeondot")
            return 1
        }
        return 0
    }
}

extension CalendarViewController: FSCalendarDelegate {
    
    //해당 날짜 클릭 시 date정보 가져오기
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("\(date)")
    }
}

extension CalendarViewController: UICollectionViewDelegate {
    
}
